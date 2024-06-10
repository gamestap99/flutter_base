import 'package:dio/dio.dart';

import '../utils.dart';

typedef DioBaseCallBack = Function(Dio dio);

class DioBase {
  final Dio dio;

  const DioBase._(this.dio);

  factory DioBase() {
    final dio = Dio();
    return DioBase._(dio);
  }

  void updateDio(DioBaseCallBack callBack) {
    callBack(dio);
  }

  void updateConfigs({
    BaseOptions? options,
    List<Interceptor>? interceptors,
  }) {
    if (options != null) dio.options = options;
    if (interceptors != null && interceptors.isNotEmpty) dio.interceptors.addAll(interceptors);
  }

  Future<Response<T>> request<T>(
    RequestMethod method,
    String url, {
    data,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return dio.request(
      url,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: Options(
        method: method.value,
        headers: headers,
      ),
      onReceiveProgress: onReceiveProgress,
      onSendProgress: onSendProgress,
    );
  }

  Future<Response<T>> fetch<T>(RequestOptions requestOptions) {
    return dio.fetch(requestOptions);
  }
}

enum RequestMethod {
  get,
  head,
  post,
  put,
  delete,
  connect,
  options,
  trace,
  patch,
}

extension RequestMethodX on RequestMethod {
  String get value => getEnumValue(this).toUpperCase();
}
