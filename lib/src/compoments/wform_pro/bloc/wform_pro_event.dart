/// WFormPro Events
/// Part of BLoC Pro VIP Architecture
library;

import 'package:equatable/equatable.dart';

/// Base event for form operations
sealed class WFormProEvent extends Equatable {
  const WFormProEvent();
}

/// Field value changed
class FormFieldChanged extends WFormProEvent {
  final String field;
  final dynamic value;

  /// Validate immediately or wait for blur
  final bool validateOnChange;

  const FormFieldChanged({
    required this.field,
    required this.value,
    this.validateOnChange = false,
  });

  @override
  List<Object?> get props => [field, value, validateOnChange];
}

/// Multiple fields changed
class FormFieldsChanged extends WFormProEvent {
  final Map<String, dynamic> values;

  const FormFieldsChanged({required this.values});

  @override
  List<Object?> get props => [values];
}

/// Field lost focus (blur)
class FormFieldBlurred extends WFormProEvent {
  final String field;

  const FormFieldBlurred({required this.field});

  @override
  List<Object?> get props => [field];
}

/// Validate specific field
class FormValidateField extends WFormProEvent {
  final String field;

  const FormValidateField({required this.field});

  @override
  List<Object?> get props => [field];
}

/// Validate all fields
class FormValidate extends WFormProEvent {
  const FormValidate();

  @override
  List<Object?> get props => [];
}

/// Submit form
class FormSubmit extends WFormProEvent {
  /// Skip validation before submit
  final bool skipValidation;

  /// Show loading dialog
  final bool showDialog;

  const FormSubmit({
    this.skipValidation = false,
    this.showDialog = false,
  });

  @override
  List<Object?> get props => [skipValidation, showDialog];
}

/// Reset form to initial values
class FormReset extends WFormProEvent {
  const FormReset();

  @override
  List<Object?> get props => [];
}

/// Set initial values
class FormSetValues extends WFormProEvent {
  final Map<String, dynamic> values;

  /// Keep existing field states
  final bool keepFieldStates;

  const FormSetValues({
    required this.values,
    this.keepFieldStates = false,
  });

  @override
  List<Object?> get props => [values, keepFieldStates];
}

/// Auto save trigger
class FormAutoSave extends WFormProEvent {
  const FormAutoSave();

  @override
  List<Object?> get props => [];
}

/// Load saved draft
class FormLoadDraft extends WFormProEvent {
  const FormLoadDraft();

  @override
  List<Object?> get props => [];
}

/// Clear draft
class FormClearDraft extends WFormProEvent {
  const FormClearDraft();

  @override
  List<Object?> get props => [];
}

/// Set field error manually
class FormSetFieldError extends WFormProEvent {
  final String field;
  final String? error;

  const FormSetFieldError({
    required this.field,
    this.error,
  });

  @override
  List<Object?> get props => [field, error];
}

/// Set server errors
class FormSetServerErrors extends WFormProEvent {
  final Map<String, List<String>> errors;

  const FormSetServerErrors({required this.errors});

  @override
  List<Object?> get props => [errors];
}

/// Clear dependent fields when parent changes
class FormClearDependentFields extends WFormProEvent {
  final String parentField;

  const FormClearDependentFields({required this.parentField});

  @override
  List<Object?> get props => [parentField];
}
