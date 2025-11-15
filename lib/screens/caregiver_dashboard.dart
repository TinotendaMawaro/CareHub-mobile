import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carehub/services/booking_service.dart';
import 'package:carehub/models/booking_model.dart';
import 'package:carehub/services/auth_service.dart';

class CaregiverDashboard extends StatelessWidget {
  const CaregiverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingService bookingService = BookingService();
    final AuthService authService = AuthService();
    final String caregiverId = authService.currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Booking>>(
        stream: bookingService.getBookingsForCaregiver(caregiverId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'You have no upcoming appointments.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Booking with Parent ${booking.parentId}'),
                  subtitle: Text(
                    'On ${booking.startTime.toLocal()} \nStatus: ${booking.status}',
                  ),
                  trailing: Text(
                    '${booking.startTime.hour}:${booking.startTime.minute} - ${booking.endTime.hour}:${booking.endTime.minute}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
