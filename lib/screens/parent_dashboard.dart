import 'package:carehub/models/booking_model.dart';
import 'package:carehub/services/booking_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carehub/services/database_service.dart';
import 'package:carehub/models/caregiver_model.dart';
import 'package:carehub/services/auth_service.dart';
import 'package:carehub/models/shift_model.dart';
import 'package:carehub/services/shift_service.dart';
import 'package:carehub/models/client_model.dart';
import 'package:carehub/services/client_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final ShiftService _shiftService = ShiftService();
  final ClientService _clientService = ClientService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Shifts',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildCaregiverList();
      case 1:
        return _buildBookingList();
      case 2:
        return _buildClientList();
      case 3:
        return _buildShiftList();
      default:
        return _buildCaregiverList();
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

        return FutureBuilder<Map<String, String>>(
          future: _getClientNames(),
          builder: (context, clientSnapshot) {
            final clientNames = clientSnapshot.data ?? {};

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: caregivers.length,
              itemBuilder: (context, index) {
                final caregiver = caregivers[index];
                final assignedClients = _getAssignedClientsForCaregiver(caregiver.id, clientNames);

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: caregiver.profilePictureUrl?.isNotEmpty ?? false
                          ? NetworkImage(caregiver.profilePictureUrl!)
                          : null,
                      child: caregiver.profilePictureUrl?.isEmpty ?? true
                          ? const Icon(Icons.person, size: 30)
                          : null,
                    ),
                    title: Text(caregiver.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(caregiver.qualifications),
                        if (assignedClients.isNotEmpty)
                          Text('Clients: ${assignedClients.join(', ')}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
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
      },
    );
  }

  List<String> _getAssignedClientsForCaregiver(String caregiverId, Map<String, String> clientNames) {
    // This is a simplified implementation. In a real app, you'd have a proper relationship
    // For now, we'll return a placeholder or implement based on your data structure
    return []; // TODO: Implement based on your caregiver-client assignment logic
  }

  Widget _buildBookingList() {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return const Center(child: Text('User not logged in'));
    }
    return StreamBuilder<List<Booking>>(
      stream: _bookingService.getBookingsForParent(userId),
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

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Available Caregivers';
      case 1:
        return 'My Bookings';
      case 2:
        return 'Clients';
      case 3:
        return 'Shifts';
      default:
        return 'Parent Dashboard';
    }
  }

  Widget _buildClientList() {
    return StreamBuilder<List<Client>>(
      stream: _clientService.getAllClients(),
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
              'No clients found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final clients = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: clients.length,
          itemBuilder: (context, index) {
            final client = clients[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: client.photoUrl?.isNotEmpty ?? false
                      ? NetworkImage(client.photoUrl!)
                      : null,
                  child: client.photoUrl?.isEmpty ?? true
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(client.diagnosis),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Get.toNamed('/client_details', arguments: client);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShiftList() {
    return StreamBuilder<List<Shift>>(
      stream: _shiftService.getAllShifts(),
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
              'No shifts found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final shifts = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: shifts.length,
          itemBuilder: (context, index) {
            final shift = shifts[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text('Shift ID: ${shift.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Caregiver: ${shift.caregiverId}'),
                    Text('Client: ${shift.clientId}'),
                    Text('Date: ${shift.startTime.toLocal().toString().split(' ')[0]}'),
                    Text('Start: ${shift.startTime.hour}:${shift.startTime.minute.toString().padLeft(2, '0')}'),
                    Text('End: ${shift.endTime.hour}:${shift.endTime.minute.toString().padLeft(2, '0')}'),
                    Text('Status: ${shift.status}'),
                    if (shift.notes != null && shift.notes!.isNotEmpty) Text('Notes: ${shift.notes}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
