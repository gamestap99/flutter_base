/// LRU Cache with TTL support
/// Part of BLoC Pro VIP Architecture
library;

import 'dart:collection';

/// Abstract cache entry with expiration support
abstract class CacheEntry {
  DateTime get createdAt;
  Duration get ttl;

  bool get isExpired => DateTime.now().difference(createdAt) > ttl;
  
  Duration get remainingTtl {
    final elapsed = DateTime.now().difference(createdAt);
    final remaining = ttl - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

/// Generic cache entry implementation
class CacheEntryImpl<T> extends CacheEntry {
  final T data;
  @override
  final DateTime createdAt;
  @override
  final Duration ttl;

  CacheEntryImpl({
    required this.data,
    required this.ttl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheEntryImpl<T> &&
          data == other.data &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(data, createdAt);
}

/// LRU Cache với TTL support
/// Automatically evicts least recently used items when at capacity
/// and expired items on access
class LRUCache<K, V> {
  final int maxSize;
  final Duration defaultTtl;
  final LinkedHashMap<K, _CacheItem<V>> _cache = LinkedHashMap();

  /// Callback when item is evicted
  final void Function(K key, V value)? onEvict;

  LRUCache({
    required this.maxSize,
    this.defaultTtl = const Duration(minutes: 5),
    this.onEvict,
  }) : assert(maxSize > 0, 'maxSize must be positive');

  /// Get item from cache
  /// Returns null if not found or expired
  V? get(K key) {
    final item = _cache[key];
    if (item == null) return null;

    // Check if expired
    if (item.isExpired) {
      _remove(key, item.value);
      return null;
    }

    // Move to end (most recently used)
    _cache.remove(key);
    _cache[key] = item;
    return item.value;
  }

  /// Put item in cache with optional custom TTL
  void put(K key, V value, {Duration? ttl}) {
    // Remove existing if present
    final existing = _cache.remove(key);
    if (existing != null) {
      onEvict?.call(key, existing.value);
    }

    // Evict oldest if at capacity
    while (_cache.length >= maxSize) {
      final oldestKey = _cache.keys.first;
      final oldestValue = _cache.remove(oldestKey);
      if (oldestValue != null) {
        onEvict?.call(oldestKey, oldestValue.value);
      }
    }

    _cache[key] = _CacheItem(
      value: value,
      createdAt: DateTime.now(),
      ttl: ttl ?? defaultTtl,
    );
  }

  /// Remove item from cache
  V? remove(K key) {
    final item = _cache.remove(key);
    if (item != null) {
      onEvict?.call(key, item.value);
      return item.value;
    }
    return null;
  }

  void _remove(K key, V value) {
    _cache.remove(key);
    onEvict?.call(key, value);
  }

  /// Clear all items from cache
  void clear() {
    if (onEvict != null) {
      _cache.forEach((key, item) => onEvict!(key, item.value));
    }
    _cache.clear();
  }

  /// Remove all expired items
  void evictExpired() {
    final expiredKeys = <K>[];
    _cache.forEach((key, item) {
      if (item.isExpired) expiredKeys.add(key);
    });
    for (final key in expiredKeys) {
      final item = _cache.remove(key);
      if (item != null) {
        onEvict?.call(key, item.value);
      }
    }
  }

  /// Check if key exists and is not expired
  bool containsKey(K key) {
    final item = _cache[key];
    if (item == null) return false;
    if (item.isExpired) {
      _remove(key, item.value);
      return false;
    }
    return true;
  }

  /// Get current cache size
  int get size => _cache.length;

  /// Check if cache is empty
  bool get isEmpty => _cache.isEmpty;

  /// Check if cache is not empty
  bool get isNotEmpty => _cache.isNotEmpty;

  /// Get all valid (non-expired) keys
  List<K> get keys {
    evictExpired();
    return _cache.keys.toList();
  }

  /// Get all valid (non-expired) values
  List<V> get values {
    evictExpired();
    return _cache.values.map((item) => item.value).toList();
  }

  /// Get or create pattern
  /// If key exists and not expired, return cached value
  /// Otherwise, call creator, cache the result, and return it
  Future<V> getOrCreate(K key, Future<V> Function() creator, {Duration? ttl}) async {
    final cached = get(key);
    if (cached != null) return cached;

    final value = await creator();
    put(key, value, ttl: ttl);
    return value;
  }

  /// Sync version of getOrCreate
  V getOrCreateSync(K key, V Function() creator, {Duration? ttl}) {
    final cached = get(key);
    if (cached != null) return cached;

    final value = creator();
    put(key, value, ttl: ttl);
    return value;
  }

  /// Invalidate items matching predicate
  void invalidateWhere(bool Function(K key, V value) predicate) {
    final keysToRemove = <K>[];
    _cache.forEach((key, item) {
      if (predicate(key, item.value)) {
        keysToRemove.add(key);
      }
    });
    for (final key in keysToRemove) {
      remove(key);
    }
  }

  /// Update item if exists
  bool update(K key, V Function(V current) updater) {
    final item = _cache[key];
    if (item == null || item.isExpired) return false;

    final newValue = updater(item.value);
    _cache[key] = _CacheItem(
      value: newValue,
      createdAt: item.createdAt,
      ttl: item.ttl,
    );
    return true;
  }
}

/// Internal cache item
class _CacheItem<V> {
  final V value;
  final DateTime createdAt;
  final Duration ttl;

  const _CacheItem({
    required this.value,
    required this.createdAt,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(createdAt) > ttl;
}

/// List-specific cache entry for pagination
class ListCacheEntry<T> extends CacheEntry {
  final List<T> items;
  final bool hasMore;
  final dynamic meta;
  @override
  final DateTime createdAt;
  @override
  final Duration ttl;

  ListCacheEntry({
    required this.items,
    this.hasMore = false,
    this.meta,
    DateTime? createdAt,
    this.ttl = const Duration(minutes: 5),
  }) : createdAt = createdAt ?? DateTime.now();

  ListCacheEntry<T> copyWith({
    List<T>? items,
    bool? hasMore,
    dynamic meta,
  }) {
    return ListCacheEntry<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      meta: meta ?? this.meta,
      createdAt: createdAt,
      ttl: ttl,
    );
  }
}
