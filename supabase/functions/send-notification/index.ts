// Edge Function: send-notification
// Envia uma notificacao push real via FCM para os tokens FCM registados do
// utilizador em notifications.fcm_token.
//
// Chamada pelo NotificationService.sendNotification (depois de o RPC
// send_notification validar permissoes e registar a notificacao in-app).
//
// Seguranca:
//   - verify_jwt = true (config.toml): o gateway exige um JWT valido.
//   - Alem disso validamos o chamador: apenas agentes/admins podem notificar
//     terceiros; um utilizador so pode notificar-se a si proprio.
//
// Variaveis de ambiente (supabase secrets set):
//   FCM_SERVER_KEY
//   SUPABASE_URL
//   SUPABASE_ANON_KEY           (para validar o JWT do chamador)
//   SUPABASE_SERVICE_ROLE_KEY   (para ler os tokens)
//
// NOTA: O RPC send_notification (migration 018) regista a notificacao na BD
// (recurso in-app). Esta funcao complementa com a entrega efetiva no telemovel.

import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Metodo invalido" }, 405);

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRole = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const serverKey = Deno.env.get("FCM_SERVER_KEY");

    if (!supabaseUrl || !serviceRole || !anonKey) {
      return json({ error: "Configuracao Supabase em falta" }, 500);
    }

    const authHeader = req.headers.get("Authorization") ?? "";
    if (!authHeader.toLowerCase().startsWith("bearer ")) {
      return json({ error: "Autenticacao obrigatoria" }, 401);
    }

    // Valida o chamador com o token que enviou.
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
      auth: { persistSession: false },
    });

    const { data: userData, error: userError } = await userClient.auth.getUser();
    if (userError || !userData?.user) {
      return json({ error: "Token invalido" }, 401);
    }
    const callerId = userData.user.id;

    const { user_id, title, body, route, category } = await req.json();
    if (!user_id || !title) {
      return json({ error: "user_id e title sao obrigatorios" }, 400);
    }

    // Autorizacao: agente/admin, ou o proprio.
    const { data: role } = await userClient.rpc("get_user_role");
    const isPrivileged = role === "agent" || role === "admin";
    if (!isPrivileged && callerId !== user_id) {
      return json({ error: "Nao autorizado a notificar este utilizador" }, 403);
    }

    if (!serverKey) {
      return json({ error: "FCM_SERVER_KEY nao configurada" }, 500);
    }

    const supabase = createClient(supabaseUrl, serviceRole, {
      auth: { persistSession: false },
    });

    const { data: tokens, error: tokenError } = await supabase
      .from("device_tokens")
      .select("token")
      .eq("user_id", user_id)
      .neq("token", "");

    if (tokenError) return json({ error: tokenError.message }, 500);

    const registered = Array.isArray(tokens) ? tokens : [];
    const uniqueTokens = [...new Set(registered.map((t) => t.token))];

    if (uniqueTokens.length === 0) {
      return json({ ok: true, sent: 0, note: "utilizador sem token FCM" });
    }

    const results = await Promise.all(
      uniqueTokens.map((token) =>
        fetch("https://fcm.googleapis.com/fcm/send", {
          method: "POST",
          headers: {
            Authorization: `key=${serverKey}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            to: token,
            notification: { title, body },
            data: {
              title,
              body,
              ...(route ? { route } : {}),
              ...(category ? { category } : {}),
            },
          }),
        })
      ),
    );

    const sent = results.filter((r) => r.ok).length;
    return json({ ok: true, sent, total: uniqueTokens.length });
  } catch (e) {
    const message = e instanceof Error ? e.message : "Erro desconhecido";
    return json({ error: message }, 500);
  }
});
