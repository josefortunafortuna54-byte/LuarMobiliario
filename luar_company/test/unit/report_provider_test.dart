import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/models/report_model.dart';
import 'package:luar_company/core/providers/report_provider.dart';
import 'package:luar_company/core/repositories/report_repository.dart';

class _FakeReportRepository extends ReportRepository {
  _FakeReportRepository({
    List<ReportModel>? reports,
    this.throwOnCreate = false,
  }) : _reports = reports ?? [];

  final List<ReportModel> _reports;
  final bool throwOnCreate;

  final List<Map<String, dynamic>> created = [];
  final List<Map<String, dynamic>> logs = [];
  final List<({String id, ReportStatus status, String reviewedById})> updates =
      [];
  final List<({ReportTarget targetType, String targetId})> hidden = [];

  @override
  Future<List<ReportModel>> fetchAll({ReportStatus? status}) async {
    if (status == null) return List.from(_reports);
    return _reports.where((r) => r.status == status).toList();
  }

  @override
  Future<void> create({
    required String reporterId,
    required ReportTarget targetType,
    required String targetId,
    required String reason,
    String details = '',
  }) async {
    if (throwOnCreate) throw Exception('falha de rede');
    created.add({
      'reporter_id': reporterId,
      'target_type': targetType,
      'target_id': targetId,
      'reason': reason,
      'details': details,
    });
  }

  @override
  Future<void> updateStatus({
    required String id,
    required ReportStatus status,
    required String reviewedById,
  }) async {
    updates.add((id: id, status: status, reviewedById: reviewedById));
  }

  @override
  Future<void> hideListing({
    required ReportTarget targetType,
    required String targetId,
  }) async {
    hidden.add((targetType: targetType, targetId: targetId));
  }

  @override
  Future<void> logModeration({
    required String actorId,
    required String action,
    ReportTarget? targetType,
    String? targetId,
    Map<String, dynamic> metadata = const {},
  }) async {
    logs.add({
      'actor_id': actorId,
      'action': action,
      'target_type': targetType,
      'target_id': targetId,
      'metadata': metadata,
    });
  }
}

ReportModel _report(String id, {ReportStatus status = ReportStatus.pending}) {
  return ReportModel(
    id: id,
    reporterId: 'u1',
    targetType: ReportTarget.property,
    targetId: 'p1',
    reason: 'spam',
    status: status,
    createdAt: DateTime(2026, 10, 15),
  );
}

void main() {
  group('ReportProvider', () {
    test('loadReports popula a lista e limpa erro', () async {
      final repo = _FakeReportRepository(reports: [_report('r1')]);
      final provider = ReportProvider(repository: repo);

      await provider.loadReports();

      expect(provider.reports.length, 1);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('loadReports com falha grava erro e lista vazia', () async {
      final provider = ReportProvider(repository: _ThrowingRepository());

      await provider.loadReports();

      expect(provider.error, contains('falha'));
      expect(provider.reports, isEmpty);
      expect(provider.isLoading, isFalse);
    });

    test('submitReport envia dados corretos', () async {
      final repo = _FakeReportRepository();
      final provider = ReportProvider(repository: repo);

      final ok = await provider.submitReport(
        reporterId: 'u1',
        targetType: ReportTarget.land,
        targetId: 'l9',
        reason: 'scam',
        details: 'desconfio',
      );

      expect(ok, isTrue);
      expect(repo.created.single['target_type'], ReportTarget.land);
      expect(repo.created.single['target_id'], 'l9');
      expect(repo.created.single['reason'], 'scam');
    });

    test('submitReport devolve false quando o repositório falha', () async {
      final provider = ReportProvider(
        repository: _FakeReportRepository(throwOnCreate: true),
      );

      final ok = await provider.submitReport(
        reporterId: 'u1',
        targetType: ReportTarget.property,
        targetId: 'p1',
        reason: 'spam',
      );

      expect(ok, isFalse);
      expect(provider.error, isNotNull);
    });

    test('updateStatus atualiza o estado local e regista moderação', () async {
      final repo = _FakeReportRepository(reports: [_report('r1')]);
      final provider = ReportProvider(repository: repo);
      await provider.loadReports();

      final ok = await provider.updateStatus(
        reportId: 'r1',
        status: ReportStatus.resolved,
        reviewedById: 'admin1',
        action: 'report_resolved',
        targetType: ReportTarget.property,
        targetId: 'p1',
      );

      expect(ok, isTrue);
      expect(provider.reports.single.status, ReportStatus.resolved);
      expect(repo.updates.single.reviewedById, 'admin1');
      expect(repo.logs.single['action'], 'report_resolved');
    });

    test('hideListing oculta o anúncio e regista moderação', () async {
      final repo = _FakeReportRepository();
      final provider = ReportProvider(repository: repo);

      final ok = await provider.hideListing(
        targetType: ReportTarget.property,
        targetId: 'p1',
        actorId: 'admin1',
        reportId: 'r1',
      );

      expect(ok, isTrue);
      expect(repo.hidden.single.targetId, 'p1');
      expect(repo.logs.single['action'], 'hide_listing');
    });
  });
}

class _ThrowingRepository extends ReportRepository {
  @override
  Future<List<ReportModel>> fetchAll({ReportStatus? status}) async {
    throw Exception('falha de rede');
  }
}
