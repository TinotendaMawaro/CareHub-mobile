import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carehub/models/caregiver_model.dart';

class CaregiverDetailsPage extends StatelessWidget {
  final Caregiver caregiver;

  const CaregiverDetailsPage({super.key, required this.caregiver});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(caregiver.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 80,
                backgroundImage: caregiver.profilePictureUrl.isNotEmpty
                    ? NetworkImage(caregiver.profilePictureUrl)
                    : null,
                child: caregiver.profilePictureUrl.isEmpty
                    ? const Icon(Icons.person, size: 80)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              caregiver.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Email: ${caregiver.email}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Phone: ${caregiver.phone}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Qualifications: ${caregiver.qualifications}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Experience: ${caregiver.experience} years',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed('/booking', arguments: caregiver);
                },
                child: const Text('Book Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
