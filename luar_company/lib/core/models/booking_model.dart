enum BookingStatus { pending, confirmed, cancelled, completed }

BookingStatus _statusFromString(String value) {
  return BookingStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => BookingStatus.pending,
  );
}

String _statusToString(BookingStatus status) => status.name;

class BookingModel {
  final String id;

  /// Imóvel marcado (vazio quando a marcação é de um terreno).
  final String propertyId;

  /// Terreno marcado (nulo quando a marcação é de um imóvel).
  final String? landId;
  final String? userId;
  final String userName;
  final String userPhone;
  final DateTime date;
  final String time;
  final BookingStatus status;
  final String notes;
  final DateTime createdAt;
  final String propertyTitle;

  const BookingModel({
    required this.id,
    required this.propertyId,
    required this.userName,
    required this.userPhone,
    required this.date,
    required this.time,
    required this.status,
    required this.notes,
    required this.createdAt,
    this.landId,
    this.userId,
    this.propertyTitle = '',
  });

  /// Verdadeiro quando a marcação é de um terreno.
  bool get isLand => (landId ?? '').isNotEmpty;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    String resolvedTitle = '';
    final properties = json['properties'];
    final lands = json['lands'];
    if (properties is Map) {
      resolvedTitle = properties['title'] as String? ?? '';
    } else if (lands is Map) {
      resolvedTitle = lands['title'] as String? ?? '';
    }

    return BookingModel(
      id: json['id'] as String? ?? '',
      propertyId: json['property_id'] as String? ?? '',
      landId: json['land_id'] as String?,
      userId: json['user_id'] as String?,
      userName: json['user_name'] as String? ?? '',
      userPhone: json['user_phone'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      time: json['time'] as String? ?? '',
      status: _statusFromString(json['status'] as String? ?? 'pending'),
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      propertyTitle: resolvedTitle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (propertyId.isNotEmpty) 'property_id': propertyId,
      if (landId != null && landId!.isNotEmpty) 'land_id': landId,
      if (userId != null) 'user_id': userId,
      'user_name': userName,
      'user_phone': userPhone,
      'date': date.toIso8601String(),
      'time': time,
      'status': _statusToString(status),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? propertyId,
    String? landId,
    String? userId,
    String? userName,
    String? userPhone,
    DateTime? date,
    String? time,
    BookingStatus? status,
    String? notes,
    DateTime? createdAt,
    String? propertyTitle,
  }) {
    return BookingModel(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      landId: landId ?? this.landId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      propertyTitle: propertyTitle ?? this.propertyTitle,
    );
  }
}
