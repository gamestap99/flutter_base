import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_base/flutter_base.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BaseListCupertinoNavbarData {
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final String? previousPageTitle;

  BaseListCupertinoNavbarData({
    required this.title,
     this.leading,
     this.trailing,
     this.previousPageTitle,
  });
}

class BaseListCupertinoWidget<T, F> extends StatefulWidget {
  final List<T>? items;
  final BaseListOpts opts;
  final Widget Function(T item, int index) buildItem;
  final Widget Function()? buildLoading;
  final Widget Function()? customBuildLoading;
  final Widget Function(BaseListState<T> state)? buildTop;
  final Widget Function(BaseListState<T> state)? buildEmptyLoaded;
  final Widget Function(BaseListState<T> state)? customList;
  final bool floatTop;
  final F? queryParameters;
  final void Function(GlobalKey<RefreshIndicatorState> key)? initRefreshKey;
  final void Function(ScrollController controller)? onInitScrollController;
  final void Function(bool isForward)? onListenerScroll;
  final String? emptyText;
  final bool Function(T)? filter;
  final ScrollController? scrollController;
  final BaseListCupertinoNavbarData baseListCupertinoNavbarData;

  /// Automatic call Api with new queryParameters. Default: false
  final bool autoFilter;

  const BaseListCupertinoWidget({
    super.key,
    this.items,
    this.buildLoading,
    this.customBuildLoading,
    this.onInitScrollController,
    this.onListenerScroll,
    this.buildEmptyLoaded,
    this.customList,
    this.emptyText,
    required this.queryParameters,
    required this.baseListCupertinoNavbarData,
    this.buildTop,
    this.initRefreshKey,
    required this.buildItem,
    this.opts = const BaseListOpts(),
    this.floatTop = false,
    this.autoFilter = false,
    this.filter,
    this.scrollController,
  });

  @override
  State<BaseListCupertinoWidget<T, F>> createState() => _BaseListCupertinoWidgetState<T, F>();
}

class _BaseListCupertinoWidgetState<T, F> extends State<BaseListCupertinoWidget<T, F>> {
  late final BaseListBloc<T, F> bloc;
  late final ScrollController _scrollController;
  final _deBouncer = Debouncer(milliseconds: 350);
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  bool showSmallTitle = false;
  double visibility = 0.0;

