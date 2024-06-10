import '../../../core/bloc/bloc_base_state.dart';
import '../../../core/dio/network_exceptions.dart';

class WFormState extends BlocBaseState {
  final Map<String, dynamic> values;
  final Map<String, dynamic> errors;

  final dynamic result;

  const WFormState({
    this.values = const {},
    this.errors = const {},
    this.result,
    EBlocStateStatus status = EBlocStateStatus.idle,
    NetworkException? exception,
  }) : super(
          status: status,
          exception: exception,
        );

  WFormState copyWith({
    Map<String, dynamic>? values,
    Map<String, dynamic>? errors,
    result,
    EBlocStateStatus? status,
    NetworkException? exception,
  }) {
    return WFormState(
      values: values ?? this.values,
      errors: errors ?? this.errors,
      result: result ?? this.result,
      status: status ?? this.status,
      exception: exception ?? this.exception,
    );
  }

  @override
  List<Object?> get props => [
        values,
        errors,
        status,
        result,
        exception,
      ];
}
