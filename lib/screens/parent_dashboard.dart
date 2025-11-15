import 'package:carehub/models/booking_model.dart';
import 'package:carehub/services/booking_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carehub/services/database_service.dart';
import 'package:carehub/models/caregiver_model.dart';
import 'package:carehub/services/auth_service.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  _ParentDashboardState createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _currentIndex = 0;
  final DatabaseService _databaseService = DatabaseService();
  final BookingService _bookingService = BookingService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Available Caregivers' : 'My Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authService.signOut();
              Get.offAllNamed('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Caregivers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'My Bookings',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Get.toNamed('/add_edit_caregiver');
              },
              tooltip: 'Add New Caregiver',
              child: const Icon(Icons.person_add_alt_1),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 0) {
      return _buildCaregiverList();
    } else {
      return _buildBookingList();
    }
  }

  Widget _buildCaregiverList() {
    return StreamBuilder<List<Caregiver>>(
      stream: _databaseService.getCaregivers(),
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
              'No caregivers are available at the moment.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final caregivers = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: caregivers.length,
          itemBuilder: (context, index) {
            final caregiver = caregivers[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: caregiver.profilePictureUrl.isNotEmpty
                      ? NetworkImage(caregiver.profilePictureUrl)
                      : null,
                  child: caregiver.profilePictureUrl.isEmpty
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                title: Text(caregiver.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(caregiver.qualifications),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Get.toNamed('/caregiver_details', arguments: caregiver);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBookingList() {
    return StreamBuilder<List<Booking>>(
      stream: _bookingService.getBookingsForParent(_authService.currentUserId),
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
              'You have no bookings.',
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
                title: Text('Booking with Caregiver ${booking.caregiverId}'),
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
    );
  }
}