  @override
  void initState() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;

    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
    bloc = context.read<BaseListBloc<T, F>>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300)).then((__) {
        if (!bloc.isClosed && bloc.state.status == EBlocStateStatus.idle && bloc.state.items.isEmpty) {


          bloc.add(BaseListLoadStarted<F>(queryParameters: widget.queryParameters));
        }
      });
    });

    if (widget.items != null) {
      bloc.setItems(items: widget.items!);
    }

    widget.initRefreshKey?.call(_refreshIndicatorKey);
    widget.onInitScrollController?.call(_scrollController);

    super.initState();
  }

  @override
  void dispose() {
    _deBouncer.destroy();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final currentScroll = _scrollController.position.pixels;
    final minScroll = _scrollController.position.minScrollExtent;

    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      widget.onListenerScroll?.call(false);
    }

    if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      widget.onListenerScroll?.call(true);
    }

    if (currentScroll == minScroll) {
      widget.onListenerScroll?.call(false);
    }
  }

  Future _onRefreshFail() {
    bloc.add(BaseListLoadStarted<F>(queryParameters: widget.queryParameters));

    return bloc.stream.firstWhere((e) => e.status != EBlocStateStatus.loading);
  }

  Future _onRefresh() async {
    bloc.add(BaseListLoadRefresh<F>());

    return bloc.stream.firstWhere((e) => e.status != EBlocStateStatus.loadingRefresh);
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0) {
      if (mounted) {
        bloc.add(BaseListLoadMoreStarted<F>(
          queryParameters: widget.queryParameters,
        ));
      }
    }
  }

  @override
  void didUpdateWidget(covariant BaseListCupertinoWidget<T, F> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoFilter) {
      if (widget.queryParameters != oldWidget.queryParameters) {
        bloc.add(BaseListLoadStarted<F>(queryParameters: widget.queryParameters));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BaseListBloc<T, F>, BaseListState<T>>(
      listenWhen: (pev, cur) => pev.status != cur.status || (pev.items != cur.items),
      listener: (context, state) {
        if ((state.status == EBlocStateStatus.loadRefreshFailure && state.items.isNotEmpty)) {}
      },
      buildWhen: (pev, cur) => pev.status != cur.status,
      builder: (context, state) {
        return CupertinoPageScaffold(
          child: Scrollbar(
            // thumbVisibility: true,
            controller: _scrollController,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                CupertinoSliverNavigationBar(
                  stretch: false,
                  backgroundColor: CupertinoColors.white.withOpacity(visibility),
                  middle: visibility > 0.9 ? Text(widget.baseListCupertinoNavbarData.title) : const Text(""),
                  trailing: widget.baseListCupertinoNavbarData.trailing,
                  leading: widget.baseListCupertinoNavbarData.leading,
                  previousPageTitle: widget.baseListCupertinoNavbarData.previousPageTitle,
                  largeTitle: VisibilityDetector(
                    key: const Key('nav-container'),
                    onVisibilityChanged: (VisibilityInfo info) {
                      setState(() {
                        visibility = 1 - info.visibleFraction;
                      });
                      if (info.visibleFraction > 0) {
                        setState(() {
                          showSmallTitle = false;
                        });
                      } else {
                        setState(() {
                          showSmallTitle = true;
                        });
                      }
                    },
                    child: Text(widget.baseListCupertinoNavbarData.title),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: CupertinoColors.white.withOpacity(visibility),
                    ),
                  ),
                ),
                CupertinoSliverRefreshControl(
                  key: _refreshIndicatorKey,
                  onRefresh: _onRefresh,
                ),
                if (widget.buildTop != null)
                  SliverToBoxAdapter(
                    child: widget.buildTop?.call(state),
                  ),
                Builder(builder: (context) {
                  switch (state.status) {
                    case EBlocStateStatus.idle:
                    case EBlocStateStatus.loading:
                      {
                        if (widget.customBuildLoading != null) {
                          return widget.customBuildLoading!.call();
                        } else if (widget.buildLoading == null) {
                          return const SliverFillRemaining(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          return _buildLoading(state);
                        }
                      }

                    case EBlocStateStatus.fail:
                      return _buildFailure();

                    case EBlocStateStatus.success:
                    case EBlocStateStatus.loadingMore:
                    case EBlocStateStatus.loadMoreFailure:
                    case EBlocStateStatus.loadMoreSuccess:
                    case EBlocStateStatus.loadingRefresh:
                    case EBlocStateStatus.loadRefreshFailure:
                    case EBlocStateStatus.loadRefreshSuccess:
                      return _buildLoaded();

                    default:
                      return const SizedBox.shrink();
                  }
                }),
                if (state.items.isNotEmpty) _buildLoadMore(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoading(BaseListState<T> state) {
    if (widget.opts.isList) {
      return SliverToBoxAdapter(
        child: ListView.separated(
          padding: widget.opts.padding,
          physics: widget.opts.physics ?? const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (_, index) {
            return widget.buildLoading?.call();
          },
          itemCount: widget.opts.countLoading,
          separatorBuilder: (_, int index) {
            return widget.opts.divider
                ? (widget.opts.buildSeparator?.call(context, index) ??
                    const Divider(
                      height: 0,
                      color: Colors.grey,
                    ))
                : const SizedBox.shrink();
          },
        ),
      );
    }

    return SliverPadding(
      padding: widget.opts.padding,
      sliver: CustomSliverGridDynamic(
        crossAxisCount: widget.opts.crossAxisCount,
        crossAxisSpacing: widget.opts.crossAxisSpacing,
        mainAxisSpacing: widget.opts.mainAxisSpacing,
        childCount: widget.opts.countLoading,
        builder: (BuildContext context, int index) {
          return widget.buildLoading!.call();
        },
      ),
    );
  }

  Widget _buildLoaded() {
    return BlocBuilder<BaseListBloc<T, F>, BaseListState<T>>(
      buildWhen: (pev, cur) => pev.items != cur.items,
      builder: (context, state) {
        if (state.items.isEmpty) {
          return SliverFillRemaining(
            child: widget.buildEmptyLoaded?.call(state) ??
                Center(
                  child: Text(widget.emptyText ?? 'Empty data'),
                ),
          );
        }

        return widget.customList?.call(state) ??
            SliverPadding(
              padding: widget.opts.padding,
              sliver: _detectDisplayItems(),
            );
      },
    );
  }

  Widget _detectDisplayItems() {
    return BlocBuilder<BaseListBloc<T, F>, BaseListState<T>>(
      buildWhen: (previous, current) => previous.items != current.items,
      builder: (context, state) {
        List<T> items = state.items;

        if (widget.filter != null) {
          items = items.where(widget.filter!).toList();
        }

        if (items.isEmpty) {
          return SliverFillRemaining(
            child: widget.buildEmptyLoaded?.call(state) ??
                Center(
                  child: Text(widget.emptyText ?? 'Empty data'),
                ),
          );
        }

        if (widget.opts.isList) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: (items.length * 2) - 1,
              (context, index) {
                final int itemIndex = index ~/ 2;

                if (index.isEven) {
                  return widget.buildItem(items[itemIndex], itemIndex);
                }

                return widget.opts.buildSeparator?.call(context, index) ??
                    (widget.opts.divider
                        ? const Divider(
                            height: 0,
                            color: Colors.grey,
                          )
                        : const SizedBox.shrink());
              },
            ),
          );
        }

        return CustomSliverGridDynamic(
          crossAxisCount: widget.opts.crossAxisCount,
          crossAxisSpacing: widget.opts.crossAxisSpacing,
          mainAxisSpacing: widget.opts.mainAxisSpacing,
          childCount: items.length,
          builder: (BuildContext context, int index) {
            return widget.buildItem(items[index], index);
          },
        );
      },
    );
  }

  Widget _buildLoadMore() {
    return BlocBuilder<BaseListBloc<T, F>, BaseListState<T>>(
      buildWhen: (previous, current) => previous.isNextPageAvailable != current.isNextPageAvailable,
      builder: (context, state) {
        if (state.isNextPageAvailable) {
          return SliverToBoxAdapter(
            child: VisibilityDetector(
              key: const Key('last-item'),
              onVisibilityChanged: _onVisibilityChanged,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          );
        }

        return const SliverToBoxAdapter(
          child: SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildFailure() {
    return BlocBuilder<BaseListBloc<T, F>, BaseListState<T>>(
      builder: (context, state) {
        return SliverFillRemaining(
          child: Center(
            child: AppErrorWidget(
              networkException: state.exception,
              error: state.error?.toString(),
              onRefresh: _onRefreshFail,
            ),
          ),
        );
      },
    );
  }
}
