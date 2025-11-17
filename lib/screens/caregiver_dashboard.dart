
import 'dart:io';

import 'package:CareHub/models/client_model.dart';
import 'package:CareHub/models/incident_model.dart';
import 'package:CareHub/models/shift_model.dart';
import 'package:CareHub/screens/client_details_page.dart';
import 'package:CareHub/services/auth_service.dart';
import 'package:CareHub/services/database_service.dart';
import 'package:CareHub/services/incident_service.dart';
import 'package:CareHub/services/shift_service.dart';
import 'package:CareHub/widgets/logo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/caregiver_model.dart';

class AnimatedBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AnimatedBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  _AnimatedBottomNavigationBarState createState() => _AnimatedBottomNavigationBarState();
}

class _AnimatedBottomNavigationBarState extends State<AnimatedBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.home, 'Home'),
          _buildNavItem(1, Icons.people, 'Clients'),
          _buildNavItem(2, Icons.event, 'Shifts'),
          _buildNavItem(3, Icons.report, 'Incidents'),
          _buildNavItem(4, Icons.person, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = widget.currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => widget.onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    icon,
                    key: ValueKey(isSelected),
                    color: isSelected ? Colors.green : Colors.white70,
                    size: isSelected ? 28 : 24,
                  ),
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isSelected ? Colors.green : Colors.white70,
                  fontSize: isSelected ? 14 : 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      bottomNavigationBar: AnimatedBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }


}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen();

  @override
  __HomeScreenState createState() => __HomeScreenState();
}

