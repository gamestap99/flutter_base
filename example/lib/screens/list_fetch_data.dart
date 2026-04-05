import 'package:example/data/fetch_list_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/flutter_base.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListFetchData extends StatelessWidget {
  const ListFetchData({super.key});

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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Base List"),
      ),
      child: BaseListWidget<ProjectEntity, dynamic>(
        queryParameters: {},
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
    );
  }
}
