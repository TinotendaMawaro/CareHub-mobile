class Caregiver {
  final String id;
  final String name;
  final String qualifications;
  final String? profilePictureUrl;

  Caregiver({
    required this.id,
    required this.name,
    required this.qualifications,
    this.profilePictureUrl,
  });
}
