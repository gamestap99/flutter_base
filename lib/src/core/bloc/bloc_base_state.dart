import 'package:equatable/equatable.dart';
import 'package:flutter_base/flutter_base.dart';

import '../dio/network_exceptions.dart';

abstract class BlocBaseState extends Equatable {
  final EBlocStateStatus status;
  final dynamic error;
  final NetworkException? exception;

  const BlocBaseState({
    required this.status,
    this.error,
    this.exception,
  });
}
