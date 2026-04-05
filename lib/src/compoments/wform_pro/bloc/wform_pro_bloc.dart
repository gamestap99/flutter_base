/// WFormPro BLoC - Form management with Pro features
/// Part of BLoC Pro VIP Architecture
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/bloc_pro_observer.dart';
import '../../../core/failure/failure.dart';
import '../../../core/repository/repository.dart';
import '../../../core/result/result.dart';
import '../../../utils/util_loading.dart';
import 'wform_pro_event.dart';
import 'wform_pro_state.dart';

/// Async validator interface
abstract class AsyncValidator {
  /// Validate value and return error message or null if valid
  Future<String?> validate(dynamic value, Map<String, dynamic> allValues);
}

/// Sync validator function type
typedef SyncValidator = String? Function(dynamic value, Map<String, dynamic> allValues);

/// WFormProBloc with advanced features:
/// - Async validation with debounce
/// - Field dependencies
/// - Auto-save draft
/// - Per-field state tracking
/// - Analytics hooks
class WFormProBloc<T> extends Bloc<WFormProEvent, WFormProState<T>> {
  /// Repository for form submission
  final FormRepository<T>? repository;

  /// Legacy API function (for backward compatibility)
  final Future<Result<T>> Function(Map<String, dynamic> values)? legacyApi;

  /// Form key for Flutter form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  /// Sync validators per field
  final Map<String, List<SyncValidator>> syncValidators;

  /// Async validators per field
  final Map<String, AsyncValidator> asyncValidators;

  /// Field dependencies (when parent changes, clear children)
  final Map<String, List<String>> fieldDependencies;

  /// Auto-save debounce duration
  final Duration autoSaveDebounce;

  /// Enable auto-save
  final bool enableAutoSave;

  /// Async validation debounce
  final Duration validationDebounce;

  /// Analytics callback
  final void Function(FormAnalyticsEvent)? onAnalytics;

  /// Callback after successful submit
  final void Function(Map<String, dynamic> values)? onSubmitSuccess;

  /// Timer for auto-save
  Timer? _autoSaveTimer;

  /// Timers for async validation debounce (per field)
  final Map<String, Timer> _validationTimers = {};

  /// Initial values (for reset)
  Map<String, dynamic> _initialValues = {};

  WFormProBloc({
    this.repository,
    this.legacyApi,
    this.syncValidators = const {},
    this.asyncValidators = const {},
    this.fieldDependencies = const {},
    this.autoSaveDebounce = const Duration(seconds: 30),
    this.enableAutoSave = false,
    this.validationDebounce = const Duration(milliseconds: 500),
    this.onAnalytics,
    this.onSubmitSuccess,
    Map<String, dynamic>? initialValues,
  }) : super(WFormProState<T>(values: initialValues ?? const {})) {
    _initialValues = Map.from(initialValues ?? {});

    on<FormFieldChanged>(_onFieldChanged);
    on<FormFieldsChanged>(_onFieldsChanged);
    on<FormFieldBlurred>(_onFieldBlurred);
    on<FormValidateField>(_onValidateField);
    on<FormValidate>(_onValidate);
    on<FormSubmit>(_onSubmit);
    on<FormReset>(_onReset);
    on<FormSetValues>(_onSetValues);
    on<FormAutoSave>(_onAutoSave);
    on<FormLoadDraft>(_onLoadDraft);
    on<FormClearDraft>(_onClearDraft);
    on<FormSetFieldError>(_onSetFieldError);
    on<FormSetServerErrors>(_onSetServerErrors);
    on<FormClearDependentFields>(_onClearDependentFields);
  }

  /// Handle field changed
  Future<void> _onFieldChanged(
    FormFieldChanged event,
    Emitter<WFormProState<T>> emit,
  ) async {
    emit(state.updateValue(event.field, event.value));
    onAnalytics?.call(FormAnalyticsEvent.fieldChanged(event.field));

    // Clear dependent fields
    final dependents = fieldDependencies[event.field];
    if (dependents != null && dependents.isNotEmpty) {
      final newValues = Map<String, dynamic>.from(state.values);
      final newFieldStates = Map<String, FieldState>.from(state.fieldStates);

      for (final dependent in dependents) {
        newValues.remove(dependent);
        newFieldStates.remove(dependent);
      }

      emit(state.copyWith(values: newValues, fieldStates: newFieldStates));
    }

    // Sync validation on change
    if (event.validateOnChange) {
      _runSyncValidation(event.field, event.value, emit);
    }

    // Debounced async validation
    if (asyncValidators.containsKey(event.field)) {
      _scheduleAsyncValidation(event.field, event.value);
    }

    // Schedule auto-save
    if (enableAutoSave) {
      _scheduleAutoSave();
    }
  }

  /// Handle multiple fields changed
  void _onFieldsChanged(
    FormFieldsChanged event,
    Emitter<WFormProState<T>> emit,
  ) {
    emit(state.updateValues(event.values));

    if (enableAutoSave) {
      _scheduleAutoSave();
    }
  }

