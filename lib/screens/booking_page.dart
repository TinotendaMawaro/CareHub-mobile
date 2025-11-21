import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:carehub/models/caregiver_model.dart';
import 'package:carehub/models/booking_model.dart';
import 'package:carehub/services/booking_service.dart';
import 'package:carehub/services/auth_service.dart';

class BookingPage extends StatefulWidget {
  final Caregiver caregiver;

  const BookingPage({super.key, required this.caregiver});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final BookingService _bookingService = BookingService();
  final AuthService _authService = AuthService();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _bookAppointment() async {
    if (_selectedDay == null || _selectedTime == null) {
      Get.snackbar(
        'Error',
        'Please select a date and time.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final startTime = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // For simplicity, lets assume a booking is for 1 hour
    final endTime = startTime.add(const Duration(hours: 1));

    final userId = _authService.currentUserId;
    if (userId == null) {
      Get.snackbar(
        'Error',
        'User not logged in',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final newBooking = Booking(
      id: '', // Firestore will generate this
      caregiverId: widget.caregiver.id,
      parentId: userId,
      startTime: startTime,
      endTime: endTime,
      status: 'pending',
    );

    try {
      await _bookingService.addBooking(newBooking);
      Get.snackbar(
        'Success',
        'Booking request sent to ${widget.caregiver.name}',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to book appointment: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.caregiver.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // update `_focusedDay` here as well
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedTime == null
                      ? 'No time selected'
                      : 'Selected time: ${_selectedTime!.format(context)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton(
                  onPressed: _showTimePicker,
                  child: const Text('Select Time'),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _bookAppointment,
                child: const Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
