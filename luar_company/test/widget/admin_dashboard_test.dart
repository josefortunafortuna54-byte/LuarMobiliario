import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:luar_company/core/models/user_model.dart';
import 'package:luar_company/core/providers/admin_provider.dart';
import 'package:luar_company/core/providers/auth_provider.dart';
import 'package:luar_company/screens/admin/admin_dashboard.dart';

import '../helpers/test_app.dart';

class _FakeAuthProvider extends AuthProvider {
  _FakeAuthProvider(this.testUser);

  final UserModel testUser;

  @override
  UserModel? get user => testUser;
}

class _FakeAdminProvider extends AdminProvider {
  @override
  Future<void> loadStats() async {}

  @override
  Future<void> loadAnalytics() async {}
}

class _FailingAdminProvider extends _FakeAdminProvider {
  @override
  String? get error => 'boom';
}

UserModel _user(UserRole role) {
  return UserModel(
    id: 'u1',
    name: 'João Mendes',
    email: 'joao@luarcompany.ao',
    phone: '+244900000000',
    avatarUrl: '',
    role: role,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

Future<void> _pumpDashboard(WidgetTester tester, {AdminProvider? admin}) {
  return tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(
          value: _FakeAuthProvider(_user(UserRole.admin)),
        ),
        ChangeNotifierProvider<AdminProvider>.value(
          value: admin ?? _FakeAdminProvider(),
        ),
      ],
      child: testApp(home: const AdminDashboard()),
    ),
  );
}

void main() {
  testWidgets('mostra secções, estatísticas e ações rápidas para admin', (
    tester,
  ) async {
    await _pumpDashboard(tester);
    await tester.pump();

    expect(find.text('Bem-vindo, Admin'), findsOneWidget);
    expect(find.text('Visão Geral'), findsOneWidget);
    expect(find.text('Análise'), findsOneWidget);
    expect(find.text('Ações Rápidas'), findsOneWidget);

    expect(find.text('Total Imóveis'), findsOneWidget);
    expect(find.text('Total Terrenos'), findsOneWidget);
    expect(find.text('Total Utilizadores'), findsOneWidget);
    expect(find.text('Mensagens Não Lidas'), findsOneWidget);

    expect(find.text('Cadastrar\nImóvel'), findsOneWidget);
    expect(find.text('Ver\nUtilizadores'), findsOneWidget);
    expect(find.text('Denúncias'), findsOneWidget);

    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    expect(find.text('A carregar análise...'), findsOneWidget);
  });

  testWidgets('oculta ações restritas a admin quando o utilizador é agente', (
    tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(
            value: _FakeAuthProvider(_user(UserRole.agent)),
          ),
          ChangeNotifierProvider<AdminProvider>.value(
            value: _FakeAdminProvider(),
          ),
        ],
        child: testApp(home: const AdminDashboard()),
      ),
    );
    await tester.pump();

    expect(find.text('Bem-vindo, Admin'), findsOneWidget);
    expect(find.text('Cadastrar\nImóvel'), findsOneWidget);
    expect(find.text('Ver\nUtilizadores'), findsNothing);
    expect(find.text('Denúncias'), findsNothing);
    expect(find.text('Ver\nParceiros'), findsOneWidget);
  });

  testWidgets('mostra estado de erro com botão para tentar novamente', (
    tester,
  ) async {
    await _pumpDashboard(tester, admin: _FailingAdminProvider());
    await tester.pump();

    expect(find.text('Erro ao carregar'), findsNWidgets(2));
    expect(find.text('Tentar novamente'), findsNWidgets(2));
  });
}
