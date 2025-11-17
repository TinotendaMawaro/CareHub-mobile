class Shift {
  final String id;
  final String clientId;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // pending, accepted, rejected, started, ended
  String? notes;

  Shift({
    required this.id,
    required this.clientId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
  });
}
