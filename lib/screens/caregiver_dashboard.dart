import 'dart:io';
import 'dart:ui';

import 'package:carehub/models/client_model.dart';
import 'package:carehub/models/incident_model.dart';
import 'package:carehub/models/shift_model.dart';
import 'package:carehub/screens/client_details_page.dart';
import 'package:carehub/services/auth_service.dart';
import 'package:carehub/services/database_service.dart';
import 'package:carehub/services/incident_service.dart';
import 'package:carehub/services/shift_service.dart';
import 'package:carehub/services/sync_service.dart';
import 'package:carehub/widgets/logo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class _AnimatedBottomNavigationBarState extends State<AnimatedBottomNavigationBar> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
        child: Container(
          color: Colors.transparent,
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
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = widget.currentIndex == index;
    if (isSelected) {
      _bounceController.forward(from: 0.0);
    }
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
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isSelected ? _bounceAnimation.value : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00FF99).withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF00FF99).withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? const Color(0xFF00FF99) : Colors.white70,
                        size: isSelected ? 28 : 24,
                      ),
                    ),
                  );
                },
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isSelected ? const Color(0xFF00FF99) : Colors.white70,
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

class __HomeScreenState extends State<_HomeScreen> with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<Alignment> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    _gradientAnimation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(_gradientController);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

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
      child: Stack(
        children: [
          // Animated Gradient Background
          AnimatedBuilder(
            animation: _gradientAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0B0E11),
                      const Color(0xFF1A1D23),
                      const Color(0xFF6200EE).withOpacity(0.3),
                      const Color(0xFF9C27B0).withOpacity(0.3),
                    ],
                    begin: _gradientAnimation.value,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Floating Glass Welcome Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [const Color(0xFF00FF99), const Color(0xFF6200EE)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FF99).withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
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
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: const Color(0xFF00FF99).withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
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
                        return AnimatedBuilder(
                          animation: _gradientAnimation,
                          builder: (context, child) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: shift.status == 'completed'
                                          ? const Color(0xFF00FF99)
                                          : shift.status == 'accepted' || shift.status == 'started'
                                              ? const Color(0xFF6200EE)
                                              : Colors.yellowAccent,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Shift with Client ${shift.clientId}',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${shift.startTime.hour}:${shift.startTime.minute.toString().padLeft(2, '0')} ${shift.startTime.hour >= 12 ? 'PM' : 'AM'} - ${shift.endTime.hour}:${shift.endTime.minute.toString().padLeft(2, '0')} ${shift.endTime.hour >= 12 ? 'PM' : 'AM'}',
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                        Text(
                                          'Status: ${shift.status}',
                                          style: TextStyle(
                                            color: shift.status == 'completed'
                                                ? const Color(0xFF00FF99)
                                                : shift.status == 'accepted' || shift.status == 'started'
                                                    ? const Color(0xFF6200EE)
                                                    : Colors.yellowAccent,
                                            fontWeight: FontWeight.w500,
                                          ),
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
                    );
                  },
                ),
              ],
            ),
          ),
        ],
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

