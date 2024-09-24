import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  int _selectedSegment = 0;

  final Map<int, Widget> _segments = const <int, Widget>{
    0: Text('Tab 1'),
    1: Text('Tab 2'),
    2: Text('Tab 3'),
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Segmented Control Demo'),
          border: Border(),
        ),
        child: SafeArea(
          child: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                // const SliverAppBar(
                //   title: Text("Whatsapp"),
                //   centerTitle: false,
                //   automaticallyImplyLeading: false,
                //   floating: true,
                //   backgroundColor: Color.fromARGB(255, 4, 94, 84),
                //   actions: [
                //     Icon(Icons.search, size: 30, color: Colors.white),
                //     SizedBox(width: 10),
                //     Icon(Icons.more_vert, size: 30, color: Colors.white),
                //   ],
                //   elevation: 0.0,
                // ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    CupertinoSlidingSegmentedControl<int>(
                      groupValue: _selectedSegment,
                      onValueChanged: (int? value) {
                        if (value != null) {
                          setState(() {
                            _selectedSegment = value;
                          });
                        }
                      },
                      children: _segments,
                    ),
                  ),
                  pinned: true,
                ),

              ];
            },
            body: IndexedStack(
              index: _selectedSegment,
              children: [
                Container(child: Center(child: Text("1")),),
                Container(child: Text("2"),),
                Container(child: Text("3"),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._segmentedControl);

  final Widget _segmentedControl;

  @override
  double get minExtent => 50.0;
  @override
  double get maxExtent => 50.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: CupertinoTheme.of(context).barBackgroundColor,
      child: Center(child: _segmentedControl),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}
