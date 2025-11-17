
import 'dart:io';

import 'package:carehub/models/client_model.dart';
import 'package:carehub/screens/client_details_page.dart';
import 'package:carehub/services/auth_service.dart';
import 'package:carehub/services/booking_service.dart';
import 'package:carehub/services/database_service.dart';
import 'package:carehub/widgets/logo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/booking_model.dart';
import '../models/caregiver_model.dart';

class CaregiverDashboard extends StatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  _CaregiverDashboardState createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeScreen(),
    _ClientsScreen(),
    const _ShiftsScreen(),
    _IncidentReportsScreen(),
    _ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Shifts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Incidents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Logo(
            height: 100,
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome, Caregiver!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Text(
            'Your Shifts for the Week:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Expanded(
            child: Center(
              child: Text('No shifts assigned yet.'),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Notifications:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Expanded(
            child: Center(
              child: Text('No new notifications.'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientsScreen extends StatelessWidget {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  _ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Client>>(
      stream: _databaseService.getAssignedClients(_authService.currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No clients assigned.'));
        }
        final clients = snapshot.data!;
        return ListView.builder(
          itemCount: clients.length,
          itemBuilder: (context, index) {
            final client = clients[index];
            return ListTile(
              title: Text(client.name),
              subtitle: Text(client.diagnosis),
              onTap: () {
                Get.to(() => ClientDetailsPage(client: client));
              },
            );
          },
        );
      },
    );
  }
}


class _ShiftsScreen extends StatefulWidget {
  const _ShiftsScreen();

  @override
  __ShiftsScreenState createState() => __ShiftsScreenState();
}

class __ShiftsScreenState extends State<_ShiftsScreen> {
  final BookingService _bookingService = BookingService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Booking>>(
      stream: _bookingService.getBookingsForCaregiver(_authService.currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No shifts assigned.'));
        }
        final bookings = snapshot.data!;
        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text('Shift with ${booking.parentId}'),
                subtitle: Text(
                  '${booking.startTime} - ${booking.endTime}\nStatus: ${booking.status}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (booking.status == 'pending')
                      TextButton(
                        onPressed: () => _bookingService.updateBookingStatus(
                          booking.id,
                          'accepted',
                        ),
                        child: const Text('Accept'),
                      ),
                    if (booking.status == 'pending')
                      TextButton(
                        onPressed: () => _bookingService.updateBookingStatus(
                          booking.id,
                          'rejected',
                        ),
                        child: const Text('Reject'),
                      ),
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

class _IncidentReportsScreen extends StatefulWidget {
  @override
  __IncidentReportsScreenState createState() => __IncidentReportsScreenState();
}

class __IncidentReportsScreenState extends State<_IncidentReportsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('incidents').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'caregiverId': AuthService().currentUserId,
      });
      Get.snackbar('Success', 'Incident report submitted.');
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Incident Title'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a title' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration:
                  const InputDecoration(labelText: 'Incident Description'),
              maxLines: 5,
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a description' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitReport,
              child: const Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileScreen extends StatefulWidget {
  @override
  __ProfileScreenState createState() => __ProfileScreenState();
}

class __ProfileScreenState extends State<_ProfileScreen> {
  final _authService = AuthService();
  final _databaseService = DatabaseService();
  final _nameController = TextEditingController();
  final _qualificationsController = TextEditingController();
  File? _image;
  Caregiver? _caregiver;

  @override
  void initState() {
    super.initState();
    _loadCaregiverData();
  }

  Future<void> _loadCaregiverData() async {
    final caregiver = await _databaseService.getCaregiver(_authService.currentUserId);
    if (caregiver != null) {
      setState(() {
        _caregiver = caregiver;
        _nameController.text = caregiver.name;
        _qualificationsController.text = caregiver.qualifications;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_caregiver != null) {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await DatabaseService().uploadFile(_image!, 'profile_pictures');
      }
      final updatedCaregiver = Caregiver(
        id: _caregiver!.id,
        name: _nameController.text,
        qualifications: _qualificationsController.text,
        profilePictureUrl: imageUrl ?? _caregiver!.profilePictureUrl,
      );
      await _databaseService.updateCaregiver(updatedCaregiver);
      Get.snackbar('Success', 'Profile updated successfully.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _caregiver == null
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : (_caregiver!.profilePictureUrl.isNotEmpty
                            ? NetworkImage(_caregiver!.profilePictureUrl)
                            : const AssetImage('assets/placeholder.png'))
                                as ImageProvider,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _qualificationsController,
                  decoration: const InputDecoration(labelText: 'Qualifications'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text('Update Profile'),
                ),
              ],
            ),
          );
  }
}
