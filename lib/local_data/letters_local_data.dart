import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:nook/model/letter_model.dart';

/// Only place in the app allowed to touch SQFlite directly.
/// Controllers call into this — screens never do.
class LettersLocalData {
  LettersLocalData._();

  static final LettersLocalData instance = LettersLocalData._();

  static Database? _db;

  Future<Database> get _database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nook.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE letters (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            created_at TEXT NOT NULL,
            unlock_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<LetterModel>> getAllLetters() async {
    final db = await _database;
    final rows = await db.query('letters', orderBy: 'created_at DESC');
    return rows.map(LetterModel.fromMap).toList();
  }

  Future<LetterModel?> getLetterById(int id) async {
    final db = await _database;
    final rows = await db.query('letters', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return LetterModel.fromMap(rows.first);
  }

  Future<int> insertLetter(LetterModel letter) async {
    final db = await _database;
    return db.insert('letters', letter.toMap());
  }

  Future<void> deleteLetter(int id) async {
    final db = await _database;
    await db.delete('letters', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateLetter(LetterModel letter) async {
    if (letter.id == null) return;
    final db = await _database;
    await db.update(
      'letters',
      letter.toMap(),
      where: 'id = ?',
      whereArgs: [letter.id],
    );
  }
}
