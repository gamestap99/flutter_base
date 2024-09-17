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
  final bool isAnimatedColor;
  final Widget largeTitle;
  final Widget? middle;

  const CupertinoSliverPageScaffold({
    super.key,
    required this.slivers,
    this.leading,
    this.leadingColor,
    this.previousPageTitle,
    this.leadingOnPressed,
    this.trailing,
    this.middle,
    this.automaticallyImplyLeading = true,
    this.isAnimatedColor = true,
    required this.largeTitle,
  });

  @override
  State<CupertinoSliverPageScaffold> createState() => _CupertinoSliverPageScaffoldState();
}

class _CupertinoSliverPageScaffoldState extends State<CupertinoSliverPageScaffold> {
  bool showSmallTitle = false;
  double visibility = 0.0;

  @override
  void initState() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    super.initState();
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

  Border? _borderNavSliver(BuildContext context) {
    Color kBorderColor = const Color(0x4D000000);

    if (!widget.isAnimatedColor) {
      return Border(
        bottom: BorderSide(
          color: kBorderColor,
          width: 0.0, // 0.0 means one physical pixel
        ),
      );
    }

    return Border(
      bottom: BorderSide(
        width: 0.0,
        color: kBorderColor.withOpacity(visibility),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              backgroundColor: !widget.isAnimatedColor ? null : CupertinoColors.white.withOpacity(visibility),
              middle: _middleSliver(context),
              trailing: widget.trailing,
              leading: _leading(context),
              previousPageTitle: widget.previousPageTitle,
              largeTitle: VisibilityDetector(
                key: const Key('nav-container'),
                onVisibilityChanged: (VisibilityInfo info) {
                  if(info.visibleFraction < 1){
                    setState(() {
                      visibility = 1 - info.visibleFraction;
                    });
                  }

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
                child: widget.largeTitle,
              ),
              border: _borderNavSliver(context),
            ),
            ...widget.slivers,
          ],
        ),
      ),
    );
  }
}
