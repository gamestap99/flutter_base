/// BLoC Pro Observer for logging and analytics
/// Part of BLoC Pro VIP Architecture
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../console.dart';

/// Custom BLoC observer với logging và analytics hooks
class BlocProObserver extends BlocObserver {
  /// Callback for transitions
  final void Function(BlocBase bloc, Transition transition)? onTransitionCallback;

  /// Callback for errors
  final void Function(BlocBase bloc, Object error, StackTrace stackTrace)? onErrorCallback;

  /// Callback for events
  final void Function(Bloc bloc, Object? event)? onEventCallback;

  /// Callback for state changes
  final void Function(BlocBase bloc, Change change)? onChangeCallback;

  /// Enable console logging
  final bool enableLogging;

  /// Log level filter
  final BlocLogLevel logLevel;

  BlocProObserver({
    this.onTransitionCallback,
    this.onErrorCallback,
    this.onEventCallback,
    this.onChangeCallback,
    this.enableLogging = true,
    this.logLevel = BlocLogLevel.info,
  });

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (enableLogging && logLevel.index >= BlocLogLevel.verbose.index) {
      AppConsole.log('🆕 [${bloc.runtimeType}] Created');
    }
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (enableLogging && logLevel.index >= BlocLogLevel.debug.index) {
      AppConsole.log('📤 [${bloc.runtimeType}] Event: ${event.runtimeType}');
    }
    onEventCallback?.call(bloc, event);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (enableLogging && logLevel.index >= BlocLogLevel.verbose.index) {
      AppConsole.log(
        '🔄 [${bloc.runtimeType}] Change:\n'
        '   Current: ${change.currentState.runtimeType}\n'
        '   Next: ${change.nextState.runtimeType}',
      );
    }
    onChangeCallback?.call(bloc, change);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (enableLogging && logLevel.index >= BlocLogLevel.info.index) {
      AppConsole.log(
        '🔀 [${bloc.runtimeType}] Transition:\n'
        '   Event: ${transition.event.runtimeType}\n'
        '   ${transition.currentState.runtimeType} → ${transition.nextState.runtimeType}',
      );
    }
    onTransitionCallback?.call(bloc, transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (enableLogging) {
      AppConsole.log(
        '❌ [${bloc.runtimeType}] Error: $error\n'
        '   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}',
      );
    }
    onErrorCallback?.call(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if (enableLogging && logLevel.index >= BlocLogLevel.verbose.index) {
      AppConsole.log('🗑️ [${bloc.runtimeType}] Closed');
    }
  }
}

/// Log level for BLoC observer
enum BlocLogLevel {
  /// No logging
  none,

  /// Only errors
  error,

  /// Errors and important transitions
  info,

  /// Errors, transitions, and events
  debug,

  /// Everything including create/close
  verbose,
}

/// Analytics events for List operations
sealed class ListAnalyticsEvent {
  const ListAnalyticsEvent();

