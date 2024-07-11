import 'package:flutter/material.dart';
import 'package:flutter_base/flutter_base.dart';
import 'package:flutter_base/src/compoments/error_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BaseItemWidget<T, F> extends StatefulWidget {
  final T? item;
  final F? queryParameters;
  final Widget Function()? buildLoading;
  final List<Widget> Function(T item, BaseItemState<T> state) buildLoadedSlivers;
  final Widget Function(T item, Future Function() onRefresh)? buildCustomLoaded;
  final Widget Function(BaseItemState<T> state)? buildEmpty;
  final SliverAppBar? sliverAppBar;

  const BaseItemWidget({
    super.key,
    this.item,
    this.queryParameters,
    this.buildLoading,
    this.buildCustomLoaded,
    required this.buildLoadedSlivers,
    this.buildEmpty,
    this.sliverAppBar,
  });

  @override
  State<BaseItemWidget<T, F>> createState() => _BaseItemWidgetState<T, F>();
}

class _BaseItemWidgetState<T, F> extends State<BaseItemWidget<T, F>> {
  BaseItemBloc<T, F> get bloc => context.read<BaseItemBloc<T, F>>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  F? queryParameters;

  Future onRefreshFail() {
    bloc.add(BaseItemLoadStarted<F>(queryParameters: queryParameters));

    return bloc.stream.firstWhere((e) => e.status != EBlocStateStatus.loading);
  }

  Future onRefresh() async {
    bloc.add(BaseItemLoadRefresh<F>(queryParameters: queryParameters));

    return bloc.stream.firstWhere((e) => e.status != EBlocStateStatus.loadingRefresh);
  }

  @override
  void initState() {
    super.initState();

    queryParameters = widget.queryParameters;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        bloc.add(
          BaseItemLoadStarted(queryParameters: queryParameters),
        );
      }
    });

    setState(() {});
  }

  @override
  void didUpdateWidget(covariant BaseItemWidget<T, F> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (queryParameters != widget.queryParameters) {
      queryParameters = widget.queryParameters;
      bloc.add(BaseItemLoadStarted<F>(queryParameters: queryParameters));
      setState(() {});
    }
  }

  Widget _buildFailure() {
    return BlocBuilder<BaseItemBloc<T, F>, BaseItemState<T>>(
      builder: (context, state) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverFillRemaining(
              child: Center(
                child: AppErrorWidget(
                  networkException: state.exception,
                  error: state.error?.toString(),
                  onRefresh: onRefreshFail,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildLoadedSliver() {
    return BlocBuilder<BaseItemBloc<T, F>, BaseItemState<T>>(
      builder: (context, state) {
        return RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: onRefresh,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              if (widget.sliverAppBar != null) widget.sliverAppBar!,
              ...widget.buildLoadedSlivers(state.item as T, state),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BaseItemBloc<T, F>, BaseItemState<T>>(
      builder: (context, state) {
        switch (state.status) {
          case EBlocStateStatus.loading:
            {
              return Center(child: widget.buildLoading?.call() ?? const CircularProgressIndicator());
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
            if ((widget.buildEmpty != null && state.item == null)) {
              return widget.buildEmpty!.call(state);
            }

            return widget.buildCustomLoaded?.call(state.item!, onRefresh) ?? _buildLoadedSliver();

          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

class BaseItemChildWidget<T, F> extends StatefulWidget {
  final Widget Function(BaseItemState<T> state)? buildLoading;
  final Widget Function(BaseItemState<T> state) buildSuccess;
  final Widget Function(BaseItemState<T> state)? buildFail;

  const BaseItemChildWidget({
    super.key,
    this.buildLoading,
    required this.buildSuccess,
    this.buildFail,
  });

  @override
  State<BaseItemChildWidget<T, F>> createState() => _BaseItemChildWidgetState<T, F>();
}

class _BaseItemChildWidgetState<T, F> extends State<BaseItemChildWidget<T, F>> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BaseItemBloc<T, F>, BaseItemState<T>>(
      builder: (context, state) {
        switch (state.status) {
          case EBlocStateStatus.loading:
            return widget.buildLoading?.call(state) ?? const SizedBox.shrink();

          case EBlocStateStatus.fail:
            return widget.buildFail?.call(state) ?? const SizedBox.shrink();

          case EBlocStateStatus.success:
          case EBlocStateStatus.loadingMore:
          case EBlocStateStatus.loadMoreFailure:
          case EBlocStateStatus.loadMoreSuccess:
          case EBlocStateStatus.loadingRefresh:
          case EBlocStateStatus.loadRefreshFailure:
          case EBlocStateStatus.loadRefreshSuccess:
            return widget.buildSuccess(state);

          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
