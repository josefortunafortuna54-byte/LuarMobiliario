import 'package:flutter/foundation.dart';

import '../models/report_model.dart';
import '../repositories/report_repository.dart';

class ReportProvider extends ChangeNotifier {
  ReportProvider({ReportRepository? repository})
    : _repository = repository ?? ReportRepository();

  final ReportRepository _repository;

  List<ReportModel> _reports = [];
  bool _isLoading = false;
  String? _error;

  List<ReportModel> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReports({ReportStatus? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reports = await _repository.fetchAll(status: status);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submete uma denúncia. Devolve `false` quando falha (ex.: sem sessão).
  Future<bool> submitReport({
    required String reporterId,
    required ReportTarget targetType,
    required String targetId,
    required String reason,
    String details = '',
  }) async {
    try {
      await _repository.create(
        reporterId: reporterId,
        targetType: targetType,
        targetId: targetId,
        reason: reason,
        details: details,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus({
    required String reportId,
    required ReportStatus status,
    required String reviewedById,
    String? action,
    ReportTarget? targetType,
    String? targetId,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      await _repository.updateStatus(
        id: reportId,
        status: status,
        reviewedById: reviewedById,
      );
      await _repository.logModeration(
        actorId: reviewedById,
        action: action ?? 'report_${status.value}',
        targetType: targetType,
        targetId: targetId,
        metadata: {'report_id': reportId, ...metadata},
      );

      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _reports[index] = _reports[index].copyWith(
          status: status,
          reviewedBy: reviewedById,
          reviewedAt: DateTime.now(),
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Ação de moderação: ocultar anúncio + registar no moderation_log.
  Future<bool> hideListing({
    required ReportTarget targetType,
    required String targetId,
    required String actorId,
    required String reportId,
  }) async {
    try {
      await _repository.hideListing(targetType: targetType, targetId: targetId);
      await _repository.logModeration(
        actorId: actorId,
        action: 'hide_listing',
        targetType: targetType,
        targetId: targetId,
        metadata: {'report_id': reportId},
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
