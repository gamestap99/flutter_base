import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CupertinoSliverPageScaffold extends StatefulWidget {
  final List<Widget> slivers;
  final Widget? leading;
  final Color? leadingColor;
  final String? previousPageTitle;
  final void Function()? leadingOnPressed;
  final Widget? trailing;
  final bool automaticallyImplyLeading;
  final Widget? largeTitle;
  final Widget? middle;
  final Border? Function(double visibility)? buildBorder;
  final Color? Function(double visibility)? navBackgroundColor;
  final bool isTransparent;
  final bool isSliverAppBar;
  final Border? border;
  final Color? backgroundColor;

  const CupertinoSliverPageScaffold({
    super.key,
    required this.slivers,
    this.leading,
    this.leadingColor,
    this.previousPageTitle,
    this.leadingOnPressed,
    this.trailing,
    this.middle,
    this.buildBorder,
    this.navBackgroundColor,
    this.automaticallyImplyLeading = true,
    this.isTransparent = false,
    this.isSliverAppBar = true,
    this.border,
    this.backgroundColor,
    this.largeTitle,
  }): assert((isSliverAppBar && largeTitle != null) || isSliverAppBar == false);

  @override
  State<CupertinoSliverPageScaffold> createState() => _CupertinoSliverPageScaffoldState();
}

class _CupertinoSliverPageScaffoldState extends State<CupertinoSliverPageScaffold> {
  late final ScrollController _scrollController;
  final ValueNotifier<double> visibilityNotifier = ValueNotifier<double>(0.0);

  @override
  void initState() {
    _scrollController = ScrollController();
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    visibilityNotifier.dispose();
    super.dispose();
  }

  Widget? _middleSliver(BuildContext context) {
    return widget.middle;
  }

  Widget? _leading(BuildContext context) {
    Widget barBackButton = CupertinoNavigationBarBackButton(
      color: widget.leadingColor,
      previousPageTitle: widget.previousPageTitle,
      onPressed: widget.leadingOnPressed,
    );

    return widget.leading ?? (widget.automaticallyImplyLeading ? barBackButton : null);
  }

  Border? _borderNavSliver(BuildContext context, double visibility) {
    Color kBorderColor = const Color(0x4D000000);

    return Border(
      bottom: BorderSide(
        width: 0.0,
        color: kBorderColor.withOpacity(visibility),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color? navBarBackgroundColor = widget.isTransparent ? Colors.transparent : widget.backgroundColor;
    Brightness? navBarBrightness = widget.isTransparent ? Brightness.light : null;
    Border? navBorder = widget.isTransparent ? const Border() : widget.border;

    CupertinoNavigationBar? navigationBar = !widget.isSliverAppBar
        ? CupertinoNavigationBar(
            brightness: navBarBrightness,
            backgroundColor: navBarBackgroundColor,
            middle: _middleSliver(context),
            trailing: widget.trailing,
            leading: widget.leading,
            previousPageTitle: widget.previousPageTitle,
            border: navBorder,
          )
        : null;

    return CupertinoPageScaffold(
      navigationBar: navigationBar,
      child: SafeArea(
        top: !widget.isSliverAppBar,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            if (widget.isSliverAppBar)
              ValueListenableBuilder<double>(
                valueListenable: visibilityNotifier,
                builder: (context, visibility, child) {
                  return CupertinoSliverNavigationBar(
                    brightness: navBarBrightness,
                    backgroundColor: navBarBackgroundColor,
                    middle: _middleSliver(context),
                    trailing: widget.trailing,
                    leading: _leading(context),
                    previousPageTitle: widget.previousPageTitle,
                    largeTitle: widget.largeTitle,
                    // largeTitle: VisibilityDetector(
                    //   key: const Key('nav-container'),
                    //   onVisibilityChanged: (VisibilityInfo info) {
                    //     if (info.visibleFraction < 1 && _scrollController.position.userScrollDirection == ScrollDirection.reverse) {
                    //       visibilityNotifier.value = 1 - info.visibleFraction;
                    //     } else if (info.visibleFraction >= 1 && _scrollController.position.pixels > 20) {
                    //       visibilityNotifier.value = 1;
                    //     } else {
                    //       visibilityNotifier.value = 1 - info.visibleFraction;
                    //     }
                    //   },
                    //   child: widget.largeTitle,
                    // ),
                    border: navBorder,
                  );
                },
              ),
            ...widget.slivers.map((e) {
              return DefaultTextStyle(
                style: CupertinoTheme.of(context).textTheme.textStyle,
                child: e,
              );
            }),
          ],
        ),
      ),
    );
  }
}
