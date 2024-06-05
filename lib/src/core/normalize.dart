

class Normalize {
  Normalize._();

  static T? initJsonMap<T>(Map<String, dynamic> json, dynamic key, {T? Function(Map<String, dynamic>)? fn}) {
    key = _key(json, key);

    if (key is List) {
      return null;
    }

    return (json.containsKey(key) && json[key] is Map && (json[key] as Map).keys.isNotEmpty)
        ? fn == null
            ? json[key]
            : fn(json[key])
        : null;
  }

  static List<T>? initJsonList<T>(Map<String, dynamic> json, dynamic key, {List<T>? Function(List)? fn}) {
    key = _key(json, key);

    if (key is List) {
      return null;
    }

    return (json.containsKey(key) && json[key] is List && (json[key] as List).isNotEmpty)
        ? fn == null
            ? json[key]
            : fn(json[key])
        : null;
  }

  static String? initJsonString(Map<String, dynamic> json, dynamic key) {
    key = _key(json, key);

    if (key is List) {
      return null;
    }

    return json.containsKey(key) && (json[key] is String || json[key] is num) && json[key].toString().isNotEmpty
        ? json[key] is num
            ? json[key].toString()
            : json[key]
        : null;
  }

  static bool? initJsonBool(Map<String, dynamic> json, dynamic key) {
    key = _key(json, key);

    if (key is List) {
      return null;
    }

    return json.containsKey(key) && (json[key] is String || json[key] is num || json[key] is bool)
        ? json[key] is num
            ? json[key] == 1
            : json[key] is String
                ? json[key] == '1' || json[key] == 'true'
                : json[key]
        : null;
  }

  static num? initJsonNum(Map<String, dynamic> json, dynamic key) {
    key = _key(json, key);

    if (key is List) {
      return null;
    }

    return json.containsKey(key) && (json[key] is String || json[key] is num) && json[key].toString().isNotEmpty
        ? json[key] is String
            ? num.parse(json[key])
            : json[key]
        : null;
  }

  static int? initJsonInt(Map<String, dynamic> json, dynamic key) {
    key = _key(json, key);

    if (key is List) {
      return null;
    }

    return json.containsKey(key) && (json[key] is String || json[key] is num) && json[key].toString().isNotEmpty
        ? json[key] is String
            ? int.parse(json[key])
            : json[key]
        : null;
  }

  static double? initJsonDouble(Map<String, dynamic> json, dynamic key) {
    key = _key(json, key);

    if (key is List) {
      return null;
    }

    return json.containsKey(key) && (json[key] is String || json[key] is num) && json[key].toString().isNotEmpty ? double.parse(json[key].toString()) : null;
  }

  static dynamic _key(Map<String, dynamic> json, dynamic key) {
    if (key is List) {
      for (var element in key) {
        if (json.containsKey(element)) {
          return element as String;
        }
      }
    }

    return key;
  }

  static Map<String, dynamic> viaDataToCallAPI(Map<String, dynamic> data) {
    Map<String, dynamic> rs = {};

    for (var entry in data.entries) {
      if (entry.value == null || (entry.value is String && (entry.value as String).isEmpty)) {
        continue;
      }

      rs[entry.key] = entry.value;
    }

    return rs;
  }
}
