


import 'package:flutter/cupertino.dart';
import 'package:flutter_base/flutter_base.dart';

class CustomCupertinoPageScaffoldScreen extends StatefulWidget {
  const CustomCupertinoPageScaffoldScreen({super.key});

  @override
  State<CustomCupertinoPageScaffoldScreen> createState() => _CustomCupertinoPageScaffoldScreenState();
}

class _CustomCupertinoPageScaffoldScreenState extends State<CustomCupertinoPageScaffoldScreen> {
  @override
  Widget build(BuildContext context) {

    return const CupertinoSliverPageScaffold(
      isTransparent: true,
      isSliverAppBar: false,
      largeTitle: Text('Dịch vụ'),
      middle: Text("aa"),
      automaticallyImplyLeading: false,
      slivers: [
        SliverToBoxAdapter(
          child: VSpacer(36),
        ),
        SliverToBoxAdapter(
          child: VSpacer(20),
        ),
        SliverToBoxAdapter(child: Text("data"),),
      ],
    );
  }
}
