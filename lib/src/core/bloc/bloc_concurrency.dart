import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocConcurrency {
  BlocConcurrency._();

  ///
  /// process only the latest event and cancel previous event handlers
  ///
  static EventTransformer<Event> blocRestartable<Event>() => restartable<Event>();

  ///
  /// process events concurrently
  ///
  static EventTransformer<Event> blocConcurrent<Event>() => concurrent<Event>();

  ///
  /// process events sequentially
  ///
  static EventTransformer<Event> blocSequential<Event>() => sequential<Event>();

  ///
  /// ignore any events added while an event is processing
  ///
  static EventTransformer<Event> blocDroppable<Event>() => droppable<Event>();
}
