/// Represents a single row of the `letters` table.
/// `isUnlocked` is derived by comparing [unlockAt] to now — never stored.
class LetterModel {
  const LetterModel({
    this.id,
    required this.content,
    required this.createdAt,
    required this.unlockAt,
  });

  final int? id;
  final String content;
  final DateTime createdAt;
  final DateTime unlockAt;

  bool get isUnlocked => !unlockAt.isAfter(DateTime.now());

  /// First line of the letter, used as the card title once unlocked.
  String get previewTitle {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return 'Untitled letter';
    final firstLine = trimmed.split('\n').first;
    return firstLine.length > 42 ? '${firstLine.substring(0, 42)}…' : firstLine;
  }

  /// Full body, left to the UI to clip with maxLines/ellipsis.
  String get previewText => content.trim();

  /// Human countdown used on locked cards, e.g. "12 days".
  String get countdownText {
    final diff = unlockAt.difference(DateTime.now());
    if (diff.inDays >= 1) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'}';
    }
    if (diff.inHours >= 1) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'}';
    }
    if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'}';
    }
    return 'less than a minute';
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'unlock_at': unlockAt.toIso8601String(),
    };
  }

  factory LetterModel.fromMap(Map<String, Object?> map) {
    return LetterModel(
      id: map['id'] as int?,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      unlockAt: DateTime.parse(map['unlock_at'] as String),
    );
  }
}
