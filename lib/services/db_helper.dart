// file: db_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            email TEXT,
            password TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE bookings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            gorName TEXT,
            location TEXT,
            date TEXT,
            time TEXT,
            price TEXT,
            image TEXT,
            rating TEXT,
            facility TEXT,
            note TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE lapangan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            location TEXT,
            price TEXT,
            rating REAL,
            image TEXT,
            facility TEXT,
            isBooked  INTEGER DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          final columns = await db.rawQuery('PRAGMA table_info(lapangan)');
          final hasFacility = columns.any((col) => col['name'] == 'facility');
          if (!hasFacility) {
            await db.execute('ALTER TABLE lapangan ADD COLUMN facility TEXT');
          }

          final bookingCols = await db.rawQuery('PRAGMA table_info(bookings)');
          Future<void> addColumnIfNotExists(String colName, String type) async {
            if (!bookingCols.any((col) => col['name'] == colName)) {
              await db.execute('ALTER TABLE bookings ADD COLUMN $colName $type');
            }
          }

          await addColumnIfNotExists('image', 'TEXT');
          await addColumnIfNotExists('rating', 'TEXT');
          await addColumnIfNotExists('facility', 'TEXT');
          await addColumnIfNotExists('note', 'TEXT');
        }
      },
    );
  }

  Future<void> registerUser(String username, String email, String password) async {
    final db = await database;
    await db.insert('users', {
      'username': username,
      'email': email,
      'password': password,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await database;
    final result = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> insertLapangan(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('lapangan', data);
  }

  Future<List<Map<String, dynamic>>> getAllLapangan() async {
    final db = await database;
    return await db.query('lapangan');
  }

  Future<List<Map<String, dynamic>>> getAllLapanganBelumDibooking() async {
    final db = await database;
    return await db.query('lapangan', where: 'isBooked = ?', whereArgs: [0]);
  }

  Future<void> updateLapanganBookingStatus(int id, int status) async {
    final db = await database;
    await db.update('lapangan', {'isBooked': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteLapangan(int id) async {
    final db = await database;
    await db.delete('lapangan', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateLapangan(int id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('lapangan', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addBooking({
    required String gorName,
    required String location,
    required String date,
    required String time,
    required String price,
    String image = '',
    String rating = '4.5',
    String facility = '',
    String note = '',
  }) async {
    final db = await database;
    await db.insert('bookings', {
      'gorName': gorName,
      'location': location,
      'date': date,
      'time': time,
      'price': price,
      'image': image,
      'rating': rating,
      'facility': facility,
      'note': note,
    });
  }

  Future<List<Map<String, dynamic>>> getBookings() async {
    final db = await database;
    return await db.query('bookings', orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> getJoinedBookings() async {
    final db = await database;
    return await db.query('lapangan', where: 'isBooked = ?', whereArgs: [1], orderBy: 'id DESC');
  }

  Future<void> deleteBooking(int id) async {
    final db = await database;
    final booking = await db.query('bookings', where: 'id = ?', whereArgs: [id], limit: 1);
    if (booking.isNotEmpty) {
      final gorName = booking.first['gorName'];
      await db.update('lapangan', {'isBooked': 0}, where: 'name = ?', whereArgs: [gorName]);
    }
    await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateBooking(int id, String newDate, String newTime) async {
    final db = await database;
    await db.update('bookings', {
      'date': newDate,
      'time': newTime,
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateBookingAndLapangan({
    required int id,
    required String gorName,
    required String location,
    required String date,
    required String time,
    required String facility,
  }) async {
    final db = await database;

    await db.update('bookings', {
      'gorName': gorName,
      'location': location,
      'date': date,
      'time': time,
      'facility': facility,
    }, where: 'id = ?', whereArgs: [id]);

    await db.update('lapangan', {
      'name': gorName,
      'location': location,
      'facility': facility,
    }, where: 'name = ?', whereArgs: [gorName]);
  }
}