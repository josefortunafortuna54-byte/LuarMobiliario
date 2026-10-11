import 'package:flutter/foundation.dart';

import '../models/booking_model.dart';
import '../repositories/booking_repository.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository _repository = BookingRepository();

  List<BookingModel> _bookings = [];
  List<BookingModel> _allBookings = [];
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get bookings => _bookings;
  List<BookingModel> get allBookings => _allBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BookingModel> get upcomingBookings =>
      _bookings
          .where(
            (b) =>
                b.status == BookingStatus.pending ||
                b.status == BookingStatus.confirmed,
          )
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  List<BookingModel> get historyBookings =>
      _bookings
          .where(
            (b) =>
                b.status == BookingStatus.cancelled ||
                b.status == BookingStatus.completed,
          )
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  Future<void> loadBookings(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await _repository.fetchByUser(userId);
    } catch (e) {
      _error = e.toString();
      _bookings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allBookings = await _repository.fetchAll();
    } catch (e) {
      _error = e.toString();
      _allBookings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    try {
      await _repository.updateStatus(bookingId, status);

      final allIndex = _allBookings.indexWhere((b) => b.id == bookingId);
      if (allIndex != -1) {
        _allBookings[allIndex] = _allBookings[allIndex].copyWith(status: status);
      }
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(status: status);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<BookingModel?> createBooking(BookingModel booking) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newBooking = await _repository.create(booking);
      _bookings.insert(0, newBooking);
      _isLoading = false;
      notifyListeners();
      return newBooking;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> registerGuestClient({
    required String name,
    required String phone,
    required String bookingId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.registerGuestClient(
        name: name,
        phone: phone,
        bookingId: bookingId,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.cancel(bookingId);

      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          status: BookingStatus.cancelled,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearBookings() {
    _bookings = [];
    _allBookings = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}