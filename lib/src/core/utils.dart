import 'dart:convert';
import 'dart:io';

String getEnumValue(e) => e.toString().split('.').last;

// Future<bool> isConnectInternetAccessServer() async {
//   var connectivityResult = await (Connectivity().checkConnectivity());
//
//   if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
//     try {
//       final result = await InternetAddress.lookup("google.com");
//
//       return (result.isNotEmpty && result[0].rawAddress.isNotEmpty);
//     } catch (ex) {
//       return false;
//     }
//   } else {
//     return false;
//   }
// }

class CUtils {
  static String base64Encode(dynamic str) {
    if (str is Map || str is List) {
      str = jsonEncode(str);
    }

    final bytes = utf8.encode(str);
    final base64Str = base64.encode(bytes);

    return base64Str;
  }

  static String base64Decode(String str) {
    final decodedBytes = base64.decode(str);
    final decodedStr = utf8.decode(decodedBytes);

    return decodedStr;
  }

  static bool isBase64(String str) {
    // Regular expression for validating Base64 string
    RegExp base64Regex = RegExp(r'^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$');

    return base64Regex.hasMatch(str);
  }
}

enum EPathCdnGs {
  si("si"),
  sv("sv"),
  sp("sp");

  final String value;

  const EPathCdnGs(this.value);
}

T? getValueMap<T>(dynamic map, List<dynamic> keys) {
  if (keys.isEmpty) return null;

  dynamic repeat = map;
  if (map is Map) {
    for (var key in keys) {
      if (repeat.containsKey(key)) {
        repeat = repeat[key];
      } else {
        return null;
      }
    }

    return repeat;
  }

  return null;
}

String stringToUUID(String value, {String join = '-'}) {
  List<int> rds = [20, 16, 12, 8];
  String uuid = value;

  for (var rd in rds) {
    uuid = uuid.substring(0, rd) + join + uuid.substring(rd);
  }

  return uuid;
}

List<List<T>> chunkList<T>(List<T> list, int chunkSize) {
  List<List<T>> chunks = [];
  for (var i = 0; i < list.length; i += chunkSize) {
    if (i + chunkSize <= list.length) {
      chunks.add(list.sublist(i, i + chunkSize));
    } else {
      chunks.add(list.sublist(i));
    }
  }
  return chunks;
}

dynamic tryJsonDecode(String source, {dynamic df, Object? Function(Object?, Object?)? reviver}) {
  try {
    return jsonDecode(source, reviver: reviver);
  } catch (e) {
    return df;
  }
}