class __ShiftsScreenState extends State<_ShiftsScreen> with TickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showCalendar = false;
  int _selectedTabIndex = 0; // 0: Pending, 1: Upcoming, 2: Completed
  late TabController _tabController;
  Shift? _activeShift;
  late AnimationController _activeShiftAnimationController;
  late Animation<double> _activeShiftAnimation;
  int _pendingSyncCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _activeShiftAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _activeShiftAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _activeShiftAnimationController, curve: Curves.easeInOut),
    );
    _activeShiftAnimationController.forward();

    // Sync offline updates after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncOfflineUpdates();
      _loadSyncStatus();
    });
  }

  Future<void> _syncOfflineUpdates() async {
    try {
      final shiftService = context.read<ShiftService>();
      final syncService = context.read<SyncService>();

      await shiftService.syncOfflineUpdates();
      await syncService.performSync();

      final pendingUpdates = await shiftService.getPendingOfflineUpdates();
      final pendingSyncCount = await syncService.getPendingSyncCount();

      if (pendingUpdates.isNotEmpty || pendingSyncCount > 0) {
        Get.snackbar('Sync Complete', '${pendingUpdates.length + pendingSyncCount} offline updates synced.');
      }

      _loadSyncStatus();
    } catch (e) {
      print('Error syncing offline updates: $e');
    }
  }

  Future<void> _loadSyncStatus() async {
    try {
      final syncService = context.read<SyncService>();
      final count = await syncService.getPendingSyncCount();
      setState(() {
        _pendingSyncCount = count;
      });
    } catch (e) {
      print('Error loading sync status: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _activeShiftAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shiftService = context.read<ShiftService>();
    final authService = context.read<AuthService>();

    return Stack(
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Shifts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    if (_pendingSyncCount > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_pendingSyncCount',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.sync),
                      onPressed: _syncOfflineUpdates,
                      tooltip: 'Sync offline data',
                    ),
                    IconButton(
                      icon: Icon(_showCalendar ? Icons.list : Icons.calendar_today),
                      onPressed: () => setState(() => _showCalendar = !_showCalendar),
                    ),
                  ],
                ),
              ],
            ),
            if (_showCalendar)
              StreamBuilder<List<Shift>>(
                stream: shiftService.getShiftsForCaregiver(authService.currentUserId!),
                builder: (context, calendarSnapshot) {
                  final shifts = calendarSnapshot.data ?? [];
                  return TableCalendar(
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
                      return shifts.where((shift) {
                        return shift.startTime.year == day.year &&
                               shift.startTime.month == day.month &&
                               shift.startTime.day == day.day;
                      }).toList();
                    },
                  );
                },
              ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Pending'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicator: BoxDecoration(
                  color: const Color(0xFF00FF99),
                  borderRadius: BorderRadius.circular(20),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
              ),
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

                  // Filter shifts based on selected tab
                  List<Shift> filteredShifts;
                  switch (_selectedTabIndex) {
                    case 0: // Pending
                      filteredShifts = shifts.where((s) => s.status == 'pending').toList();
                      break;
                    case 1: // Upcoming
                      filteredShifts = shifts.where((s) =>
                        (s.status == 'accepted' || s.status == 'started') &&
                        s.startTime.isAfter(DateTime.now())).toList();
                      break;
                    case 2: // Completed
                      filteredShifts = shifts.where((s) => s.status == 'completed').toList();
                      break;
                    default:
                      filteredShifts = shifts;
                  }

                  // Sort shifts by start time
                  filteredShifts.sort((a, b) => a.startTime.compareTo(b.startTime));

                  // Check for active shift
                  _activeShift = shifts.firstWhereOrNull((s) => s.status == 'started');

                  return ListView.builder(
                    itemCount: filteredShifts.length,
                    itemBuilder: (context, index) {
                      final shift = filteredShifts[index];
                      return Dismissible(
                        key: Key(shift.id),
                        direction: shift.status == 'pending'
                            ? DismissDirection.horizontal
                            : DismissDirection.none,
                        background: Container(
                          color: Colors.green,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.check, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            await shiftService.updateShiftStatus(shift.id, 'accepted');
                            Get.snackbar('Success', 'Shift accepted.');
                            return true;
                          } else if (direction == DismissDirection.endToStart) {
                            await shiftService.updateShiftStatus(shift.id, 'rejected');
                            Get.snackbar('Info', 'Shift rejected.');
                            return true;
                          }
                          return false;
                        },
                        child: Card(
                          margin: const EdgeInsets.all(8.0),
                          elevation: shift.status == 'pending' ? 8 : 2,
                          color: shift.status == 'pending' ? Colors.yellow.shade50 : null,
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
                                      Text(
                                        'Actual Start: ${shift.actualStartTime!.hour}:${shift.actualStartTime!.minute.toString().padLeft(2, '0')} ${shift.actualStartTime!.hour >= 12 ? 'PM' : 'AM'}',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    if (shift.actualEndTime != null)
                                      Text(
                                        'Actual End: ${shift.actualEndTime!.hour}:${shift.actualEndTime!.minute.toString().padLeft(2, '0')} ${shift.actualEndTime!.hour >= 12 ? 'PM' : 'AM'}',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    if (shift.notes != null && shift.notes!.isNotEmpty)
                                      Text(
                                        'Notes: ${shift.notes}',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (shift.status == 'pending')
                                          TextButton(
                                            onPressed: () async {
                                              await shiftService.updateShiftStatus(shift.id, 'accepted');
                                              Get.snackbar('Success', 'Shift accepted.');
                                            },
                                            child: Text('Accept', style: TextStyle(color: Color(0xFF00FF99))),
                                          ),
                                        if (shift.status == 'pending')
                                          TextButton(
                                            onPressed: () async {
                                              await shiftService.updateShiftStatus(shift.id, 'rejected');
                                              Get.snackbar('Info', 'Shift rejected.');
                                            },
                                            child: Text('Reject', style: TextStyle(color: Colors.redAccent)),
                                          ),
                                        if (shift.status == 'accepted')
                                          ElevatedButton(
                                            onPressed: () async {
                                              await shiftService.startShift(shift.id);
                                              await shiftService.addShiftLog(shift.id, {
                                                'action': 'started',
                                                'timestamp': FieldValue.serverTimestamp(),
                                                'caregiverId': authService.currentUserId,
                                              });
                                              Get.snackbar('Success', 'Shift started.');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF00FF99),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                            ),
                                            child: const Text('Start Shift'),
                                          ),
                                        if (shift.status == 'started')
                                          ElevatedButton(
                                            onPressed: () async {
                                              await shiftService.endShift(shift.id);
                                              await shiftService.addShiftLog(shift.id, {
                                                'action': 'ended',
                                                'timestamp': FieldValue.serverTimestamp(),
                                                'caregiverId': authService.currentUserId,
                                              });
                                              Get.snackbar('Success', 'Shift ended.');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                            ),
                                            child: const Text('End Shift'),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () => _showNotesDialog(shift),
                                      child: Text('Add/Edit Notes', style: TextStyle(color: Color(0xFF00FF99))),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        // Active Shift Floating Banner
        if (_activeShift != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _activeShiftAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -100 + (100 * _activeShiftAnimation.value)),
                  child: child,
                );
              },
              child: Container(
                color: Colors.blue.shade100,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Active Shift: Client ${_activeShift!.clientId} (${_activeShift!.startTime} - ${_activeShift!.endTime})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showNotesDialog(_activeShift!),
                          icon: const Icon(Icons.note_add),
                          label: const Text('Add Notes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            await shiftService.endShift(_activeShift!.id);
                            await shiftService.addShiftLog(_activeShift!.id, {
                              'action': 'ended',
                              'timestamp': FieldValue.serverTimestamp(),
                              'caregiverId': authService.currentUserId,
                            });
                            setState(() {
                              _activeShift = null;
                            });
                            Get.snackbar('Success', 'Shift ended.');
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('End Shift'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showNotesDialog(Shift shift) {
    final TextEditingController notesController =
        TextEditingController(text: shift.notes ?? '');

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
            onPressed: () async {
              await context
                  .read<ShiftService>()
                  .updateShiftNotes(shift.id, notesController.text);

              Navigator.of(context).pop();
              Get.snackbar('Success', 'Notes updated.');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _requestTimeOff(BuildContext context) {
    DateTime? startDate;
    DateTime? endDate;
    String startDateText = '';
    String endDateText = '';
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Request Time Off'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)'),
                  controller: TextEditingController(text: startDateText),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        startDate = picked;
                        startDateText = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                ),
                TextField(
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'End Date (YYYY-MM-DD)'),
                  controller: TextEditingController(text: endDateText),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? startDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        endDate = picked;
                        endDateText = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                      });
                    }
                  },
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
                if (startDate == null || endDate == null) {
                  Get.snackbar('Error', 'Please select start and end dates.');
                  return;
                }
                // Submit time off request to Firestore
                final authService = context.read<AuthService>();
                final db = FirebaseFirestore.instance;
                await db.collection('timeOffRequests').add({
                  'caregiverId': authService.currentUserId,
                  'startDate': startDateText,
                  'endDate': endDateText,
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
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  readOnly: true, // Email might not be editable
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                  ),
                ),
                TextField(
                  controller: _certificationsController,
                  decoration: const InputDecoration(
                    labelText: 'Certifications',
                  ),
                ),
                Text('Experience: ${_caregiver!.experience} years', style: Theme.of(context).textTheme.bodyMedium),
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
                TextButton(
                  onPressed: _logout,
                  child: const Text('Logout', style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(height: 20),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text('App Version: ${snapshot.data!.version}');
                    }
                    return Text('App Version: 1.0.0', style: TextStyle(color: Colors.black));
                  },
                ),
              ],
            ),
          );
  }
}
