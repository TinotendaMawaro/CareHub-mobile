class Client {
  final String id;
  final String name;
  final String diagnosis;
  final String address;
  final String emergencyContact;

  Client({
    required this.id,
    required this.name,
    required this.diagnosis,
    required this.address,
    required this.emergencyContact,
  });

  factory Client.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Client(
      id: documentId,
      name: data['name'] ?? '',
      diagnosis: data['diagnosis'] ?? '',
      address: data['address'] ?? '',
      emergencyContact: data['emergencyContact'] ?? '',
    );
  }
}
