import 'package:example/data/fetch_list_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/flutter_base.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListCupertinoFetchData extends StatelessWidget {
  const ListCupertinoFetchData({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BaseListBloc<ProjectEntity, dynamic>(
        api: (page, limit, filter) {
          return fetchGetLists();
        },
      ),
      child: const _Render(),
    );
  }
}

class _Render extends StatefulWidget {
  const _Render({super.key});

  @override
  State<_Render> createState() => _RenderState();
}

class _RenderState extends State<_Render> {
  bool _isAnimatedNavBg = true;
  bool _isLargeTitle = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseListCupertinoWidget<ProjectEntity, dynamic>(
        queryParameters: {},
        baseListCupertinoNavbarData: BaseListCupertinoNavbarData(
          isLargeTitle: _isLargeTitle,
          isAnimatedColor: _isAnimatedNavBg,
          leadingColor: CupertinoColors.black,
          previousPageTitle: "Home",
          leadingOnPressed: () => Navigator.pop(context),
          largeTitle: Text('Test'),
          trailing: IconButton(
            onPressed: () {
              // _showSheet(context);
            },
            icon: const Icon(CupertinoIcons.line_horizontal_3_decrease),
          ),
        ),
        opts: const BaseListOpts(padding: EdgeInsetsDirectional.symmetric(horizontal: 24)),
        buildItem: (item, int index) {
          return Card(
            child: Column(
              children: [
                Text(item.name ?? ''),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              onPressed: () {
                setState(() {
                  _isAnimatedNavBg = !_isAnimatedNavBg;
                });
              },
              child: Row(
                children: [
                  CupertinoSwitch(
                    value: _isAnimatedNavBg,
                    onChanged: (value){
                      setState(() {
                        _isAnimatedNavBg = !value;
                      });
                    },
                  ),
                  Text("Change Nav Animated Bg")
                ],
              ),
            ),
            CupertinoButton(
              onPressed: () {
                setState(() {
                  _isLargeTitle = !_isLargeTitle;
                });
              },
              child: Row(
                children: [
                  CupertinoSwitch(
                    value: _isLargeTitle,
                    onChanged: (value){
                      setState(() {
                        _isLargeTitle = !value;
                      });
                    },
                  ),
                  const Text("Change Large to Small Title")
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
