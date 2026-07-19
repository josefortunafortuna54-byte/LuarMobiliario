import '../models/booking_model.dart';
import '../services/supabase_service.dart';

class BookingRepository {
  final _client = SupabaseService.client;
  static const _table = 'bookings';

  Future<List<BookingModel>> getBookings(String userId) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<BookingModel>> getPropertyBookings(String propertyId) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('property_id', propertyId)
          .order('date', ascending: true);

      return (response as List<dynamic>)
          .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<BookingModel> createBooking(BookingModel booking) async {
    final data = booking.toJson()..remove('id');

    final response =
        await _client.from(_table).insert(data).select().single();

    return BookingModel.fromJson(response);
  }

  Future<BookingModel> updateBookingStatus(
    String id,
    BookingStatus status,
  ) async {
    final response =
        await _client
            .from(_table)
            .update({'status': status.name})
            .eq('id', id)
            .select()
            .single();

    return BookingModel.fromJson(response);
  }

  Future<void> cancelBooking(String id) async {
    await _client
        .from(_table)
        .update({'status': BookingStatus.cancelled.name})
        .eq('id', id);
  }
}
