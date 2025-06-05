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
  bool searchIsActive = false;
  late String text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseListCupertinoWidget<ProjectEntity, dynamic>(
        queryParameters: {},
        cupertinoSliverNavigationBar: CupertinoSliverNavigationBar.search(
          stretch: true,
          // middle: const Text('Contacts Group'),
          largeTitle: const Text('Family'),
          // bottomMode: true,
          searchField: CupertinoSearchTextField(
            autofocus: true,
            placeholder: searchIsActive ? 'Enter search text' : 'Search',
            onChanged: (String value) {
              setState(() {
                if (value.isEmpty) {
                  text = 'Type in the search field to show text here';
                } else {
                  text = 'The text has changed to: $value';
                }
              });
            },
          ),
          onSearchableBottomTap: (bool value) {
            text = 'Type in the search field to show text here';
            setState(() {
              searchIsActive = value;
            });
          },
        ),
        // baseListCupertinoNavbarData: BaseListCupertinoNavbarData(
        //   isTransparent: true,
        //   isSliverAppBar: false,
        //   previousPageTitle: "Home",
        //   largeTitle: const Text('Test'),
        //   middle: const Text("aa"),
        //   trailing: IconButton(
        //     onPressed: () {
        //       // _showSheet(context);
        //     },
        //     icon: const Icon(CupertinoIcons.line_horizontal_3_decrease),
        //   ),
        // ),
        opts: const BaseListOpts(padding: EdgeInsetsDirectional.symmetric(horizontal: 24,vertical: 20)),
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
