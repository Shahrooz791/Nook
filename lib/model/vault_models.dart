// Plain Dart data classes for the vault layer.
// No Flutter imports — pure data, fully serialisable to/from SQFlite maps.

class VaultPhoto {
  final int? id;
  final String encryptedPath;
  final String? originalPath;
  final String addedAt;

  const VaultPhoto({
    this.id,
    required this.encryptedPath,
    this.originalPath,
    required this.addedAt,
  });

  factory VaultPhoto.fromMap(Map<String, dynamic> m) => VaultPhoto(
        id: m['id'] as int?,
        encryptedPath: m['encrypted_path'] as String,
        originalPath: m['original_path'] as String?,
        addedAt: m['added_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'encrypted_path': encryptedPath,
        if (originalPath != null) 'original_path': originalPath,
        'added_at': addedAt,
      };
}

// ---------------------------------------------------------------------------

class VaultVideo {
  final int? id;
  final String encryptedPath;
  final String? originalPath;
  final String? thumbEncryptedPath;
  final int durationSeconds;
  final String addedAt;

  const VaultVideo({
    this.id,
    required this.encryptedPath,
    this.originalPath,
    this.thumbEncryptedPath,
    this.durationSeconds = 0,
    required this.addedAt,
  });

  factory VaultVideo.fromMap(Map<String, dynamic> m) => VaultVideo(
        id: m['id'] as int?,
        encryptedPath: m['encrypted_path'] as String,
        originalPath: m['original_path'] as String?,
        thumbEncryptedPath: m['thumb_encrypted_path'] as String?,
        durationSeconds: (m['duration_seconds'] as int?) ?? 0,
        addedAt: m['added_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'encrypted_path': encryptedPath,
        if (originalPath != null) 'original_path': originalPath,
        'thumb_encrypted_path': thumbEncryptedPath,
        'duration_seconds': durationSeconds,
        'added_at': addedAt,
      };

  String get durationDisplay {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------

class VaultFile {
  final int? id;
  final String originalName;
  final String encryptedPath;
  final int fileSize;
  final String addedAt;

  const VaultFile({
    this.id,
    required this.originalName,
    required this.encryptedPath,
    required this.fileSize,
    required this.addedAt,
  });

  factory VaultFile.fromMap(Map<String, dynamic> m) => VaultFile(
        id: m['id'] as int?,
        originalName: m['original_name'] as String,
        encryptedPath: m['encrypted_path'] as String,
        fileSize: (m['file_size'] as int?) ?? 0,
        addedAt: m['added_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'original_name': originalName,
        'encrypted_path': encryptedPath,
        'file_size': fileSize,
        'added_at': addedAt,
      };

  String get fileSizeDisplay {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get extension => originalName.contains('.')
      ? originalName.split('.').last.toUpperCase()
      : 'FILE';
}

// ---------------------------------------------------------------------------

class VaultNote {
  final int? id;
  final String titleEncrypted;
  final String bodyEncrypted;
  final String updatedAt;

  const VaultNote({
    this.id,
    required this.titleEncrypted,
    required this.bodyEncrypted,
    required this.updatedAt,
  });

  factory VaultNote.fromMap(Map<String, dynamic> m) => VaultNote(
        id: m['id'] as int?,
        titleEncrypted: m['title_encrypted'] as String,
        bodyEncrypted: m['body_encrypted'] as String,
        updatedAt: m['updated_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title_encrypted': titleEncrypted,
        'body_encrypted': bodyEncrypted,
        'updated_at': updatedAt,
      };
}

// ---------------------------------------------------------------------------

class VaultPassword {
  final int? id;
  final String title; // stored plain — it's just the site/app name
  final String usernameEncrypted;
  final String passwordEncrypted;
  final String notesEncrypted;
  final String updatedAt;

  const VaultPassword({
    this.id,
    required this.title,
    required this.usernameEncrypted,
    required this.passwordEncrypted,
    required this.notesEncrypted,
    required this.updatedAt,
  });

  factory VaultPassword.fromMap(Map<String, dynamic> m) => VaultPassword(
        id: m['id'] as int?,
        title: m['title'] as String,
        usernameEncrypted: m['username_encrypted'] as String,
        passwordEncrypted: m['password_encrypted'] as String,
        notesEncrypted: m['notes_encrypted'] as String,
        updatedAt: m['updated_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'username_encrypted': usernameEncrypted,
        'password_encrypted': passwordEncrypted,
        'notes_encrypted': notesEncrypted,
        'updated_at': updatedAt,
      };
}