class __HomeScreenState extends State<_HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final shiftService = context.read<ShiftService>();
    final authService = context.read<AuthService>();
    final databaseService = context.read<DatabaseService>();

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh logic - streams will auto-update, but we can force a rebuild
        setState(() {});
      },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header with gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade100, Colors.blue.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const HeartLogo(size: 80.0),
                    const SizedBox(height: 16),
                    StreamBuilder<Caregiver?>(
                      stream: Stream.fromFuture(databaseService.getCaregiver(authService.currentUserId!)),
                      builder: (context, caregiverSnapshot) {
                        if (caregiverSnapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        final caregiver = caregiverSnapshot.data;
                        return Text(
                          'Welcome back, ${caregiver?.name ?? 'Caregiver'}!',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            // Next Shift Card
            StreamBuilder<List<Shift>>(
              stream: shiftService.getShiftsForCaregiver(authService.currentUserId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }
                final shifts = snapshot.data!;
                final nextShift = shifts.where((s) => s.status == 'accepted' && s.startTime.isAfter(DateTime.now())).toList()
                  ..sort((a, b) => a.startTime.compareTo(b.startTime));
                if (nextShift.isEmpty) return const SizedBox.shrink();

                final shift = nextShift.first;
                return Card(
                  elevation: 8,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade100, Colors.orange.shade50],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Shift',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Client: ${shift.clientId}'), // TODO: Get client name
                        Text('Time: ${shift.startTime} - ${shift.endTime}'),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await shiftService.startShift(shift.id);
                            await shiftService.addShiftLog(shift.id, {
                              'action': 'started',
                              'timestamp': FieldValue.serverTimestamp(),
                              'caregiverId': authService.currentUserId,
                            });
                            Get.snackbar('Success', 'Shift started.');
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Shift'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Notifications Card
            StreamBuilder<List<Shift>>(
              stream: shiftService.getShiftsForCaregiver(authService.currentUserId!),
              builder: (context, snapshot) {
                int pendingCount = 0;
                List<String> notifications = [];
                if (snapshot.hasData) {
                  pendingCount = snapshot.data!.where((s) => s.status == 'pending').length;
                  notifications = snapshot.data!.where((s) => s.status == 'pending').map((s) => 'New shift assigned').toList();
                }
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Notifications',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (pendingCount > 0)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$pendingCount',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(child: Text(notifications[index])),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Shifts for the Week:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => setState(() {}),
                ),
              ],
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<Shift>>(
              stream: shiftService.getShiftsForCaregiver(authService.currentUserId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No shifts assigned yet.'));
                }
                final shifts = snapshot.data!;
                final now = DateTime.now();
                final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
                final weeklyShifts = shifts.where((s) =>
                  s.startTime.isAfter(startOfWeek) && s.startTime.isBefore(endOfWeek)).toList();
                if (weeklyShifts.isEmpty) {
                  return const Center(child: Text('No shifts this week.'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: weeklyShifts.length,
                  itemBuilder: (context, index) {
                    final shift = weeklyShifts[index];
                    Color borderColor;
                    switch (shift.status) {
                      case 'completed':
                        borderColor = Colors.green;
                        break;
                      case 'accepted':
                      case 'started':
                        borderColor = Colors.blue;
                        break;
                      case 'pending':
                        borderColor = Colors.yellow;
                        break;
                      default:
                        borderColor = Colors.grey;
                    }
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: borderColor, width: 4),
                      ),
                      child: ListTile(
                        title: Text('Shift with Client ${shift.clientId}'),
                        subtitle: Text('${shift.startTime} - ${shift.endTime}\nStatus: ${shift.status}'),
                      ),
                    );
                  },
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}

class _ClientsScreen extends StatefulWidget {
  const _ClientsScreen();

  @override
  __ClientsScreenState createState() => __ClientsScreenState();
}

class __ClientsScreenState extends State<_ClientsScreen> {
  String _searchQuery = '';
  String _filterLocation = '';

  @override
  Widget build(BuildContext context) {
    final databaseService = context.read<DatabaseService>();
    final authService = context.read<AuthService>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search by name',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Filter by location',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: (value) => setState(() => _filterLocation = value),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<List<Client>>(
            stream: databaseService.getAssignedClients(authService.currentUserId!),
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
              var clients = snapshot.data!;
              if (_searchQuery.isNotEmpty) {
                clients = clients.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
              }
              if (_filterLocation.isNotEmpty) {
                clients = clients.where((c) => c.address.toLowerCase().contains(_filterLocation.toLowerCase())).toList();
              }
              return ListView.separated(
                itemCount: clients.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final client = clients[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: client.photoUrl != null ? NetworkImage(client.photoUrl!) : null,
                        child: client.photoUrl == null
                            ? Text(
                                client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${client.diagnosis}\n${client.address}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => ClientDetailsPage(client: client),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(position: offsetAnimation, child: child);
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}


class _ShiftsScreen extends StatefulWidget {
  const _ShiftsScreen();

  @override
  __ShiftsScreenState createState() => __ShiftsScreenState();
}

class __ShiftsScreenState extends State<_ShiftsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showCalendar = false;

  @override
  Widget build(BuildContext context) {
    final shiftService = context.read<ShiftService>();
    final authService = context.read<AuthService>();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Shifts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(_showCalendar ? Icons.list : Icons.calendar_today),
              onPressed: () => setState(() => _showCalendar = !_showCalendar),
            ),
          ],
        ),
        if (_showCalendar)
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) => setState(() => _calendarFormat = format),
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
          eventLoader: (day) {
            // Load shifts for the day
            final shiftService = context.read<ShiftService>();
            final authService = context.read<AuthService>();
            // Note: This is a simplified implementation. In a real app, you'd want to cache or optimize this.
            return []; // Placeholder - implement proper event loading if needed
          },
          ),
        ElevatedButton(
          onPressed: () => _requestTimeOff(context),
          child: const Text('Request Time Off'),
        ),
        Expanded(
          child: StreamBuilder<List<Shift>>(
            stream: shiftService.getShiftsForCaregiver(authService.currentUserId!),
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
              final shifts = snapshot.data!;
              return ListView.builder(
                itemCount: shifts.length,
                itemBuilder: (context, index) {
                  final shift = shifts[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      title: Text('Shift with Client ${shift.clientId}'),
                      subtitle: Text(
                        '${shift.startTime} - ${shift.endTime}\nStatus: ${shift.status}',
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (shift.actualStartTime != null)
                                Text('Actual Start: ${shift.actualStartTime}'),
                              if (shift.actualEndTime != null)
                                Text('Actual End: ${shift.actualEndTime}'),
                              if (shift.notes != null && shift.notes!.isNotEmpty)
                                Text('Notes: ${shift.notes}'),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (shift.status == 'pending')
                                    TextButton(
                                      onPressed: () async {
                                        await shiftService.updateShiftStatus(shift.id, 'accepted');
                                        // Add notification logic here if needed
                                        Get.snackbar('Success', 'Shift accepted.');
                                      },
                                      child: const Text('Accept'),
                                    ),
                                  if (shift.status == 'pending')
                                    TextButton(
                                      onPressed: () async {
                                        await shiftService.updateShiftStatus(shift.id, 'rejected');
                                        Get.snackbar('Info', 'Shift rejected.');
                                      },
                                      child: const Text('Reject'),
                                    ),
                                  if (shift.status == 'accepted')
                                    TextButton(
                                      onPressed: () async {
                                        await shiftService.startShift(shift.id);
                                        await shiftService.addShiftLog(shift.id, {
                                          'action': 'started',
                                          'timestamp': FieldValue.serverTimestamp(),
                                          'caregiverId': authService.currentUserId,
                                        });
                                        Get.snackbar('Success', 'Shift started.');
                                      },
                                      child: const Text('Start Shift'),
                                    ),
                                  if (shift.status == 'started')
                                    TextButton(
                                      onPressed: () async {
                                        await shiftService.endShift(shift.id);
                                        await shiftService.addShiftLog(shift.id, {
                                          'action': 'ended',
                                          'timestamp': FieldValue.serverTimestamp(),
                                          'caregiverId': authService.currentUserId,
                                        });
                                        Get.snackbar('Success', 'Shift ended.');
                                      },
                                      child: const Text('End Shift'),
                                    ),
                                ],
                              ),
                              TextButton(
                                onPressed: () => _showNotesDialog(shift),
                                child: const Text('Add/Edit Notes'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showNotesDialog(Shift shift) {
    final TextEditingController notesController = TextEditingController(text: shift.notes ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shift Notes'),
        content: TextField(
          controller: notesController,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'Enter notes...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ShiftService>().updateShiftNotes(shift.id, notesController.text);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _requestTimeOff(BuildContext context) {
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Time Off'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: startDateController,
                decoration: const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)'),
              ),
              TextField(
                controller: endDateController,
                decoration: const InputDecoration(labelText: 'End Date (YYYY-MM-DD)'),
              ),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Reason'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Submit time off request to Firestore
              final authService = context.read<AuthService>();
              final db = FirebaseFirestore.instance;
              await db.collection('timeOffRequests').add({
                'caregiverId': authService.currentUserId,
                'startDate': startDateController.text,
                'endDate': endDateController.text,
                'reason': reasonController.text,
                'status': 'pending',
                'submittedAt': FieldValue.serverTimestamp(),
              });
              Navigator.of(context).pop();
              Get.snackbar('Success', 'Time off request submitted.');
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class _IncidentReportsScreen extends StatefulWidget {
  @override
  __IncidentReportsScreenState createState() => __IncidentReportsScreenState();
}

class __IncidentReportsScreenState extends State<_IncidentReportsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _incidentType = 'Medical';
  final _descriptionController = TextEditingController();
  DateTime _dateTime = DateTime.now();
  final _involvedPartiesController = TextEditingController();
  final _actionsTakenController = TextEditingController();
  List<File> _photos = [];
  bool _showForm = true;

  final List<String> _incidentTypes = ['Medical', 'Behavioral', 'Safety', 'Other'];

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dateTime),
      );
      if (time != null) {
        setState(() => _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
      }
    }
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    setState(() => _photos.addAll(pickedFiles.map((f) => File(f.path))));
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      try {
        List<String> photoUrls = [];
        for (final photo in _photos) {
          final url = await context.read<DatabaseService>().uploadFile(photo, 'incident_photos/${DateTime.now().millisecondsSinceEpoch}');
          photoUrls.add(url);
        }
        final incident = Incident(
          id: '',
          caregiverId: context.read<AuthService>().currentUserId!,
          incidentType: _incidentType,
          description: _descriptionController.text,
          dateTime: _dateTime,
          involvedParties: _involvedPartiesController.text,
          actionsTaken: _actionsTakenController.text,
          status: 'Reported',
          photoUrls: photoUrls,
        );
        await context.read<IncidentService>().addIncident(incident);
        Get.snackbar('Success', 'Incident report submitted successfully.');
        _formKey.currentState!.reset();
        setState(() {
          _photos = [];
          _showForm = false;
        });
      } catch (e) {
        Get.snackbar('Error', 'Failed to submit report: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _showForm ? _buildForm() : _buildList();
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _incidentType,
                items: _incidentTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => _incidentType = value!),
                decoration: const InputDecoration(labelText: 'Incident Type'),
                validator: (value) => value == null ? 'Please select an incident type' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              ListTile(
                title: Text('Date & Time: ${_dateTime.toString()}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickPhotos,
                icon: const Icon(Icons.photo),
                label: const Text('Attach Photos'),
              ),
              if (_photos.isNotEmpty)
                Wrap(
                  children: _photos.map((photo) => Image.file(photo, width: 50, height: 50)).toList(),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitReport,
                child: const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => setState(() => _showForm = true),
          child: const Text('New Report'),
        ),
        Expanded(
          child: StreamBuilder<List<Incident>>(
            stream: context.read<IncidentService>().getIncidentsForCaregiver(context.read<AuthService>().currentUserId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No incidents reported.'));
              }
              final incidents = snapshot.data!;
              return ListView.builder(
                itemCount: incidents.length,
                itemBuilder: (context, index) {
                  final incident = incidents[index];
                  return ListTile(
                    title: Text(incident.incidentType),
                    subtitle: Text('${incident.dateTime}\n${incident.description}'),
                    trailing: Text(incident.status),
                    onTap: () {
                      if (incident.status == 'Reported') {
                        // Allow editing if not submitted
                        _editIncident(incident);
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _editIncident(Incident incident) {
    // Populate form with existing data
    setState(() {
      _incidentType = incident.incidentType;
      _descriptionController.text = incident.description;
      _dateTime = incident.dateTime;
      _involvedPartiesController.text = incident.involvedParties;
      _actionsTakenController.text = incident.actionsTaken;
      _photos = []; // Reset photos for editing
      _showForm = true;
    });
    // Note: In a full implementation, you'd want to track if this is an edit and update instead of add
    Get.snackbar('Info', 'Edit functionality partially implemented. Photos not loaded.');
  }
}

class _ProfileScreen extends StatefulWidget {
  @override
  __ProfileScreenState createState() => __ProfileScreenState();
}

class __ProfileScreenState extends State<_ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _certificationsController = TextEditingController();
  File? _image;
  Caregiver? _caregiver;

  @override
  void initState() {
    super.initState();
    _loadCaregiverData();
  }

  Future<void> _loadCaregiverData() async {
    final authService = context.read<AuthService>();
    final databaseService = context.read<DatabaseService>();
    final caregiver = await databaseService.getCaregiver(authService.currentUserId!);
    if (caregiver != null) {
      setState(() {
        _caregiver = caregiver;
        _nameController.text = caregiver.name;
        _emailController.text = caregiver.email;
        _phoneController.text = caregiver.phone;
        _certificationsController.text = caregiver.certifications;
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
      final databaseService = context.read<DatabaseService>();
      String? imageUrl;
      if (_image != null) {
        imageUrl = await databaseService.uploadFile(_image!, 'profile_pictures/${_caregiver!.id}');
      }
      final updatedCaregiver = Caregiver(
        id: _caregiver!.id,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        certifications: _certificationsController.text,
        qualifications: _caregiver!.qualifications,
        experience: _caregiver!.experience,
        profilePictureUrl: imageUrl ?? _caregiver!.profilePictureUrl,
      );
      await databaseService.updateCaregiver(updatedCaregiver);
      Get.snackbar('Success', 'Profile updated successfully.');
    }
  }

  Future<void> _changePassword() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(labelText: 'Current Password'),
                obscureText: true,
              ),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm New Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                Get.snackbar('Error', 'Passwords do not match.');
                return;
              }
              try {
                final user = FirebaseAuth.instance.currentUser;
                final credential = EmailAuthProvider.credential(
                  email: user!.email!,
                  password: currentPasswordController.text,
                );
                await user.reauthenticateWithCredential(credential);
                await user.updatePassword(newPasswordController.text);
                Navigator.of(context).pop();
                Get.snackbar('Success', 'Password changed successfully.');
              } catch (e) {
                Get.snackbar('Error', 'Failed to change password: $e');
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await context.read<AuthService>().signOut();
    Get.offAllNamed('/auth');
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
                        : (_caregiver!.profilePictureUrl?.isNotEmpty ?? false
                            ? NetworkImage(_caregiver!.profilePictureUrl!)
                            : null),
                    child: _image == null && (_caregiver!.profilePictureUrl?.isEmpty ?? true)
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  readOnly: true, // Email might not be editable
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                TextField(
                  controller: _certificationsController,
                  decoration: const InputDecoration(labelText: 'Certifications'),
                ),
                Text('Experience: ${_caregiver!.experience} years'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text('Update Profile'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _changePassword,
                  child: const Text('Change Password'),
                ),
                ElevatedButton(
                  onPressed: _logout,
                  child: const Text('Logout'),
                ),
                const SizedBox(height: 20),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text('App Version: ${snapshot.data!.version}');
                    }
                    return const Text('App Version: 1.0.0');
                  },
                ),
              ],
            ),
          );
  }
}
