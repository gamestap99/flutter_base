import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CupertinoSliverPageScaffold extends StatefulWidget {
  final List<Widget> slivers;
  final Widget? leading;
  final Color? leadingColor;
  final String? previousPageTitle;
  final void Function()? leadingOnPressed;
  final String largeTitle;
  final Widget? trailing;
  final bool automaticallyImplyLeading;

  const CupertinoSliverPageScaffold({
    super.key,
    required this.slivers,
    this.leading,
    this.leadingColor,
    this.previousPageTitle,
    this.leadingOnPressed,
    this.trailing,
    this.automaticallyImplyLeading = true,
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

  Widget _largeTitle(BuildContext context) {
    return VisibilityDetector(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(widget.largeTitle),
      ),
    );
  }

  Widget? _middle(BuildContext context) {
    return visibility > 0.9 ? (Text(widget.largeTitle)) : const Text("");
  }

  Widget? _leading(BuildContext context) {
    Widget barBackButton = CupertinoNavigationBarBackButton(
      color: widget.leadingColor,
      previousPageTitle: widget.previousPageTitle,
      onPressed: widget.leadingOnPressed,
    );

    return widget.leading ?? (widget.automaticallyImplyLeading ? barBackButton : null);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              backgroundColor: CupertinoColors.white.withOpacity(visibility),
              middle: _middle(context),
              trailing: widget.trailing,
              leading: _leading(context),
              previousPageTitle: widget.previousPageTitle,
              largeTitle: _largeTitle(context),
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: CupertinoColors.white.withOpacity(visibility),
                ),
              ),
            ),
            ...widget.slivers,
          ],
        ),
      ),
    );
  }
}
