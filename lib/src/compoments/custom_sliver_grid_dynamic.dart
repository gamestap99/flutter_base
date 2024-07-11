import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CustomSliverGridDynamic extends StatelessWidget {
  final int crossAxisCount;
  final int childCount;
  final Widget? Function(BuildContext context, int index) builder;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const CustomSliverGridDynamic({
    super.key,
    this.crossAxisCount = 2,
    required this.childCount,
    required this.builder,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMasonryGrid(
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      delegate: SliverChildBuilderDelegate(
        builder,
        childCount: childCount,
      ),
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
      ),
    );
  }
}
