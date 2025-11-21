class Caregiver {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String certifications;
  final String qualifications;
  final int experience;
  final String? profilePictureUrl;
  final String? fcmToken;
  final DateTime? lastTokenUpdate;
  final String availabilityStatus; // 'Available', 'Unavailable', 'On Shift'

  Caregiver({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.certifications,
    required this.qualifications,
    required this.experience,
    this.profilePictureUrl,
    this.fcmToken,
    this.lastTokenUpdate,
    this.availabilityStatus = 'Available',
  });
}
