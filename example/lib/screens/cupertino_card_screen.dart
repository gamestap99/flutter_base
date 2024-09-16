import 'package:flutter/cupertino.dart';
import 'package:flutter_base/flutter_base.dart';

class CupertinoCardScreen extends StatefulWidget {
  const CupertinoCardScreen({super.key});

  @override
  State<CupertinoCardScreen> createState() => _CupertinoCardScreenState();
}

class _CupertinoCardScreenState extends State<CupertinoCardScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("CupertinoCardScreen"),
      ),
      child: Center(
        child: CupertinoCardWidget(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("data dad ad ad a"),
              Text("data"),
              Text("data"),
              Text("data"),
            ],
          ),
        ),
      ),
    );
  }
}
