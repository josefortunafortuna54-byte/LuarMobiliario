import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/booking_model.dart';
import '../services/supabase_service.dart';

class BookingRepository {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<BookingModel>> fetchByUser(String userId) async {
    final response = await _client
        .from('bookings')
        .select('*, properties(title)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
        .toList();
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
}