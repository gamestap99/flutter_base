import 'dart:io';

import 'package:dio/dio.dart';

enum NetworkException {
  none,
  requestCancelled,
  unauthorisedRequest,
  badRequest,
  notFound,
  methodNotAllowed,
  notAcceptable,
  requestTimeout,
  sendTimeout,
  conflict,
  internalServerError,
  notImplemented,
  serviceUnavailable,
  noInternetConnection,
  formatException,
  unableToProcess,
  defaultError,
  unexpectedError,
  badCertificate,
}

class NetworkExceptions {
  static NetworkExceptions instance = NetworkExceptions._internal(NetworkException.none);

  NetworkExceptions._internal(this.networkException);

  factory NetworkExceptions() => instance;

  final NetworkException networkException;

  factory NetworkExceptions.getDioException(error) {
    NetworkExceptions networkExceptions = NetworkExceptions._internal(NetworkException.defaultError);

    if (error is Exception) {
      try {
        if (error is DioException) {
          switch (error.type) {
            case DioExceptionType.cancel:
              networkExceptions = NetworkExceptions._internal(NetworkException.requestCancelled);

              break;
            case DioExceptionType.connectionTimeout:
              networkExceptions = NetworkExceptions._internal(NetworkException.requestTimeout);

              break;
            case DioExceptionType.unknown:
              networkExceptions = NetworkExceptions._internal(NetworkException.noInternetConnection);

              break;
            case DioExceptionType.receiveTimeout:
              networkExceptions = NetworkExceptions._internal(NetworkException.sendTimeout);

              break;
            case DioExceptionType.badResponse:
              switch (error.response!.statusCode) {
                case 400:
                  networkExceptions = NetworkExceptions._internal(NetworkException.unauthorisedRequest);
                  break;
                case 401:
                  networkExceptions = NetworkExceptions._internal(NetworkException.unauthorisedRequest);
                  break;
                case 403:
                  networkExceptions = NetworkExceptions._internal(NetworkException.unauthorisedRequest);
                  break;
                case 404:
                  networkExceptions = NetworkExceptions._internal(NetworkException.notFound);
                  break;
                case 409:
                  networkExceptions = NetworkExceptions._internal(NetworkException.conflict);
                  break;
                case 408:
                  networkExceptions = NetworkExceptions._internal(NetworkException.requestTimeout);
                  break;
                case 500:
                  networkExceptions = NetworkExceptions._internal(NetworkException.internalServerError);
                  break;
                case 503:
                  networkExceptions = NetworkExceptions._internal(NetworkException.serviceUnavailable);
                  break;
                default:
                  networkExceptions = NetworkExceptions._internal(NetworkException.defaultError);
              }

              break;
            case DioExceptionType.sendTimeout:
              networkExceptions = NetworkExceptions._internal(NetworkException.sendTimeout);

              break;
            case DioExceptionType.badCertificate:
              networkExceptions = NetworkExceptions._internal(NetworkException.badCertificate);
              break;
            case DioExceptionType.connectionError:
              networkExceptions = NetworkExceptions._internal(NetworkException.noInternetConnection);
              break;
          }
        } else if (error is SocketException) {
          networkExceptions = NetworkExceptions._internal(NetworkException.noInternetConnection);
        } else {
          networkExceptions = NetworkExceptions._internal(NetworkException.unexpectedError);
        }
      } on FormatException catch (_) {
        networkExceptions = NetworkExceptions._internal(NetworkException.formatException);
      } catch (_) {
        networkExceptions = NetworkExceptions._internal(NetworkException.unexpectedError);
      }
    } else {
      if (error.toString().contains("is not a subtype of")) {
        networkExceptions = NetworkExceptions._internal(NetworkException.unableToProcess);
      } else {
        networkExceptions = NetworkExceptions._internal(NetworkException.unexpectedError);
      }
    }

    return networkExceptions;
  }
}
