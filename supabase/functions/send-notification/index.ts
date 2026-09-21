// Edge Function: send-notification
// Envia uma notificacao push real via FCM (legacy HTTP API) para os tokens
// FCM registados do utilizador em notifications.fcm_token.
//
// Chamada pelo NotificationService.sendNotification:
//   supabase.functions.invoke('send-notification', { body: { user_id, title, body } })
//
// Variáveis de ambiente (definir via: supabase secrets set):
//   FCM_SERVER_KEY   Chave de servidor legada do Firebase Cloud Messaging
//   SUPABASE_URL
//   SUPABASE_SERVICE_ROLE_KEY
//
// NOTA: O RPC send_notification (migration 009) regista a notificacao na BD
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
    const { user_id, title, body } = await req.json();

    if (!user_id || !title) {
      return json({ error: "user_id e title sao obrigatorios" }, 400);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRole = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const serverKey = Deno.env.get("FCM_SERVER_KEY");

    if (!supabaseUrl || !serviceRole) {
      return json({ error: "Configuracao Supabase em falta" }, 500);
    }
    if (!serverKey) {
      return json({ error: "FCM_SERVER_KEY nao configurada" }, 500);
    }

    const supabase = createClient(supabaseUrl, serviceRole, {
      auth: { persistSession: false },
    });

    const { data: tokens, error: tokenError } = await supabase
      .from("notifications")
      .select("fcm_token")
      .eq("user_id", user_id)
      .neq("fcm_token", "");

    if (tokenError) return json({ error: tokenError.message }, 500);

    const registered = Array.isArray(tokens) ? tokens : [];
    const uniqueTokens = [...new Set(registered.map((t) => t.fcm_token))];

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
            data: { title, body },
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