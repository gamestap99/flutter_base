/// BaseListPro Widget - List widget with Pro features
/// Part of BLoC Pro VIP Architecture
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_base/flutter_base.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';


/// Widget for displaying list with BaseListProBloc
/// Supports pull-to-refresh, load more, error handling
class BaseListProWidget<T, F> extends StatefulWidget {
  /// Build item widget
  final Widget Function(T item, int index) buildItem;

  /// Build loading skeleton
  final Widget Function()? buildLoading;

  /// Custom loading widget (replaces default)
  final Widget Function()? customBuildLoading;

  /// Build empty state
  final Widget Function()? buildEmpty;

  /// Build error state
  final Widget Function(Failure failure, VoidCallback retry)? buildError;

  /// Build header/top content
  final Widget Function(BaseListProState<T> state)? buildTop;

  /// Custom list builder for complete control
  final Widget Function(BaseListProState<T> state)? customList;

  /// Sliver app bar
  final SliverAppBar Function(BaseListProState<T> state)? sliverAppBar;

  /// Initial filter
  final F? queryParameters;

  /// Auto filter when queryParameters changes
  final bool autoFilter;

  /// Empty message
  final String? emptyText;

  /// Padding
  final EdgeInsetsGeometry padding;

  /// Is grid layout
  final bool isGrid;

  /// Grid cross axis count
  final int crossAxisCount;

  /// Grid spacing
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  /// Number of loading skeletons
  final int loadingCount;

  /// Show divider between items
  final bool showDivider;

  /// Custom divider builder
  final Widget Function(BuildContext context, int index)? buildDivider;

  /// Filter items locally
  final bool Function(T)? filter;

  /// Scroll controller
  final ScrollController? scrollController;

  /// Refresh indicator key callback
  final void Function(GlobalKey<RefreshIndicatorState> key)? initRefreshKey;

  /// Scroll controller callback
  final void Function(ScrollController controller)? onInitScrollController;

  /// Scroll direction listener
  final void Function(bool isForward)? onListenerScroll;

  /// Header builder for custom scroll containers (e.g. NestedScrollView)
  /// Receives list of slivers and returns custom widget
  /// When provided, replaces the default CustomScrollView implementation
  final Widget Function({
    required List<Widget> slivers,
    required ScrollController scrollController,
    required GlobalKey<RefreshIndicatorState> refreshIndicatorKey,
    required Future<void> Function() onRefresh,
  })? headerBuilder;

  const BaseListProWidget({
    super.key,
    required this.buildItem,
    this.buildLoading,
    this.customBuildLoading,
    this.buildEmpty,
    this.buildError,
    this.buildTop,
    this.customList,
    this.sliverAppBar,
    this.queryParameters,
    this.autoFilter = false,
    this.emptyText,
    this.padding = EdgeInsets.zero,
    this.isGrid = false,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
    this.loadingCount = 3,
    this.showDivider = false,
    this.buildDivider,
    this.filter,
    this.scrollController,
    this.initRefreshKey,
    this.onInitScrollController,
    this.onListenerScroll,
    this.headerBuilder,
  });

  @override
  State<BaseListProWidget<T, F>> createState() => _BaseListProWidgetState<T, F>();
}

