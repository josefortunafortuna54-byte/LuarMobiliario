import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:luar_company/core/models/report_model.dart';
import 'package:luar_company/core/models/user_model.dart';
import 'package:luar_company/core/providers/admin_provider.dart';
import 'package:luar_company/core/providers/auth_provider.dart';
import 'package:luar_company/core/providers/booking_provider.dart';
import 'package:luar_company/core/providers/land_provider.dart';
import 'package:luar_company/core/providers/property_provider.dart';
import 'package:luar_company/core/providers/report_provider.dart';
import 'package:luar_company/screens/admin/admin_bookings.dart';
import 'package:luar_company/screens/admin/admin_dashboard.dart';
import 'package:luar_company/screens/admin/admin_lands.dart';
import 'package:luar_company/screens/admin/admin_properties.dart';
import 'package:luar_company/screens/admin/admin_reports.dart';
import 'package:luar_company/screens/admin/admin_users.dart';
import 'package:luar_company/widgets/access_denied_view.dart';

import '../helpers/test_app.dart';

class _FakeAuthProvider extends AuthProvider {
  _FakeAuthProvider(this.testUser);

  final UserModel testUser;

  @override
  UserModel? get user => testUser;
}

class _RecordingAdminProvider extends AdminProvider {
  int statsCalls = 0;
  int analyticsCalls = 0;
  int usersCalls = 0;

  @override
  Future<void> loadStats() async => statsCalls++;

  @override
  Future<void> loadAnalytics() async => analyticsCalls++;

  @override
  Future<void> loadUsers() async => usersCalls++;
}

class _RecordingPropertyProvider extends PropertyProvider {
  int loadCalls = 0;

  @override
  Future<void> loadProperties({Map<String, dynamic>? filters}) async =>
      loadCalls++;
}

class _RecordingLandProvider extends LandProvider {
  int loadCalls = 0;

  @override
  Future<void> loadLands({Map<String, dynamic>? filters}) async => loadCalls++;
}

class _RecordingBookingProvider extends BookingProvider {
  int loadCalls = 0;

  @override
  Future<void> loadAllBookings() async => loadCalls++;
}

class _RecordingReportProvider extends ReportProvider {
  int loadCalls = 0;

  @override
  Future<void> loadReports({ReportStatus? status}) async => loadCalls++;
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

/// Constrói a app com todos os providers usados pelos ecrãs administrativos.
Widget _app({
  required Widget home,
  required UserRole role,
  required _RecordingAdminProvider admin,
  required _RecordingPropertyProvider properties,
  required _RecordingLandProvider lands,
  required _RecordingBookingProvider bookings,
  required _RecordingReportProvider reports,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(
        value: _FakeAuthProvider(_user(role)),
      ),
      ChangeNotifierProvider<AdminProvider>.value(value: admin),
      ChangeNotifierProvider<PropertyProvider>.value(value: properties),
      ChangeNotifierProvider<LandProvider>.value(value: lands),
      ChangeNotifierProvider<BookingProvider>.value(value: bookings),
      ChangeNotifierProvider<ReportProvider>.value(value: reports),
    ],
    child: testApp(home: home),
  );
}

class _Env {
  _Env({
    required this.admin,
    required this.properties,
    required this.lands,
    required this.bookings,
    required this.reports,
  });

  final _RecordingAdminProvider admin;
  final _RecordingPropertyProvider properties;
  final _RecordingLandProvider lands;
  final _RecordingBookingProvider bookings;
  final _RecordingReportProvider reports;

  int get totalLoadCalls =>
      admin.statsCalls +
      admin.analyticsCalls +
      admin.usersCalls +
      properties.loadCalls +
      lands.loadCalls +
      bookings.loadCalls +
      reports.loadCalls;
}

_Env _env() {
  return _Env(
    admin: _RecordingAdminProvider(),
    properties: _RecordingPropertyProvider(),
    lands: _RecordingLandProvider(),
    bookings: _RecordingBookingProvider(),
    reports: _RecordingReportProvider(),
  );
}

void main() {
  final screens = <String, Widget Function()>{
    'admin_dashboard': () => const AdminDashboard(),
    'admin_properties': () => const AdminPropertiesScreen(),
    'admin_lands': () => const AdminLandsScreen(),
    'admin_bookings': () => const AdminBookingsScreen(),
    'admin_users': () => const AdminUsersScreen(),
    'admin_reports': () => const AdminReportsScreen(),
  };

  screens.forEach((name, build) {
    testWidgets('$name: agente é impedido de ver o conteúdo administrativo', (
      tester,
    ) async {
      final env = _env();

      await tester.pumpWidget(
        _app(
          home: build(),
          role: UserRole.agent,
          admin: env.admin,
          properties: env.properties,
          lands: env.lands,
          bookings: env.bookings,
          reports: env.reports,
        ),
      );
      await tester.pump();

      expect(find.byType(AccessDeniedView), findsOneWidget);
      expect(find.text('Acesso restrito a administradores'), findsWidgets);

      // Nenhum dado administrativo é carregado para um utilizador sem role.
      expect(env.totalLoadCalls, 0);
    });

    testWidgets('$name: cliente é impedido de ver o conteúdo administrativo', (
      tester,
    ) async {
      final env = _env();

      await tester.pumpWidget(
        _app(
          home: build(),
          role: UserRole.client,
          admin: env.admin,
          properties: env.properties,
          lands: env.lands,
          bookings: env.bookings,
          reports: env.reports,
        ),
      );
      await tester.pump();

      expect(find.byType(AccessDeniedView), findsOneWidget);
      expect(env.totalLoadCalls, 0);
    });
  });

  testWidgets('admin mantém acesso e carrega os dados', (tester) async {
    final env = _env();

    await tester.pumpWidget(
      _app(
        home: const AdminDashboard(),
        role: UserRole.admin,
        admin: env.admin,
        properties: env.properties,
        lands: env.lands,
        bookings: env.bookings,
        reports: env.reports,
      ),
    );
    await tester.pump();

    expect(find.byType(AccessDeniedView), findsNothing);
    expect(find.text('Bem-vindo, Admin'), findsOneWidget);
    expect(env.admin.statsCalls, 1);
    expect(env.admin.analyticsCalls, 1);
  });
}
