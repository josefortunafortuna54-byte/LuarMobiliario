enum ReportTarget {
  property,
  land,
  user;

  static ReportTarget fromString(String? value) => switch (value) {
    'land' => ReportTarget.land,
    'user' => ReportTarget.user,
    _ => ReportTarget.property,
  };

  String get value => name;
}

enum ReportStatus {
  pending,
  reviewing,
  resolved,
  dismissed;

  static ReportStatus fromString(String? value) => switch (value) {
    'reviewing' => ReportStatus.reviewing,
    'resolved' => ReportStatus.resolved,
    'dismissed' => ReportStatus.dismissed,
    _ => ReportStatus.pending,
  };

  String get value => name;
}

class ReportModel {
  final String id;
  final String reporterId;
  final String reporterName;
  final ReportTarget targetType;
  final String targetId;
  final String reason;
  final String details;
  final ReportStatus status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  const ReportModel({
    required this.id,
    required this.reporterId,
    this.reporterName = '',
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.details = '',
    this.status = ReportStatus.pending,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String? ?? '',
      reporterId: json['reporter_id'] as String? ?? '',
      reporterName:
          (json['reporter'] as Map<String, dynamic>?)?['name'] as String? ?? '',
      targetType: ReportTarget.fromString(json['target_type'] as String?),
      targetId: json['target_id'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      details: json['details'] as String? ?? '',
      status: ReportStatus.fromString(json['status'] as String?),
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'target_type': targetType.value,
      'target_id': targetId,
      'reason': reason,
      'details': details,
      'status': status.value,
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  ReportModel copyWith({
    String? id,
    String? reporterId,
    String? reporterName,
    ReportTarget? targetType,
    String? targetId,
    String? reason,
    String? details,
    ReportStatus? status,
    String? reviewedBy,
    DateTime? reviewedAt,
    DateTime? createdAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      reason: reason ?? this.reason,
      details: details ?? this.details,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
