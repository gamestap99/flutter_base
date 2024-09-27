import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CupertinoSliverPageScaffold extends StatefulWidget {
  final List<Widget> slivers;
  final Widget? leading;
  final Color? leadingColor;
  final String? previousPageTitle;
  final void Function()? leadingOnPressed;
  final Widget? trailing;
  final bool automaticallyImplyLeading;
  final Widget largeTitle;
  final Widget? middle;
  final Border? Function(double visibility)? buildBorder;
  final Color? Function(double visibility)? navBackgroundColor;

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
    required this.largeTitle,
  });

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
    return CupertinoPageScaffold(
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          ValueListenableBuilder<double>(
            valueListenable: visibilityNotifier,
            builder: (context, visibility, child) {
              return CupertinoSliverNavigationBar(
                backgroundColor: widget.navBackgroundColor?.call(visibility) ?? CupertinoColors.white.withOpacity(visibility),
                middle: _middleSliver(context),
                trailing: widget.trailing,
                leading: _leading(context),
                previousPageTitle: widget.previousPageTitle,
                largeTitle: VisibilityDetector(
                  key: const Key('nav-container'),
                  onVisibilityChanged: (VisibilityInfo info) {
                    if (info.visibleFraction < 1 && _scrollController.position.userScrollDirection == ScrollDirection.reverse) {
                      visibilityNotifier.value = 1 - info.visibleFraction;
                    } else if (info.visibleFraction >= 1 && _scrollController.position.pixels > 20) {
                      visibilityNotifier.value = 1;
                    } else {
                      visibilityNotifier.value = 1 - info.visibleFraction;
                    }
                  },
                  child: widget.largeTitle,
                ),
                border: widget.buildBorder?.call(visibility) ?? _borderNavSliver(context, visibility),
              );
            },
          ),
          ...widget.slivers,
        ],
      ),
    );
  }
}
