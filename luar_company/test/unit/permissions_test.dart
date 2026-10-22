import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/models/user_model.dart';
import 'package:luar_company/core/utils/permissions.dart';

void main() {
  group('Permissions.canAccessAdminPanel', () {
    test('admin tem acesso', () {
      expect(Permissions.canAccessAdminPanel(UserRole.admin), isTrue);
    });

    test('agente não tem acesso ao painel administrativo', () {
      expect(Permissions.canAccessAdminPanel(UserRole.agent), isFalse);
    });

    test('cliente não tem acesso ao painel administrativo', () {
      expect(Permissions.canAccessAdminPanel(UserRole.client), isFalse);
    });

    test('utilizador sem role não tem acesso', () {
      expect(Permissions.canAccessAdminPanel(null), isFalse);
    });
  });

  group('Permissions.canManageAllListings', () {
    test('admin gere todos os anúncios', () {
      expect(Permissions.canManageAllListings(UserRole.admin), isTrue);
    });

    test('agente não gere o inventário global', () {
      expect(Permissions.canManageAllListings(UserRole.agent), isFalse);
    });

    test('cliente não gere o inventário global', () {
      expect(Permissions.canManageAllListings(UserRole.client), isFalse);
    });

    test('sem role não gere o inventário global', () {
      expect(Permissions.canManageAllListings(null), isFalse);
    });
  });

  group('Permissions.canCreateListing', () {
    test('agente pode publicar', () {
      expect(Permissions.canCreateListing(UserRole.agent), isTrue);
    });

    test('admin pode publicar', () {
      expect(Permissions.canCreateListing(UserRole.admin), isTrue);
    });

    test('cliente não pode publicar', () {
      expect(Permissions.canCreateListing(UserRole.client), isFalse);
    });

    test('sem role não pode publicar', () {
      expect(Permissions.canCreateListing(null), isFalse);
    });
  });

  group('Permissions.ownsListing', () {
    test('admin é dono de todos os anúncios', () {
      expect(
        Permissions.ownsListing(
          role: UserRole.admin,
          agentId: 'outro-agente',
          currentUserId: 'admin-1',
        ),
        isTrue,
      );
    });

    test('agente é dono do seu próprio anúncio', () {
      expect(
        Permissions.ownsListing(
          role: UserRole.agent,
          agentId: 'agente-1',
          currentUserId: 'agente-1',
        ),
        isTrue,
      );
    });

    test('agente não é dono do anúncio de outro agente', () {
      expect(
        Permissions.ownsListing(
          role: UserRole.agent,
          agentId: 'agente-2',
          currentUserId: 'agente-1',
        ),
        isFalse,
      );
    });

    test('cliente não é dono de anúncio algum', () {
      expect(
        Permissions.ownsListing(
          role: UserRole.client,
          agentId: 'agente-1',
          currentUserId: 'cliente-1',
        ),
        isFalse,
      );
    });

    test('anúncio sem agent_id não pertence a ninguém', () {
      expect(
        Permissions.ownsListing(
          role: UserRole.agent,
          agentId: null,
          currentUserId: 'agente-1',
        ),
        isFalse,
      );
    });

    test('utilizador sem id não é dono do anúncio', () {
      expect(
        Permissions.ownsListing(
          role: UserRole.agent,
          agentId: 'agente-1',
          currentUserId: null,
        ),
        isFalse,
      );
    });
  });

  group('userRoleFromString', () {
    test('converte os roles válidos', () {
      expect(userRoleFromString('admin'), UserRole.admin);
      expect(userRoleFromString('agent'), UserRole.agent);
      expect(userRoleFromString('client'), UserRole.client);
    });

    test('valor desconhecido cai em client', () {
      expect(userRoleFromString('superadmin'), UserRole.client);
      expect(userRoleFromString(null), UserRole.client);
    });
  });
}
