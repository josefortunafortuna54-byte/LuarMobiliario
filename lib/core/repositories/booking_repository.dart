import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class BookingRepository {
  final SupabaseClient _client = SupabaseService.client;

  static const String _selectWithTarget =
      '*, properties(title), lands(title)';

  Future<List<BookingModel>> fetchByUser(String userId) async {
    final response = await _client
        .from('bookings')
        .select(_selectWithTarget)
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<BookingModel>> fetchAll() async {
    final response = await _client
        .from('bookings')
        .select(_selectWithTarget)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateStatus(String bookingId, BookingStatus status) async {
    await _client
        .from('bookings')
        .update({'status': status.name})
        .eq('id', bookingId);
  }

  Future<BookingModel> create(BookingModel booking) async {
    final data = booking.toJson()..remove('id');

    final response = await _client
        .from('bookings')
        .insert(data)
        .select()
        .single();

    return BookingModel.fromJson(response);
  }

  Future<void> cancel(String bookingId) async {
    await _client
        .from('bookings')
        .update({'status': BookingStatus.cancelled.name})
        .eq('id', bookingId);
  }

  Future<UserModel> registerGuestClient({
    required String name,
    required String phone,
    required String bookingId,
  }) async {
    final response = await _client
        .rpc('register_guest_client', params: {
          'p_name': name,
          'p_phone': phone,
          'p_booking_id': bookingId,
        })
        .single();

    return UserModel.fromJson(response);
  }
}