  /// Handle field blurred
  Future<void> _onFieldBlurred(
    FormFieldBlurred event,
    Emitter<WFormProState<T>> emit,
  ) async {
    // Mark field as touched
    emit(state.touchField(event.field));

    // Run sync validation
    final value = state.values[event.field];
    _runSyncValidation(event.field, value, emit);

    // Run async validation immediately (no debounce)
    if (asyncValidators.containsKey(event.field)) {
      await _runAsyncValidation(event.field, value, emit);
    }
  }

  /// Handle validate single field
  Future<void> _onValidateField(
    FormValidateField event,
    Emitter<WFormProState<T>> emit,
  ) async {
    final value = state.values[event.field];
    _runSyncValidation(event.field, value, emit);

    if (asyncValidators.containsKey(event.field)) {
      await _runAsyncValidation(event.field, value, emit);
    }
  }

  /// Handle validate all
  Future<void> _onValidate(
    FormValidate event,
    Emitter<WFormProState<T>> emit,
  ) async {
    emit(state.copyWith(status: FormStatus.validating));

    // Run sync validation for all fields with validators
    for (final field in syncValidators.keys) {
      final value = state.values[field];
      _runSyncValidation(field, value, emit);
    }

    // Run async validation for all fields with async validators
    for (final field in asyncValidators.keys) {
      final value = state.values[field];
      await _runAsyncValidation(field, value, emit);
    }

    // Also validate using Flutter form
    _formKey.currentState?.validate();

    final newStatus = state.isValid ? FormStatus.dirty : FormStatus.error;
    emit(state.copyWith(status: newStatus));
  }

  /// Handle submit
  Future<void> _onSubmit(
    FormSubmit event,
    Emitter<WFormProState<T>> emit,
  ) async {
    // Validate first (unless skipped)
    if (!event.skipValidation) {
      final isFormValid = _formKey.currentState?.validate() ?? false;
      if (!isFormValid) {
        onAnalytics?.call(FormAnalyticsEvent.validationError(state.allErrors));
        return;
      }

      // Also check async validation
      if (!state.isValid) {
        onAnalytics?.call(FormAnalyticsEvent.validationError(state.allErrors));
        return;
      }
    }

    emit(state.copyWith(status: FormStatus.submitting, clearFailure: true));

    if (event.showDialog) {
      UtilLoading.instance.showLoading();
    }

    // Submit via repository or legacy API
    final Result<T> result;
    if (repository != null) {
      result = await repository!.submit(state.values);
    } else if (legacyApi != null) {
      result = await legacyApi!(state.values);
    } else {
      // No API, just call callback
      onSubmitSuccess?.call(state.values);
      emit(state.copyWith(
        status: FormStatus.success,
        hasUnsavedChanges: false,
      ));
      onAnalytics?.call(FormAnalyticsEvent.submitSuccess());

      if (event.showDialog) {
        UtilLoading.instance.showSuccess();
        UtilLoading.instance.hide();
      }
      return;
    }

    result.when(
      success: (data) {
        emit(state.copyWith(
          status: FormStatus.success,
          result: data,
          hasUnsavedChanges: false,
        ));
        onSubmitSuccess?.call(state.values);
        onAnalytics?.call(FormAnalyticsEvent.submitSuccess());

        if (event.showDialog) {
          UtilLoading.instance.showSuccess();
        }

        // Clear draft on success
        repository?.clearDraft();
      },
      failure: (failure) {
        emit(state.copyWith(
          status: FormStatus.error,
          failure: failure,
        ));

        // Set server validation errors
        if (failure is ValidationFailure) {
          emit(state.setServerErrors(failure.fieldErrors));
        }

        onAnalytics?.call(FormAnalyticsEvent.submitError(failure));

        if (event.showDialog) {
          UtilLoading.instance.showError(content: failure.message);
        }
      },
    );

    if (event.showDialog) {
      UtilLoading.instance.hide();
    }
  }

  /// Handle reset
  void _onReset(FormReset event, Emitter<WFormProState<T>> emit) {
    emit(WFormProState<T>(values: Map.from(_initialValues)));
    _formKey.currentState?.reset();

    // Clear draft
    repository?.clearDraft();
  }

  /// Handle set values
  void _onSetValues(FormSetValues event, Emitter<WFormProState<T>> emit) {
    if (event.keepFieldStates) {
      emit(state.copyWith(values: event.values));
    } else {
      emit(WFormProState<T>(values: event.values));
    }
    _initialValues = Map.from(event.values);
  }

  /// Handle auto-save
  Future<void> _onAutoSave(
    FormAutoSave event,
    Emitter<WFormProState<T>> emit,
  ) async {
    if (!state.hasUnsavedChanges) return;

    final result = await repository?.saveDraft(state.values);
    if (result?.isSuccess ?? false) {
      emit(state.copyWith(
        lastAutoSaved: DateTime.now(),
        hasUnsavedChanges: false,
      ));
      onAnalytics?.call(FormAnalyticsEvent.autoSaved());
    }
  }