class _BaseListProWidgetState<T, F> extends State<BaseListProWidget<T, F>> {
  late final BaseListProBloc<T, F> bloc;
  late final ScrollController _scrollController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);

    bloc = context.read<BaseListProBloc<T, F>>();

    // Load data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!bloc.isClosed && bloc.state.isInitial) {
        bloc.load(filter: widget.queryParameters);
      }
    });

    widget.initRefreshKey?.call(_refreshIndicatorKey);
    widget.onInitScrollController?.call(_scrollController);
  }

  @override
  void didUpdateWidget(covariant BaseListProWidget<T, F> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoFilter && widget.queryParameters != oldWidget.queryParameters) {
      bloc.load(filter: widget.queryParameters, forceRefresh: true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      widget.onListenerScroll?.call(false);
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      widget.onListenerScroll?.call(true);
    }
  }

  Future<void> _onRefresh() async {
    bloc.refresh(filter: widget.queryParameters);
    await bloc.stream.firstWhere((state) => !state.isRefreshing);
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0 && mounted) {
      bloc.loadMore(filter: widget.queryParameters);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BaseListProBloc<T, F>, BaseListProState<T>>(
      builder: (context, state) {
        final slivers = <Widget>[
          // App bar
          if (widget.sliverAppBar != null) widget.sliverAppBar!(state),

          // Top content
          if (widget.buildTop != null)
            SliverToBoxAdapter(child: widget.buildTop!(state)),

          // Main content based on state
          _buildContent(state),

          // Load more indicator
          if (state.isLoaded && state.hasMore) _buildLoadMore(state),
        ];

        // Use custom headerBuilder if provided (for NestedScrollView etc.)
        if (widget.headerBuilder != null) {
          return widget.headerBuilder!(
            slivers: slivers,
            scrollController: _scrollController,
            refreshIndicatorKey: _refreshIndicatorKey,
            onRefresh: _onRefresh,
          );
        }

        // Default implementation with RefreshIndicator + CustomScrollView
        return RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _onRefresh,
          child: Scrollbar(
            controller: _scrollController,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: slivers,
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BaseListProState<T> state) {
    return switch (state) {
      ListInitial() => _buildLoading(),
      ListLoading(:final previousItems, :final isRefresh) =>
        previousItems.isEmpty && !isRefresh ? _buildLoading() : _buildItems(previousItems),
      ListLoaded(:final items) => items.isEmpty ? _buildEmpty() : _buildItems(items),
      ListError(:final failure, :final previousItems) =>
        previousItems.isEmpty ? _buildError(failure) : _buildItems(previousItems),
    };
  }

  Widget _buildLoading() {
    if (widget.customBuildLoading != null) {
      return SliverToBoxAdapter(child: widget.customBuildLoading!());
    }

    if (widget.buildLoading == null) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.isGrid) {
      return SliverPadding(
        padding: widget.padding,
        sliver: SliverGrid.count(
          crossAxisCount: widget.crossAxisCount,
          crossAxisSpacing: widget.crossAxisSpacing,
          mainAxisSpacing: widget.mainAxisSpacing,
          children: List.generate(widget.loadingCount, (_) => widget.buildLoading!()),
        ),
      );
    }

    return SliverPadding(
      padding: widget.padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (widget.showDivider && index.isOdd) {
              return widget.buildDivider?.call(context, index) ??
                  const Divider(height: 0, color: Colors.grey);
            }
            return widget.buildLoading!();
          },
          childCount: widget.loadingCount * (widget.showDivider ? 2 : 1) - (widget.showDivider ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildItems(List<T> items) {
    // Apply local filter
    final filteredItems = widget.filter != null
        ? items.where(widget.filter!).toList()
        : items;

    if (filteredItems.isEmpty) {
      return _buildEmpty();
    }

    if (widget.customList != null) {
      return SliverToBoxAdapter(
        child: widget.customList!(
          bloc.state is ListLoaded<T>
              ? bloc.state
              : ListLoaded(items: filteredItems, loadedAt: DateTime.now()),
        ),
      );
    }

    if (widget.isGrid) {
      return SliverPadding(
        padding: widget.padding,
        sliver: SliverGrid.count(
          crossAxisCount: widget.crossAxisCount,
          crossAxisSpacing: widget.crossAxisSpacing,
          mainAxisSpacing: widget.mainAxisSpacing,
          children: filteredItems
              .asMap()
              .entries
              .map((e) => widget.buildItem(e.value, e.key))
              .toList(),
        ),
      );
    }

    return SliverPadding(
      padding: widget.padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (widget.showDivider) {
              final itemIndex = index ~/ 2;
              if (index.isOdd) {
                return widget.buildDivider?.call(context, itemIndex) ??
                    const Divider(height: 0, color: Colors.grey);
              }
              return widget.buildItem(filteredItems[itemIndex], itemIndex);
            }
            return widget.buildItem(filteredItems[index], index);
          },
          childCount: widget.showDivider
              ? (filteredItems.length * 2) - 1
              : filteredItems.length,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    if (widget.buildEmpty != null) {
      return SliverFillRemaining(child: widget.buildEmpty!());
    }

    return SliverFillRemaining(
      child: Center(
        child: Text(widget.emptyText ?? 'Không có dữ liệu'),
      ),
    );
  }

  Widget _buildError(Failure failure) {
    if (widget.buildError != null) {
      return SliverFillRemaining(
        child: widget.buildError!(failure, () => bloc.retry()),
      );
    }

    return SliverFillRemaining(
      child: Center(
        child: AppErrorWidget(
          error: failure.message,
          onRefresh: () async {
            bloc.retry();
          },
        ),
      ),
    );
  }

  Widget _buildLoadMore(BaseListProState<T> state) {
    final isLoadingMore = state is ListLoaded<T> && state.isLoadingMore;

    return SliverToBoxAdapter(
      child: VisibilityDetector(
        key: const Key('list-load-more'),
        onVisibilityChanged: _onVisibilityChanged,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Center(
            child: isLoadingMore
                ? const CircularProgressIndicator()
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

/// Selector widget for listening to specific state changes
class BaseListProSelector<T, F> extends StatelessWidget {
  final bool Function(BaseListProState<T>, BaseListProState<T>)? listenWhen;
  final void Function(BuildContext context, BaseListProState<T> state) listener;
  final bool Function(BaseListProState<T>, BaseListProState<T>)? buildWhen;
  final Widget Function(BaseListProState<T> state)? buildLoading;
  final Widget Function(ListError<T> state)? buildError;
  final Widget Function(ListLoaded<T> state) buildLoaded;

  const BaseListProSelector({
    super.key,
    this.listenWhen,
    required this.listener,
    this.buildWhen,
    this.buildLoading,
    this.buildError,
    required this.buildLoaded,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BaseListProBloc<T, F>, BaseListProState<T>>(
      listenWhen: listenWhen,
      listener: listener,
      buildWhen: buildWhen,
      builder: (context, state) {
        return switch (state) {
          ListInitial() || ListLoading() =>
            buildLoading?.call(state) ?? const SizedBox.shrink(),
          ListLoaded() => buildLoaded(state),
          ListError() => buildError?.call(state) ?? const SizedBox.shrink(),
        };
      },
    );
  }
}
