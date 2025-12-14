/// WFormPro State
/// Part of BLoC Pro VIP Architecture
library;

import 'package:equatable/equatable.dart';
import '../../../core/failure/failure.dart';

/// Form status enum
enum FormStatus {
  /// Initial state
  initial,

  /// User has made changes
  dirty,

  /// Async validation in progress
  validating,

  /// Submitting to server
  submitting,

  /// Submit succeeded
  success,

  /// Submit failed
  error,
}

/// Per-field state
class FieldState extends Equatable {
  /// Field has been modified
  final bool isDirty;

  /// Field has been touched (blurred)
  final bool isTouched;

  /// Async validation in progress
  final bool isValidating;

  /// Validation error
  final String? error;

  /// Server errors from API
  final List<String>? serverErrors;

  const FieldState({
    this.isDirty = false,
    this.isTouched = false,
    this.isValidating = false,
    this.error,
    this.serverErrors,
  });

  /// Check if field has any error
  bool get hasError => error != null || (serverErrors?.isNotEmpty ?? false);

  /// Get first error
  String? get firstError {
    if (error != null) return error;
    if (serverErrors?.isNotEmpty ?? false) return serverErrors!.first;
    return null;
  }

  FieldState copyWith({
    bool? isDirty,
    bool? isTouched,
    bool? isValidating,
    String? error,
    List<String>? serverErrors,
    bool clearError = false,
    bool clearServerErrors = false,
  }) {
    return FieldState(
      isDirty: isDirty ?? this.isDirty,
      isTouched: isTouched ?? this.isTouched,
      isValidating: isValidating ?? this.isValidating,
      error: clearError ? null : (error ?? this.error),
      serverErrors: clearServerErrors ? null : (serverErrors ?? this.serverErrors),
    );
  }

  @override
  List<Object?> get props => [isDirty, isTouched, isValidating, error, serverErrors];
}

/// Form state
class WFormProState<T> extends Equatable {
  /// Form values
  final Map<String, dynamic> values;

  /// Per-field states
  final Map<String, FieldState> fieldStates;

  /// Form status
  final FormStatus status;

  /// Submit result
  final T? result;

  /// Submit failure
  final Failure? failure;

  /// Last auto-saved time
  final DateTime? lastAutoSaved;

  /// Has unsaved changes
  final bool hasUnsavedChanges;

  const WFormProState({
    this.values = const {},
    this.fieldStates = const {},
    this.status = FormStatus.initial,
    this.result,
    this.failure,
    this.lastAutoSaved,
    this.hasUnsavedChanges = false,
  });

  /// Check if form is valid (no errors in any field)
  bool get isValid {
    return !fieldStates.values.any((field) => field.hasError);
  }

  /// Check if form is dirty
  bool get isDirty => fieldStates.values.any((field) => field.isDirty);

  /// Check if any field is validating
  bool get isValidating => fieldStates.values.any((field) => field.isValidating);

  /// Check if form is submitting
  bool get isSubmitting => status == FormStatus.submitting;

  /// Check if submit succeeded
  bool get isSuccess => status == FormStatus.success;

  /// Check if submit failed
  bool get isError => status == FormStatus.error;

  /// Get field value
  dynamic getValue(String field) => values[field];

  /// Get field state
  FieldState getFieldState(String field) =>
      fieldStates[field] ?? const FieldState();

  /// Get field error
  String? getFieldError(String field) => getFieldState(field).firstError;

  /// Check if field has error
  bool hasFieldError(String field) => getFieldState(field).hasError;

  /// Get all errors as map
  Map<String, String> get allErrors {
    final errors = <String, String>{};
    fieldStates.forEach((field, state) {
      if (state.firstError != null) {
        errors[field] = state.firstError!;
      }
    });
    return errors;
  }

  WFormProState<T> copyWith({
    Map<String, dynamic>? values,
    Map<String, FieldState>? fieldStates,
    FormStatus? status,
    T? result,
    Failure? failure,
    DateTime? lastAutoSaved,
    bool? hasUnsavedChanges,
    bool clearResult = false,
    bool clearFailure = false,
  }) {
    return WFormProState<T>(
      values: values ?? this.values,
      fieldStates: fieldStates ?? this.fieldStates,
      status: status ?? this.status,
      result: clearResult ? null : (result ?? this.result),
      failure: clearFailure ? null : (failure ?? this.failure),
      lastAutoSaved: lastAutoSaved ?? this.lastAutoSaved,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }

  @override
  List<Object?> get props => [
        values,
        fieldStates,
        status,
        result,
        failure,
        lastAutoSaved,
        hasUnsavedChanges,
      ];
}

/// Extension for convenient state access
extension WFormProStateX<T> on WFormProState<T> {
  /// Update single field value
  WFormProState<T> updateValue(String field, dynamic value) {
    final newValues = Map<String, dynamic>.from(values);
    newValues[field] = value;

    final newFieldStates = Map<String, FieldState>.from(fieldStates);
    newFieldStates[field] = getFieldState(field).copyWith(
      isDirty: true,
      clearError: true,
      clearServerErrors: true,
    );

    return copyWith(
      values: newValues,
      fieldStates: newFieldStates,
      status: FormStatus.dirty,
      hasUnsavedChanges: true,
    );
  }

  /// Update multiple field values
  WFormProState<T> updateValues(Map<String, dynamic> updates) {
    final newValues = Map<String, dynamic>.from(values);
    final newFieldStates = Map<String, FieldState>.from(fieldStates);

    updates.forEach((field, value) {
      newValues[field] = value;
      newFieldStates[field] = getFieldState(field).copyWith(
        isDirty: true,
        clearError: true,
        clearServerErrors: true,
      );
    });

    return copyWith(
      values: newValues,
      fieldStates: newFieldStates,
      status: FormStatus.dirty,
      hasUnsavedChanges: true,
    );
  }

  /// Set field error
  WFormProState<T> setFieldError(String field, String? error) {
    final newFieldStates = Map<String, FieldState>.from(fieldStates);
    newFieldStates[field] = getFieldState(field).copyWith(error: error);
    return copyWith(fieldStates: newFieldStates);
  }

  /// Set multiple field errors (from server)
  WFormProState<T> setServerErrors(Map<String, List<String>> errors) {
    final newFieldStates = Map<String, FieldState>.from(fieldStates);
    errors.forEach((field, fieldErrors) {
      newFieldStates[field] = getFieldState(field).copyWith(
        serverErrors: fieldErrors,
      );
    });
    return copyWith(fieldStates: newFieldStates);
  }

  /// Mark field as touched
  WFormProState<T> touchField(String field) {
    final newFieldStates = Map<String, FieldState>.from(fieldStates);
    newFieldStates[field] = getFieldState(field).copyWith(isTouched: true);
    return copyWith(fieldStates: newFieldStates);
  }

  /// Clear all field errors
  WFormProState<T> clearErrors() {
    final newFieldStates = fieldStates.map(
      (field, state) => MapEntry(
        field,
        state.copyWith(clearError: true, clearServerErrors: true),
      ),
    );
    return copyWith(fieldStates: newFieldStates);
  }
}
