import 'package:example/data/project_repository.dart';
import 'package:example/screens/item_pro_example.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/flutter_base.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/fetch_list_data.dart';

/// Example screen demonstrating BaseListProBloc + BaseListProWidget
/// Shows the new Pro architecture with:
/// - Repository pattern
/// - Result type for error handling
/// - Sealed class state pattern matching
/// - Pull-to-refresh and load more
class ListProExampleScreen extends StatelessWidget {
  const ListProExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BaseListProBloc<ProjectEntity, dynamic>>(
      create: (_) => ProjectListBloc(
        repository: ProjectRepository(),
      )..load(),
      child: const _ListProExampleContent(),
    );
  }
}

/// BLoC for project list using Pro architecture
class ProjectListBloc extends BaseListProBloc<ProjectEntity, dynamic> {
  ProjectListBloc({required ProjectRepository repository})
      : super(
          repository: repository,
          pageSize: 20,
          cacheTTL: const Duration(minutes: 5),
          retryConfig: const RetryConfig(maxAttempts: 3),
          onAnalytics: (event) {
            debugPrint('📊 ProjectList: $event');
          },
        );
}

class _ListProExampleContent extends StatelessWidget {
  const _ListProExampleContent();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('List Pro Example'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.refresh),
          onPressed: () {
            context.read<BaseListProBloc<ProjectEntity, dynamic>>().refresh();
          },
        ),
      ),
      child: SafeArea(
        child: BaseListProWidget<ProjectEntity, dynamic>(
          // Build individual item
          buildItem: (project, index) => _ProjectCard(project: project),

          // Custom loading state
          buildLoading: () => const _LoadingSkeleton(),

          // Custom empty state
          buildEmpty: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.doc_text_search,
                  size: 64,
                  color: CupertinoColors.systemGrey,
                ),
                SizedBox(height: 16),
                Text(
                  'Không có dự án nào',
                  style: TextStyle(
                    fontSize: 18,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),

          // Custom error state with retry
          buildError: (failure, retry) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.exclamationmark_triangle,
                  size: 64,
                  color: CupertinoColors.systemRed,
                ),
                const SizedBox(height: 16),
                Text(
                  failure.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                CupertinoButton.filled(
                  onPressed: retry,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),

          // Layout options
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectEntity project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to Item Pro Example
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => const ItemProExampleScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.building_2_fill,
                  color: CupertinoColors.activeBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name ?? 'Không có tên',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          5,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 80,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
