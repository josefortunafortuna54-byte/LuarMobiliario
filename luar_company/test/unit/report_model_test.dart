import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/models/report_model.dart';

void main() {
  group('ReportModel', () {
    test('fromJson ignora campos ausentes com valores por omissão', () {
      final report = ReportModel.fromJson(const {});

      expect(report.id, '');
      expect(report.reporterId, '');
      expect(report.targetType, ReportTarget.property);
      expect(report.status, ReportStatus.pending);
      expect(report.details, '');
      expect(report.reviewedBy, isNull);
      expect(report.reviewedAt, isNull);
    });

    test(
      'fromJson converte campos da BD (enums, datas e join do reporter)',
      () {
        final report = ReportModel.fromJson(const {
          'id': 'r1',
          'reporter_id': 'u1',
          'reporter': {'name': 'Maria'},
          'target_type': 'land',
          'target_id': 'l1',
          'reason': 'scam',
          'details': 'suspeito',
          'status': 'reviewing',
          'reviewed_by': 'admin1',
          'reviewed_at': '2026-10-15T10:00:00Z',
          'created_at': '2026-10-14T08:30:00Z',
        });

        expect(report.reporterName, 'Maria');
        expect(report.targetType, ReportTarget.land);
        expect(report.status, ReportStatus.reviewing);
        expect(report.reviewedBy, 'admin1');
        expect(report.createdAt, DateTime.parse('2026-10-14T08:30:00Z'));
      },
    );

    test('enums revertem para valores da BD', () {
      expect(ReportTarget.user.value, 'user');
      expect(ReportTarget.fromString('user'), ReportTarget.user);
      expect(ReportTarget.fromString('nada'), ReportTarget.property);
      expect(ReportStatus.resolved.value, 'resolved');
      expect(ReportStatus.fromString('dismissed'), ReportStatus.dismissed);
      expect(ReportStatus.fromString(null), ReportStatus.pending);
    });

    test('toJson usa chaves snake_case e omit reviewed_by nulo', () {
      final report = ReportModel(
        id: 'r1',
        reporterId: 'u1',
        targetType: ReportTarget.property,
        targetId: 'p1',
        reason: 'spam',
        createdAt: DateTime(2026, 10, 15),
      );

      final json = report.toJson();

      expect(json['target_type'], 'property');
      expect(json['status'], 'pending');
      expect(json['reviewed_by'], isNull);
      expect(json['created_at'], isNotNull);
    });

    test('copyWith substitui apenas os campos pedidos', () {
      final report = ReportModel(
        id: 'r1',
        reporterId: 'u1',
        targetType: ReportTarget.property,
        targetId: 'p1',
        reason: 'spam',
        createdAt: DateTime(2026, 10, 15),
      );

      final updated = report.copyWith(
        status: ReportStatus.resolved,
        reviewedBy: 'admin1',
        reviewedAt: DateTime(2026, 10, 15, 12),
      );

      expect(updated.status, ReportStatus.resolved);
      expect(updated.reviewedBy, 'admin1');
      expect(updated.id, 'r1');
      expect(updated.reason, 'spam');
    });
  });
}
