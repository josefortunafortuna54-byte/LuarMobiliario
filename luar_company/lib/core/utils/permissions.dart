import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/user_model.dart';

/// Fonte única de verdade para as permissões por role.
///
/// Antes existiam sete verificações de role divergentes nos ecrãs de
/// administração: o ecrã de login e o dashboard aceitavam `agent`, enquanto
/// `admin_users` e `admin_reports` exigiam `admin` estrito. Um agente que
/// entrasse pelo login de admin ficava com acesso ao inventário global de
/// anúncios e às métricas da plataforma — o RLS bloqueiava a escrita, mas a
/// leitura e a UI deviam impedir a tentativa.
abstract final class Permissions {
  /// O painel de administração é exclusivo do role `admin`.
  ///
  /// Os agentes têm o seu próprio espaço de gestão (`my_listings`), onde veem
  /// apenas os seus anúncios.
  static bool canAccessAdminPanel(UserRole? role) => role == UserRole.admin;

  /// Só o administrador gere o inventário completo de anúncios.
  static bool canManageAllListings(UserRole? role) => role == UserRole.admin;

  /// O utilizador pode publicar anúncios (agente ou administrador).
  static bool canCreateListing(UserRole? role) =>
      role == UserRole.agent || role == UserRole.admin;

  /// O utilizador é dono do anúncio e pode editá-lo.
  ///
  /// O administrador é dono de todos os anúncios. O RLS aplica a mesma regra
  /// no servidor (`auth.uid() = agent_id OR role = 'admin'`); esta função
  /// existe para a UI não oferecer ações que o servidor vai recusar.
  static bool ownsListing({
    required UserRole? role,
    required String? agentId,
    required String? currentUserId,
  }) {
    if (role == UserRole.admin) return true;
    if (agentId == null || currentUserId == null) return false;
    return agentId == currentUserId;
  }
}

/// Afasta o utilizador de um ecrã restrito e notifica-o.
///
/// Devolve `true` quando o acesso foi **recusado** — o chamador deve
/// interromper o carregamento de dados e apresentar [AccessDeniedView].
///
/// O `pop` só é feito quando existe historial para onde recuar: se o ecrã for
/// a rota inicial não há nada para onde voltar, e nesse caso o ecrã tem de
/// se auto-bloquear em vez de ficar visível.
bool denyUnlessAdmin(
  BuildContext context, {
  required UserRole? role,
  required String message,
}) {
  if (Permissions.canAccessAdminPanel(role)) return false;

  if (!context.mounted) return true;

  final navigator = Navigator.of(context);
  if (navigator.canPop()) navigator.pop();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: AppColors.error),
  );
  return true;
}
