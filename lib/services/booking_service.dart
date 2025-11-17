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
}
