import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService {
  final CollectionReference _bookingsCollection = FirebaseFirestore.instance.collection('bookings');

  Future<void> addBooking(Booking booking) async {
    await _bookingsCollection.add(booking.toFirestore());
  }

  Stream<List<Booking>> getBookingsForCaregiver(String caregiverId) {
    return _bookingsCollection
        .where('caregiverId', isEqualTo: caregiverId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

  Stream<List<Booking>> getBookingsForParent(String parentId) {
    return _bookingsCollection
        .where('parentId', isEqualTo: parentId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _bookingsCollection.doc(bookingId).update({'status': status});
  }

  Future<void> startShift(String bookingId) async {
    await _bookingsCollection.doc(bookingId).update({
      'status': 'started',
      'actualStartTime': FieldValue.serverTimestamp(),
    });
  }

  Future<void> endShift(String bookingId) async {
    await _bookingsCollection.doc(bookingId).update({
      'status': 'ended',
      'actualEndTime': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateShiftNotes(String bookingId, String notes) async {
    await _bookingsCollection.doc(bookingId).update({'notes': notes});
  }
}
