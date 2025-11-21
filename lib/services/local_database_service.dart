import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/shift_model.dart';
import '../models/incident_model.dart';
import '../models/client_model.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  static Database? _database;

  factory LocalDatabaseService() => _instance;

  LocalDatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'carehub_local.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Shifts table
    await db.execute('''
      CREATE TABLE shifts (
        id TEXT PRIMARY KEY,
        caregiverId TEXT,
        clientId TEXT,
        startTime TEXT,
        endTime TEXT,
        status TEXT,
        actualStartTime TEXT,
        actualEndTime TEXT,
        notes TEXT,
        lastSync TEXT
      )
    ''');

    // Incidents table
    await db.execute('''
      CREATE TABLE incidents (
        id TEXT PRIMARY KEY,
        caregiverId TEXT,
        incidentType TEXT,
        description TEXT,
        dateTime TEXT,
        involvedParties TEXT,
        actionsTaken TEXT,
        status TEXT,
        photoUrls TEXT,
        lastSync TEXT
      )
    ''');

    // Clients table for offline access
    await db.execute('''
      CREATE TABLE clients (
        id TEXT PRIMARY KEY,
        name TEXT,
        diagnosis TEXT,
        address TEXT,
        emergencyContact TEXT,
        photoUrl TEXT,
        medicalNotes TEXT,
        lastSync TEXT
      )
    ''');

    // Pending sync operations
    await db.execute('''
      CREATE TABLE pending_sync (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        data TEXT,
        timestamp TEXT
      )
    ''');
  }

  // Shift operations
  Future<void> saveShiftLocally(Shift shift) async {
    final db = await database;
    await db.insert(
      'shifts',
      {
        'id': shift.id,
        'caregiverId': shift.caregiverId,
        'clientId': shift.clientId,
        'startTime': shift.startTime.toIso8601String(),
        'endTime': shift.endTime.toIso8601String(),
        'status': shift.status,
        'actualStartTime': shift.actualStartTime?.toIso8601String(),
        'actualEndTime': shift.actualEndTime?.toIso8601String(),
        'notes': shift.notes,
        'lastSync': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Shift>> getLocalShifts(String caregiverId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shifts',
      where: 'caregiverId = ?',
      whereArgs: [caregiverId],
    );

    return List.generate(maps.length, (i) {
      return Shift(
        id: maps[i]['id'],
        caregiverId: maps[i]['caregiverId'],
        clientId: maps[i]['clientId'],
        startTime: DateTime.parse(maps[i]['startTime']),
        endTime: DateTime.parse(maps[i]['endTime']),
        status: maps[i]['status'],
        actualStartTime: maps[i]['actualStartTime'] != null ? DateTime.parse(maps[i]['actualStartTime']) : null,
        actualEndTime: maps[i]['actualEndTime'] != null ? DateTime.parse(maps[i]['actualEndTime']) : null,
        notes: maps[i]['notes'],
      );
    });
  }

  Future<List<Shift>> getLocalShiftsForClient(String clientId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shifts',
      where: 'clientId = ?',
      whereArgs: [clientId],
    );

    return List.generate(maps.length, (i) {
      return Shift(
        id: maps[i]['id'],
        caregiverId: maps[i]['caregiverId'],
        clientId: maps[i]['clientId'],
        startTime: DateTime.parse(maps[i]['startTime']),
        endTime: DateTime.parse(maps[i]['endTime']),
        status: maps[i]['status'],
        actualStartTime: maps[i]['actualStartTime'] != null ? DateTime.parse(maps[i]['actualStartTime']) : null,
        actualEndTime: maps[i]['actualEndTime'] != null ? DateTime.parse(maps[i]['actualEndTime']) : null,
        notes: maps[i]['notes'],
      );
    });
  }

  // Incident operations
  Future<void> saveIncidentLocally(Incident incident) async {
    final db = await database;
    await db.insert(
      'incidents',
      {
        'id': incident.id,
        'caregiverId': incident.caregiverId,
        'incidentType': incident.incidentType,
        'description': incident.description,
        'dateTime': incident.dateTime.toIso8601String(),
        'involvedParties': incident.involvedParties,
        'actionsTaken': incident.actionsTaken,
        'status': incident.status,
        'photoUrls': incident.photoUrls?.join(','),
        'lastSync': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Incident>> getLocalIncidents(String caregiverId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'incidents',
      where: 'caregiverId = ?',
      whereArgs: [caregiverId],
    );

    return List.generate(maps.length, (i) {
      return Incident(
        id: maps[i]['id'],
        caregiverId: maps[i]['caregiverId'],
        incidentType: maps[i]['incidentType'],
        description: maps[i]['description'],
        dateTime: DateTime.parse(maps[i]['dateTime']),
        involvedParties: maps[i]['involvedParties'],
        actionsTaken: maps[i]['actionsTaken'],
        status: maps[i]['status'],
        photoUrls: maps[i]['photoUrls']?.split(','),
      );
    });
  }

  // Client operations
  Future<void> saveClientLocally(Client client) async {
    final db = await database;
    await db.insert(
      'clients',
      {
        'id': client.id,
        'name': client.name,
        'diagnosis': client.diagnosis,
        'address': client.address,
        'emergencyContact': client.emergencyContact,
        'photoUrl': client.photoUrl,
        'medicalNotes': client.medicalNotes,
        'lastSync': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Client>> getLocalClients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('clients');

    return List.generate(maps.length, (i) {
      return Client(
        id: maps[i]['id'],
        name: maps[i]['name'],
        diagnosis: maps[i]['diagnosis'],
        address: maps[i]['address'],
        emergencyContact: maps[i]['emergencyContact'],
        photoUrl: maps[i]['photoUrl'],
        medicalNotes: maps[i]['medicalNotes'],
      );
    });
  }

  // Pending sync operations
  Future<void> addPendingSync(String type, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('pending_sync', {
      'type': type,
      'data': data.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSync() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pending_sync');
    return maps;
  }

  Future<void> removePendingSync(int id) async {
    final db = await database;
    await db.delete('pending_sync', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateLocalShift(String shiftId, Map<String, dynamic> updates) async {
    final db = await database;
    await db.update(
      'shifts',
      updates,
      where: 'id = ?',
      whereArgs: [shiftId],
    );
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('shifts');
    await db.delete('incidents');
    await db.delete('clients');
    await db.delete('pending_sync');
  }
}
