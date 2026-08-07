import 'dart:collection';
import 'dart:typed_data';

/// In-memory LRU cache for decrypted vault media bytes (thumbnails & photos).
class VaultMediaCache {
  VaultMediaCache._();
  static final VaultMediaCache instance = VaultMediaCache._();

  // Max entries to keep in memory
  static const int _maxThumbEntries = 100;
  static const int _maxFullResEntries = 20;

  final LinkedHashMap<String, Uint8List> _thumbCache = LinkedHashMap();
  final LinkedHashMap<String, Uint8List> _fullResCache = LinkedHashMap();

  Uint8List? getThumb(String key) {
    if (!_thumbCache.containsKey(key)) return null;
    final val = _thumbCache.remove(key)!;
    _thumbCache[key] = val; // Move to end (most recently used)
    return val;
  }

  void putThumb(String key, Uint8List bytes) {
    if (_thumbCache.containsKey(key)) {
      _thumbCache.remove(key);
    } else if (_thumbCache.length >= _maxThumbEntries) {
      _thumbCache.remove(_thumbCache.keys.first); // Evict LRU
    }
    _thumbCache[key] = bytes;
  }

  Uint8List? getFullRes(String key) {
    if (!_fullResCache.containsKey(key)) return null;
    final val = _fullResCache.remove(key)!;
    _fullResCache[key] = val;
    return val;
  }

  void putFullRes(String key, Uint8List bytes) {
    if (_fullResCache.containsKey(key)) {
      _fullResCache.remove(key);
    } else if (_fullResCache.length >= _maxFullResEntries) {
      _fullResCache.remove(_fullResCache.keys.first);
    }
    _fullResCache[key] = bytes;
  }

  void remove(String key) {
    _thumbCache.remove(key);
    _fullResCache.remove(key);
  }

  void clear() {
    _thumbCache.clear();
    _fullResCache.clear();
  }
}
