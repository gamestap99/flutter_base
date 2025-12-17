import 'package:example/data/project_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/flutter_base.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/fetch_list_data.dart';

// =============================================================================
// EXAMPLE: Using GetListUseCase with Clean Architecture
// =============================================================================

/// UseCase for fetching projects - Clean Architecture pattern
/// This can be injected via DI (GetIt, Riverpod, etc.)
class GetProjectsUseCase extends GetListUseCase<ProjectEntity, dynamic> {
  final ProjectRepository _repository;

  const GetProjectsUseCase(this._repository);

  @override
  Future<Result<ListResponse<ProjectEntity>>> call(ListParams<dynamic> params) {
    return _repository.getItems(
      page: params.page,
      limit: params.limit,
      filter: params.filter,
    );
  }
}

/// BLoC using UseCase pattern
class ProjectListWithUseCaseBloc extends BaseListProBloc<ProjectEntity, dynamic> {
  ProjectListWithUseCaseBloc({required GetProjectsUseCase getProjectsUseCase})
      : super(
          fetchUseCase: getProjectsUseCase,
          pageSize: 20,
          cacheTTL: const Duration(minutes: 5),
          retryConfig: const RetryConfig(maxAttempts: 3),
          onAnalytics: (event) {
            debugPrint('📊 ProjectList (UseCase): $event');
          },
        );
}

/// Example screen demonstrating UseCase pattern with BaseListProBloc
class ListProUseCaseExampleScreen extends StatelessWidget {
  const ListProUseCaseExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In real app, inject via DI
    final repository = ProjectRepository();
    final getProjectsUseCase = GetProjectsUseCase(repository);

    return BlocProvider<BaseListProBloc<ProjectEntity, dynamic>>(
      create: (_) => ProjectListWithUseCaseBloc(
        getProjectsUseCase: getProjectsUseCase,
      )..load(),
      child: const _ListProUseCaseContent(),
    );
  }
}

class _ListProUseCaseContent extends StatelessWidget {
  const _ListProUseCaseContent();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('UseCase Pattern Example'),
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
          buildItem: (project, index) => _ProjectCard(project: project),
          buildLoading: () => const Center(child: CupertinoActivityIndicator()),
          buildEmpty: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.doc_text_search, size: 64, color: CupertinoColors.systemGrey),
                SizedBox(height: 16),
                Text('Không có dự án nào', style: TextStyle(fontSize: 18, color: CupertinoColors.systemGrey)),
              ],
            ),
          ),
          buildError: (failure, retry) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.exclamationmark_triangle, size: 64, color: CupertinoColors.systemRed),
                const SizedBox(height: 16),
                Text(failure.message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                CupertinoButton.filled(onPressed: retry, child: const Text('Thử lại')),
              ],
            ),
          ),
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
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: CupertinoColors.activeBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(CupertinoIcons.building_2_fill, color: CupertinoColors.activeBlue),
        ),
        title: Text(project.name ?? 'Không có tên'),
        trailing: const Icon(CupertinoIcons.chevron_right),
      ),
    );
  }
}