  factory ListAnalyticsEvent.cacheHit(String key) = ListCacheHitEvent;
  factory ListAnalyticsEvent.cacheMiss(String key) = ListCacheMissEvent;
  factory ListAnalyticsEvent.loadSuccess(int itemCount) = ListLoadSuccessEvent;
  factory ListAnalyticsEvent.loadError(Object failure) = ListLoadErrorEvent;
  factory ListAnalyticsEvent.loadMore(int page) = ListLoadMoreEvent;
  factory ListAnalyticsEvent.refresh() = ListRefreshEvent;
  factory ListAnalyticsEvent.deleteSuccess() = ListDeleteSuccessEvent;
  factory ListAnalyticsEvent.deleteError(Object failure) = ListDeleteErrorEvent;
  factory ListAnalyticsEvent.retry(int attempt) = ListRetryEvent;
}

class ListCacheHitEvent extends ListAnalyticsEvent {
  final String key;
  const ListCacheHitEvent(this.key);
}

class ListCacheMissEvent extends ListAnalyticsEvent {
  final String key;
  const ListCacheMissEvent(this.key);
}

class ListLoadSuccessEvent extends ListAnalyticsEvent {
  final int itemCount;
  const ListLoadSuccessEvent(this.itemCount);
}

class ListLoadErrorEvent extends ListAnalyticsEvent {
  final Object failure;
  const ListLoadErrorEvent(this.failure);
}

class ListLoadMoreEvent extends ListAnalyticsEvent {
  final int page;
  const ListLoadMoreEvent(this.page);
}

class ListRefreshEvent extends ListAnalyticsEvent {
  const ListRefreshEvent();
}

class ListDeleteSuccessEvent extends ListAnalyticsEvent {
  const ListDeleteSuccessEvent();
}

class ListDeleteErrorEvent extends ListAnalyticsEvent {
  final Object failure;
  const ListDeleteErrorEvent(this.failure);
}

class ListRetryEvent extends ListAnalyticsEvent {
  final int attempt;
  const ListRetryEvent(this.attempt);
}

/// Analytics events for Item operations
sealed class ItemAnalyticsEvent {
  const ItemAnalyticsEvent();

  factory ItemAnalyticsEvent.loadSuccess() = ItemLoadSuccessEvent;
  factory ItemAnalyticsEvent.loadError(Object failure) = ItemLoadErrorEvent;
  factory ItemAnalyticsEvent.updateSuccess() = ItemUpdateSuccessEvent;
  factory ItemAnalyticsEvent.updateError(Object failure) = ItemUpdateErrorEvent;
  factory ItemAnalyticsEvent.optimisticUpdate() = ItemOptimisticUpdateEvent;
  factory ItemAnalyticsEvent.rollback() = ItemRollbackEvent;
}

class ItemLoadSuccessEvent extends ItemAnalyticsEvent {
  const ItemLoadSuccessEvent();
}

class ItemLoadErrorEvent extends ItemAnalyticsEvent {
  final Object failure;
  const ItemLoadErrorEvent(this.failure);
}

class ItemUpdateSuccessEvent extends ItemAnalyticsEvent {
  const ItemUpdateSuccessEvent();
}

class ItemUpdateErrorEvent extends ItemAnalyticsEvent {
  final Object failure;
  const ItemUpdateErrorEvent(this.failure);
}

class ItemOptimisticUpdateEvent extends ItemAnalyticsEvent {
  const ItemOptimisticUpdateEvent();
}

class ItemRollbackEvent extends ItemAnalyticsEvent {
  const ItemRollbackEvent();
}

/// Analytics events for Form operations
sealed class FormAnalyticsEvent {
  const FormAnalyticsEvent();

  factory FormAnalyticsEvent.fieldChanged(String field) = FormFieldChangedEvent;
  factory FormAnalyticsEvent.submitSuccess() = FormSubmitSuccessEvent;
  factory FormAnalyticsEvent.submitError(Object failure) = FormSubmitErrorEvent;
  factory FormAnalyticsEvent.validationError(Map<String, String> errors) = FormValidationErrorEvent;
  factory FormAnalyticsEvent.autoSaved() = FormAutoSavedEvent;
  factory FormAnalyticsEvent.draftLoaded() = FormDraftLoadedEvent;
}

class FormFieldChangedEvent extends FormAnalyticsEvent {
  final String field;
  const FormFieldChangedEvent(this.field);
}

class FormSubmitSuccessEvent extends FormAnalyticsEvent {
  const FormSubmitSuccessEvent();
}

class FormSubmitErrorEvent extends FormAnalyticsEvent {
  final Object failure;
  const FormSubmitErrorEvent(this.failure);
}

class FormValidationErrorEvent extends FormAnalyticsEvent {
  final Map<String, String> errors;
  const FormValidationErrorEvent(this.errors);
}

class FormAutoSavedEvent extends FormAnalyticsEvent {
  const FormAutoSavedEvent();
}

class FormDraftLoadedEvent extends FormAnalyticsEvent {
  const FormDraftLoadedEvent();
}
