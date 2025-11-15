import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carehub/services/database_service.dart';
import 'package:carehub/models/caregiver_model.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Caregivers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement a proper logout service
              Get.offAllNamed('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<List<Caregiver>>(
        stream: databaseService.getCaregivers(),
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
                  title: Text(caregiver.name, style: const TextStyle(fontWeight: FontWeight.bold)),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/add_edit_caregiver');
        },
        tooltip: 'Add New Caregiver',
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}
