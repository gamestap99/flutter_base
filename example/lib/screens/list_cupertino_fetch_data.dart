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
  @override
  Widget build(BuildContext context) {
    return BaseListCupertinoWidget<ProjectEntity, dynamic>(
      queryParameters: {},
      baseListCupertinoNavbarData: BaseListCupertinoNavbarData(
        leadingColor: CupertinoColors.black,
        title: 'Test',
        trailing: IconButton(
          onPressed: () {
            // _showSheet(context);
          },
          icon:  const Icon(CupertinoIcons.line_horizontal_3_decrease),
        ),
      ),
      opts: BaseListOpts(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 24)
      ),
      buildItem: (item, int index) {
        return Card(
          child: Column(
            children: [
              Text(item.name ?? ''),
            ],
          ),
        );
      },
    );
  }
}
