/// BaseItemPro Widget - Item widget with Pro features
/// Part of BLoC Pro VIP Architecture
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_base/flutter_base.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



/// Widget for displaying single item with BaseItemProBloc
class BaseItemProWidget<T, F> extends StatefulWidget {
  /// Filter/ID for loading item
  final F? queryParameters;

  /// Build loaded content
  final List<Widget> Function(T item, BaseItemProState<T> state) buildLoadedSlivers;

  /// Custom loaded builder (replaces sliver layout)
  final Widget Function(T item, Future<void> Function() onRefresh)? buildCustomLoaded;

  /// Build loading state
  final Widget Function()? buildLoading;

  /// Build empty state
  final Widget Function(BaseItemProState<T> state)? buildEmpty;

  /// Build error state
  final Widget Function(Failure failure, VoidCallback retry)? buildError;

  /// Sliver app bar
  final SliverAppBar? sliverAppBar;

  /// Auto refresh when parameters change
  final bool autoRefresh;

  const BaseItemProWidget({
    super.key,
    this.queryParameters,
    required this.buildLoadedSlivers,
    this.buildCustomLoaded,
    this.buildLoading,
    this.buildEmpty,
    this.buildError,
    this.sliverAppBar,
    this.autoRefresh = true,
  });

  @override
  State<BaseItemProWidget<T, F>> createState() => _BaseItemProWidgetState<T, F>();
}

class _BaseItemProWidgetState<T, F> extends State<BaseItemProWidget<T, F>> {
  late final BaseItemProBloc<T, F> bloc;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    bloc = context.read<BaseItemProBloc<T, F>>();

    // Load data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && bloc.state.isInitial) {
        bloc.load(filter: widget.queryParameters);
      }
    });
  }

  @override
  void didUpdateWidget(covariant BaseItemProWidget<T, F> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoRefresh && widget.queryParameters != oldWidget.queryParameters) {
      bloc.load(filter: widget.queryParameters, forceRefresh: true);
    }
  }

  Future<void> _onRefresh() async {
    bloc.refresh(filter: widget.queryParameters, force: true);
    await bloc.stream.firstWhere((state) => !state.isRefreshing && !state.isLoading);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BaseItemProBloc<T, F>, BaseItemProState<T>>(
      builder: (context, state) {
        return switch (state) {
          ItemInitial() => _buildLoading(),
          ItemLoading(:final previousItem) => previousItem != null
              ? _buildLoaded(previousItem)
              : _buildLoading(),
          ItemLoaded(:final item) => _buildLoaded(item),
          ItemError(:final failure, :final previousItem) =>
            previousItem != null ? _buildLoaded(previousItem) : _buildError(failure),
        };
      },
    );
  }

  Widget _buildLoading() {
    if (widget.buildLoading != null) {
      return Center(child: widget.buildLoading!());
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildLoaded(T item) {
    if (widget.buildCustomLoaded != null) {
      return widget.buildCustomLoaded!(item, _onRefresh);
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _onRefresh,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          if (widget.sliverAppBar != null) widget.sliverAppBar!,
          ...widget.buildLoadedSlivers(item, bloc.state),
        ],
      ),
    );
  }

  Widget _buildError(Failure failure) {
    if (widget.buildError != null) {
      return widget.buildError!(failure, () => bloc.retry());
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: AppErrorWidget(
              error: failure.message,
              onRefresh: () async {
                bloc.retry();
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Child widget for nested item state access
class BaseItemProChildWidget<T, F> extends StatelessWidget {
  final Widget Function(BaseItemProState<T> state)? buildLoading;
  final Widget Function(ItemLoaded<T> state) buildSuccess;
  final Widget Function(ItemError<T> state)? buildError;

  const BaseItemProChildWidget({
    super.key,
    this.buildLoading,
    required this.buildSuccess,
    this.buildError,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BaseItemProBloc<T, F>, BaseItemProState<T>>(
      builder: (context, state) {
        return switch (state) {
          ItemInitial() || ItemLoading() =>
            buildLoading?.call(state) ?? const SizedBox.shrink(),
          ItemLoaded() => buildSuccess(state),
          ItemError() => buildError?.call(state) ?? const SizedBox.shrink(),
        };
      },
    );
  }
}

/// Selector widget for specific state changes
class BaseItemProSelector<T, F, S> extends StatelessWidget {
  final S Function(BaseItemProState<T> state) selector;
  final Widget Function(S selected) builder;

  const BaseItemProSelector({
    super.key,
    required this.selector,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<BaseItemProBloc<T, F>, BaseItemProState<T>, S>(
      selector: selector,
      builder: (context, selected) => builder(selected),
    );
  }
}
