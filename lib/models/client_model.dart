class Client {
  final String id;
  final String name;
  final String diagnosis;
  final String address;
  final String emergencyContact;
  final String? photoUrl;
  final String? medicalNotes;

  Client({
    required this.id,
    required this.name,
    required this.diagnosis,
    required this.address,
    required this.emergencyContact,
    this.photoUrl,
    this.medicalNotes,
  });

  factory Client.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Client(
      id: documentId,
      name: data['name'] ?? '',
      diagnosis: data['diagnosis'] ?? '',
      address: data['address'] ?? '',
      emergencyContact: data['emergencyContact'] ?? '',
      photoUrl: data['photoUrl'],
      medicalNotes: data['medicalNotes'],
    );
  }
}
