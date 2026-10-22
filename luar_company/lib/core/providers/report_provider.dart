import 'package:flutter/foundation.dart';

import '../models/report_model.dart';
import '../repositories/report_repository.dart';
import '../services/notification_preferences.dart';
import '../services/notification_service.dart';
import '../utils/error_mapper.dart';

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
      _error = ErrorMapper.toMessage(e);
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
      _error = ErrorMapper.toMessage(e);
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
      _error = ErrorMapper.toMessage(e);
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

      // Informa o agente dono do anúncio. Ação best-effort: uma falha ao
      // notificar nunca deve invalidar a moderação já efetuada.
      try {
        final agentId = await _repository.fetchListingAgentId(
          targetType: targetType,
          targetId: targetId,
        );
        if (agentId != null) {
          await NotificationService().sendNotification(
            userId: agentId,
            title: 'Anúncio ocultado',
            body:
                'O seu anúncio foi ocultado dos resultados após revisão da moderação.',
            route: targetType == ReportTarget.land
                ? '/lands/$targetId'
                : '/properties/$targetId',
            category: NotificationCategory.listings,
          );
        }
      } catch (_) {
        // Notificação é best-effort — ignora erros.
      }
      return true;
    } catch (e) {
      _error = ErrorMapper.toMessage(e);
      notifyListeners();
      return false;
    }
  }
}
