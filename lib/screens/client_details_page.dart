import 'package:carehub/models/client_model.dart';
import 'package:flutter/material.dart';

class ClientDetailsPage extends StatelessWidget {
  final Client client;

  const ClientDetailsPage({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(client.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Diagnosis: ${client.diagnosis}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text('Address: ${client.address}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Text('Emergency Contact: ${client.emergencyContact}', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