  /// Handle load draft
  Future<void> _onLoadDraft(
    FormLoadDraft event,
    Emitter<WFormProState<T>> emit,
  ) async {
    final result = await repository?.loadDraft();
    result?.whenSuccess((draft) {
      if (draft != null && draft.isNotEmpty) {
        emit(state.copyWith(values: draft));
        onAnalytics?.call(FormAnalyticsEvent.draftLoaded());
      }
    });
  }

  /// Handle clear draft
  Future<void> _onClearDraft(
    FormClearDraft event,
    Emitter<WFormProState<T>> emit,
  ) async {
    await repository?.clearDraft();
  }

  /// Handle set field error
  void _onSetFieldError(
    FormSetFieldError event,
    Emitter<WFormProState<T>> emit,
  ) {
    emit(state.setFieldError(event.field, event.error));
  }

  /// Handle set server errors
  void _onSetServerErrors(
    FormSetServerErrors event,
    Emitter<WFormProState<T>> emit,
  ) {
    emit(state.setServerErrors(event.errors));
  }

  /// Handle clear dependent fields
  void _onClearDependentFields(
    FormClearDependentFields event,
    Emitter<WFormProState<T>> emit,
  ) {
    final dependents = fieldDependencies[event.parentField];
    if (dependents == null || dependents.isEmpty) return;

    final newValues = Map<String, dynamic>.from(state.values);
    final newFieldStates = Map<String, FieldState>.from(state.fieldStates);

    for (final dependent in dependents) {
      newValues.remove(dependent);
      newFieldStates.remove(dependent);
    }

    emit(state.copyWith(values: newValues, fieldStates: newFieldStates));
  }

  // ========== Private Helpers ==========

  void _runSyncValidation(
    String field,
    dynamic value,
    Emitter<WFormProState<T>> emit,
  ) {
    final validators = syncValidators[field];
    if (validators == null || validators.isEmpty) return;

    String? error;
    for (final validator in validators) {
      error = validator(value, state.values);
      if (error != null) break;
    }

    emit(state.setFieldError(field, error));
  }

  Future<void> _runAsyncValidation(
    String field,
    dynamic value,
    Emitter<WFormProState<T>> emit,
  ) async {
    final validator = asyncValidators[field];
    if (validator == null) return;

    // Set validating state
    final newFieldStates = Map<String, FieldState>.from(state.fieldStates);
    newFieldStates[field] = state.getFieldState(field).copyWith(isValidating: true);
    emit(state.copyWith(fieldStates: newFieldStates));

    // Run validation
    final error = await validator.validate(value, state.values);

    // Update error
    final updatedFieldStates = Map<String, FieldState>.from(state.fieldStates);
    updatedFieldStates[field] = state.getFieldState(field).copyWith(
      isValidating: false,
      error: error,
    );
    emit(state.copyWith(fieldStates: updatedFieldStates));
  }

  void _scheduleAsyncValidation(String field, dynamic value) {
    _validationTimers[field]?.cancel();
    _validationTimers[field] = Timer(validationDebounce, () {
      add(FormValidateField(field: field));
    });
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(autoSaveDebounce, () {
      add(const FormAutoSave());
    });
  }

  // ========== Public Helper Methods ==========

  /// Get current form values
  Map<String, dynamic> get values => Map.from(state.values);

  /// Get value for specific field
  dynamic getValue(String field) => state.values[field];

  /// Set value for specific field
  void setValue(String field, dynamic value, {bool validateOnChange = false}) {
    add(FormFieldChanged(
      field: field,
      value: value,
      validateOnChange: validateOnChange,
    ));
  }

  /// Set multiple values
  void setValues(Map<String, dynamic> values) {
    add(FormFieldsChanged(values: values));
  }

  /// Mark field as blurred
  void blurField(String field) {
    add(FormFieldBlurred(field: field));
  }

  /// Validate form
  bool validate() {
    add(const FormValidate());
    return _formKey.currentState?.validate() ?? false;
  }

  /// Submit form
  void submit({bool skipValidation = false, bool showDialog = false}) {
    add(FormSubmit(skipValidation: skipValidation, showDialog: showDialog));
  }

  /// Reset form
  void reset() {
    add(const FormReset());
  }

  /// Load draft
  void loadDraft() {
    add(const FormLoadDraft());
  }

  /// Get values if valid
  Map<String, dynamic>? getValuesIfValid() {
    if (_formKey.currentState?.validate() ?? false) {
      return values;
    }
    return null;
  }

  @override
  Future<void> close() {
    _autoSaveTimer?.cancel();
    for (final timer in _validationTimers.values) {
      timer.cancel();
    }
    return super.close();
  }
}
