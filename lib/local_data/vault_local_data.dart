import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:get/get.dart';

import 'package:nook/local_data/vault_encryption.dart';
import 'package:nook/model/vault_models.dart';

/// Only place allowed to touch vault SQFlite tables and encrypted file storage.
/// Uses a separate [vault.db] to avoid version-migration conflicts with [nook.db].
/// Controllers call into this; screens never do.
class VaultLocalData {
  VaultLocalData._();
  static final VaultLocalData instance = VaultLocalData._();

  static Database? _db;

  Future<Database> get _database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'vault.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE vault_photos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            encrypted_path TEXT NOT NULL,
            original_path TEXT,
            added_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE vault_videos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            encrypted_path TEXT NOT NULL,
            original_path TEXT,
            thumb_encrypted_path TEXT,
            duration_seconds INTEGER NOT NULL DEFAULT 0,
            added_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE vault_files (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            original_name TEXT NOT NULL,
            encrypted_path TEXT NOT NULL,
            file_size INTEGER NOT NULL DEFAULT 0,
            added_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE vault_notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title_encrypted TEXT NOT NULL,
            body_encrypted TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE vault_passwords (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            username_encrypted TEXT NOT NULL,
            password_encrypted TEXT NOT NULL,
            notes_encrypted TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE vault_photos ADD COLUMN original_path TEXT');
          await db.execute('ALTER TABLE vault_videos ADD COLUMN original_path TEXT');
          await db.execute('DROP TABLE IF EXISTS vault_meta');
        }
      },
    );
  }

  // ── Meta ──────────────────────────────────────────────────────────────────

  Future<bool> hasPinSet() => VaultEncryption.instance.hasPinSet();

  // ── Counts (for dashboard) ────────────────────────────────────────────────

  Future<int> countPhotos() async => _count('vault_photos');
  Future<int> countVideos() async => _count('vault_videos');
  Future<int> countFiles() async => _count('vault_files');
  Future<int> countNotes() async => _count('vault_notes');
  Future<int> countPasswords() async => _count('vault_passwords');

  Future<int> _count(String table) async {
    final db = await _database;
    final r = await db.rawQuery('SELECT COUNT(*) as c FROM $table');
    return (r.first['c'] as int?) ?? 0;
  }

  // ── Photos ────────────────────────────────────────────────────────────────

  Future<List<VaultPhoto>> getAllPhotos() async {
    final db = await _database;
    final rows = await db.query('vault_photos', orderBy: 'added_at DESC');
    return rows.map(VaultPhoto.fromMap).toList();
  }

  /// Encrypts [imageBytes], writes an `.enc` file, inserts metadata row.
  Future<VaultPhoto> insertPhoto(Uint8List imageBytes, {String? originalPath}) async {
    final encrypted = await VaultEncryption.instance.encrypt(imageBytes);
    final path = await _writeEncFile(encrypted, 'photos');
    final photo = VaultPhoto(
      encryptedPath: path,
      originalPath: originalPath,
      addedAt: DateTime.now().toIso8601String(),
    );
    final db = await _database;
    final id = await db.insert('vault_photos', photo.toMap());
    
    // Gallery Deletion Logic
    if (originalPath != null) {
      try {
        final List<String> deleted = await PhotoManager.editor.deleteWithIds([originalPath]);
        if (deleted.isEmpty) {
          Get.snackbar(
            'Notice',
            'Saved to vault, but couldn\'t remove the original.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Notice',
          'Saved to vault, but couldn\'t remove the original.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
    
    return VaultPhoto(id: id, encryptedPath: path, originalPath: originalPath, addedAt: photo.addedAt);
  }

  Future<Uint8List> decryptPhoto(VaultPhoto photo) async {
    final raw = await File(photo.encryptedPath).readAsBytes();
    return VaultEncryption.instance.decrypt(raw);
  }

  Future<void> deletePhoto(int id) async {
    final db = await _database;
    final rows = await db.query('vault_photos', where: 'id = ?', whereArgs: [id]);
    if (rows.isNotEmpty) {
      final f = File(rows.first['encrypted_path'] as String);
      if (await f.exists()) await f.delete();
    }
    await db.delete('vault_photos', where: 'id = ?', whereArgs: [id]);
  }

  // ── Videos ───────────────────────────────────────────────────────────────

  Future<List<VaultVideo>> getAllVideos() async {
    final db = await _database;
    final rows = await db.query('vault_videos', orderBy: 'added_at DESC');
    return rows.map(VaultVideo.fromMap).toList();
  }

  Future<VaultVideo> insertVideo(
    Uint8List videoBytes, {
    String? originalPath,
    int durationSeconds = 0,
  }) async {
    final encrypted = await VaultEncryption.instance.encrypt(videoBytes);
    final path = await _writeEncFile(encrypted, 'videos');
    final video = VaultVideo(
      encryptedPath: path,
      originalPath: originalPath,
      durationSeconds: durationSeconds,
      addedAt: DateTime.now().toIso8601String(),
    );
    final db = await _database;
    final id = await db.insert('vault_videos', video.toMap());
    
    // Gallery Deletion Logic
    if (originalPath != null) {
      try {
        final List<String> deleted = await PhotoManager.editor.deleteWithIds([originalPath]);
        if (deleted.isEmpty) {
          Get.snackbar(
            'Notice',
            'Saved to vault, but couldn\'t remove the original.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Notice',
          'Saved to vault, but couldn\'t remove the original.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }

    return VaultVideo(
      id: id,
      encryptedPath: path,
      originalPath: originalPath,
      durationSeconds: durationSeconds,
      addedAt: video.addedAt,
    );
  }

  Future<Uint8List> decryptVideo(VaultVideo video) async {
    final raw = await File(video.encryptedPath).readAsBytes();
    return VaultEncryption.instance.decrypt(raw);
  }

  Future<void> deleteVideo(int id) async {
    final db = await _database;
    final rows = await db.query('vault_videos', where: 'id = ?', whereArgs: [id]);
    if (rows.isNotEmpty) {
      final f = File(rows.first['encrypted_path'] as String);
      if (await f.exists()) await f.delete();
    }
    await db.delete('vault_videos', where: 'id = ?', whereArgs: [id]);
  }

  // ── Files/Docs ────────────────────────────────────────────────────────────

  Future<List<VaultFile>> getAllFiles() async {
    final db = await _database;
    final rows = await db.query('vault_files', orderBy: 'added_at DESC');
    return rows.map(VaultFile.fromMap).toList();
  }

  Future<VaultFile> insertFile(
    Uint8List fileBytes, {
    required String originalName,
  }) async {
    final encrypted = await VaultEncryption.instance.encrypt(fileBytes);
    final path = await _writeEncFile(encrypted, 'files');
    final vf = VaultFile(
      originalName: originalName,
      encryptedPath: path,
      fileSize: fileBytes.length,
      addedAt: DateTime.now().toIso8601String(),
    );
    final db = await _database;
    final id = await db.insert('vault_files', vf.toMap());
    return VaultFile(
      id: id,
      originalName: originalName,
      encryptedPath: path,
      fileSize: fileBytes.length,
      addedAt: vf.addedAt,
    );
  }

  Future<Uint8List> decryptFile(VaultFile vf) async {
    final raw = await File(vf.encryptedPath).readAsBytes();
    return VaultEncryption.instance.decrypt(raw);
  }

  Future<void> deleteFile(int id) async {
    final db = await _database;
    final rows = await db.query('vault_files', where: 'id = ?', whereArgs: [id]);
    if (rows.isNotEmpty) {
      final f = File(rows.first['encrypted_path'] as String);
      if (await f.exists()) await f.delete();
    }
    await db.delete('vault_files', where: 'id = ?', whereArgs: [id]);
  }

  // ── Notes ─────────────────────────────────────────────────────────────────

  Future<List<VaultNote>> getAllNotes() async {
    final db = await _database;
    final rows = await db.query('vault_notes', orderBy: 'updated_at DESC');
    return rows.map(VaultNote.fromMap).toList();
  }

  Future<VaultNote> insertNote({
    required String titlePlain,
    required String bodyPlain,
  }) async {
    final enc = VaultEncryption.instance;
    final note = VaultNote(
      titleEncrypted: await enc.encryptString(titlePlain),
      bodyEncrypted: await enc.encryptString(bodyPlain),
      updatedAt: DateTime.now().toIso8601String(),
    );
    final db = await _database;
    final id = await db.insert('vault_notes', note.toMap());
    return VaultNote(
      id: id,
      titleEncrypted: note.titleEncrypted,
      bodyEncrypted: note.bodyEncrypted,
      updatedAt: note.updatedAt,
    );
  }

  Future<void> updateNote({
    required int id,
    required String titlePlain,
    required String bodyPlain,
  }) async {
    final enc = VaultEncryption.instance;
    final db = await _database;
    await db.update(
      'vault_notes',
      {
        'title_encrypted': await enc.encryptString(titlePlain),
        'body_encrypted': await enc.encryptString(bodyPlain),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String> decryptNoteTitle(VaultNote note) =>
      VaultEncryption.instance.decryptString(note.titleEncrypted);

  Future<String> decryptNoteBody(VaultNote note) =>
      VaultEncryption.instance.decryptString(note.bodyEncrypted);

  Future<void> deleteNote(int id) async {
    final db = await _database;
    await db.delete('vault_notes', where: 'id = ?', whereArgs: [id]);
  }

  // ── Passwords ─────────────────────────────────────────────────────────────

  Future<List<VaultPassword>> getAllPasswords() async {
    final db = await _database;
    final rows = await db.query('vault_passwords', orderBy: 'updated_at DESC');
    return rows.map(VaultPassword.fromMap).toList();
  }

  Future<VaultPassword> insertPassword({
    required String title,
    required String username,
    required String password,
    String notes = '',
  }) async {
    final enc = VaultEncryption.instance;
    final vp = VaultPassword(
      title: title,
      usernameEncrypted: await enc.encryptString(username),
      passwordEncrypted: await enc.encryptString(password),
      notesEncrypted: await enc.encryptString(notes),
      updatedAt: DateTime.now().toIso8601String(),
    );
    final db = await _database;
    final id = await db.insert('vault_passwords', vp.toMap());
    return VaultPassword(
      id: id,
      title: title,
      usernameEncrypted: vp.usernameEncrypted,
      passwordEncrypted: vp.passwordEncrypted,
      notesEncrypted: vp.notesEncrypted,
      updatedAt: vp.updatedAt,
    );
  }

  Future<void> updatePassword({
    required int id,
    required String title,
    required String username,
    required String password,
    String notes = '',
  }) async {
    final enc = VaultEncryption.instance;
    final db = await _database;
    await db.update(
      'vault_passwords',
      {
        'title': title,
        'username_encrypted': await enc.encryptString(username),
        'password_encrypted': await enc.encryptString(password),
        'notes_encrypted': await enc.encryptString(notes),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String> decryptUsername(VaultPassword vp) =>
      VaultEncryption.instance.decryptString(vp.usernameEncrypted);

  Future<String> decryptPassword(VaultPassword vp) =>
      VaultEncryption.instance.decryptString(vp.passwordEncrypted);

  Future<String> decryptNotes(VaultPassword vp) =>
      VaultEncryption.instance.decryptString(vp.notesEncrypted);

  Future<void> deletePassword(int id) async {
    final db = await _database;
    await db.delete('vault_passwords', where: 'id = ?', whereArgs: [id]);
  }

  // ── Wipe everything ───────────────────────────────────────────────────────

  /// Deletes all vault data: encrypted files, DB rows, AES key, and PIN.
  /// Returns vault to its factory-fresh "no PIN set" state.
  Future<void> wipeAll() async {
    // Delete encrypted files from disk
    final appDir = await getApplicationDocumentsDirectory();
    final vaultDir = Directory(p.join(appDir.path, 'vault_enc'));
    if (await vaultDir.exists()) await vaultDir.delete(recursive: true);

    // Wipe all DB tables
    final db = await _database;
    await db.delete('vault_photos');
    await db.delete('vault_videos');
    await db.delete('vault_files');
    await db.delete('vault_notes');
    await db.delete('vault_passwords');
    await db.update('vault_meta', {'auto_lock_seconds': 60}, where: 'id = 1');

    // Delete secure-storage credentials
    await VaultEncryption.instance.deleteKey();
    await VaultEncryption.instance.deletePin();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<String> _writeEncFile(Uint8List data, String subfolder) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'vault_enc', subfolder));
    await dir.create(recursive: true);
    final filename =
        '${DateTime.now().millisecondsSinceEpoch}_${data.length}.enc';
    final file = File(p.join(dir.path, filename));
    await file.writeAsBytes(data);
    return file.path;
  }
}
