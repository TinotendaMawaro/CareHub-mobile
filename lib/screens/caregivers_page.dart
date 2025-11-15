import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carehub/services/database_service.dart';
import 'package:carehub/models/caregiver_model.dart';
import 'package:carehub/services/storage_service.dart';

class CaregiversPage extends StatelessWidget {
  const CaregiversPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = DatabaseService();
    final StorageService storageService = StorageService();

    void showDeleteConfirmationDialog(Caregiver caregiver) {
      Get.dialog(
        AlertDialog(
          title: const Text('Delete Caregiver'),
          content: Text('Are you sure you want to delete ${caregiver.name}?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await databaseService.deleteCaregiver(caregiver.id);
                  if (caregiver.profilePictureUrl.isNotEmpty) {
                    await storageService.deleteProfilePicture(caregiver.id);
                  }
                  Get.back(); // Close the dialog
                  Get.snackbar(
                    'Success',
                    '${caregiver.name} was deleted.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Failed to delete caregiver: $e',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Caregivers'),
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
            return const Center(child: Text('No caregivers found.'));
          }

          final caregivers = snapshot.data!;

          return ListView.builder(
            itemCount: caregivers.length,
            itemBuilder: (context, index) {
              final caregiver = caregivers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: caregiver.profilePictureUrl.isNotEmpty
                      ? NetworkImage(caregiver.profilePictureUrl)
                      : null,
                  child: caregiver.profilePictureUrl.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(caregiver.name),
                subtitle: Text(caregiver.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Get.toNamed('/add_edit_caregiver', arguments: caregiver);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDeleteConfirmationDialog(caregiver);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Get.toNamed('/caregiver_details', arguments: caregiver);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/add_edit_caregiver');
        },
        tooltip: 'Add Caregiver',
        child: const Icon(Icons.add),
      ),
    );
  }
}
