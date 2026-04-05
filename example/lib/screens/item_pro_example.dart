import 'package:example/data/project_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/flutter_base.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/fetch_list_data.dart';

/// Example screen demonstrating BaseItemProBloc + BaseItemProWidget
/// Shows the new Pro architecture with:
/// - Repository pattern for single item
/// - Result type for error handling
/// - Sealed class state pattern matching
/// - Auto refresh when stale
/// - Optimistic updates
class ItemProExampleScreen extends StatelessWidget {
  const ItemProExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo với project ID mặc định
    const projectId = '01j3yrgjkgrwybjgdsgr1qw38q';
    
    // QUAN TRỌNG: Phải dùng BlocProvider<BaseItemProBloc<T, F>>
    // để BaseItemProWidget có thể tìm thấy bloc
    return BlocProvider<BaseItemProBloc<ProjectEntity, String>>(
      create: (_) => ProjectDetailBloc(
        repository: ProjectDetailRepository(),
      )..load(filter: projectId),
      child: const _ItemProExampleContent(projectId: projectId),
    );
  }
}

/// BLoC for project detail using Pro architecture
class ProjectDetailBloc extends BaseItemProBloc<ProjectEntity, String> {
  ProjectDetailBloc({required ProjectDetailRepository repository})
      : super(
          repository: repository,
          staleDuration: const Duration(minutes: 5),
          retryConfig: const RetryConfig(
            maxAttempts: 3,
            initialDelay: Duration(seconds: 1),
          ),
          onAnalytics: (event) => debugPrint('📊 ProjectDetail: $event'),
        );
}

class _ItemProExampleContent extends StatelessWidget {
  final String projectId;

  const _ItemProExampleContent({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Item Pro Example'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.refresh),
          onPressed: () {
            context.read<BaseItemProBloc<ProjectEntity, String>>().refresh(force: true);
          },
        ),
      ),
      child: Material(
        child: SafeArea(
          child: BaseItemProWidget<ProjectEntity, String>(
            queryParameters: projectId,
            autoRefresh: true,

            // Build loaded content as slivers
            buildLoadedSlivers: (project, state) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              CupertinoColors.activeBlue.withOpacity(0.1),
                              CupertinoColors.activeBlue.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: CupertinoColors.activeBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                CupertinoIcons.building_2_fill,
                                size: 32,
                                color: CupertinoColors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project.name ?? 'Không có tên',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.label.resolveFrom(context),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ID: $projectId',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // State info section
                      Text(
                        'State Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.label.resolveFrom(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      _InfoCard(
                        children: [
                          _InfoRow(
                            icon: CupertinoIcons.cube_box,
                            label: 'State Type',
                            value: state.runtimeType.toString(),
                          ),
                          _InfoRow(
                            icon: CupertinoIcons.time,
                            label: 'Loaded At',
                            value: state.asLoadedOrNull?.loadedAt.toString().split('.').first ?? 'N/A',
                          ),
                          _InfoRow(
                            icon: CupertinoIcons.clock,
                            label: 'Is Stale',
                            value: (state.asLoadedOrNull?.isStale ?? false) ? 'Yes ⚠️' : 'No ✓',
                            valueColor: (state.asLoadedOrNull?.isStale ?? false) 
                                ? CupertinoColors.systemOrange 
                                : CupertinoColors.systemGreen,
                          ),
                          _InfoRow(
                            icon: CupertinoIcons.arrow_2_circlepath,
                            label: 'Is Updating',
                            value: (state.asLoadedOrNull?.isUpdating ?? false) ? 'Yes' : 'No',
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // API Methods Demo
                      Text(
                        'API Methods Demo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.label.resolveFrom(context),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Actions grid
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ActionButton(
                            icon: CupertinoIcons.refresh,
                            label: 'Refresh',
                            onTap: () {
                              context.read<BaseItemProBloc<ProjectEntity, String>>().refresh();
                            },
                          ),
                          _ActionButton(
                            icon: CupertinoIcons.refresh_bold,
                            label: 'Force Refresh',
                            color: CupertinoColors.activeBlue,
                            onTap: () {
                              context.read<BaseItemProBloc<ProjectEntity, String>>().refresh(force: true);
                            },
                          ),
                          _ActionButton(
                            icon: CupertinoIcons.arrow_counterclockwise,
                            label: 'Reset',
                            color: CupertinoColors.systemOrange,
                            onTap: () {
                              context.read<BaseItemProBloc<ProjectEntity, String>>().reset();
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Reload with different ID
                      Text(
                        'Load Different Item',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.label.resolveFrom(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          color: CupertinoColors.systemGrey5.resolveFrom(context),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          onPressed: () {
                            // Load item khác (demo)
                            context.read<BaseItemProBloc<ProjectEntity, String>>().load(
                              filter: '01j4e7bvf8g0rqjhn9e5qc3x4w',
                            );
                          },
                          child: Text(
                            'Load Another Project',
                            style: TextStyle(
                              color: CupertinoColors.label.resolveFrom(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Loading state
            buildLoading: () => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CupertinoActivityIndicator(radius: 20),
                  const SizedBox(height: 16),
                  Text(
                    'Đang tải...',
                    style: TextStyle(
                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                ],
              ),
            ),

            // Error state
            buildError: (failure, retry) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemRed.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        size: 48,
                        color: CupertinoColors.systemRed,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Có lỗi xảy ra',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label.resolveFrom(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      failure.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel.resolveFrom(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CupertinoButton.filled(
                      onPressed: retry,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: CupertinoColors.systemGrey),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor ?? CupertinoColors.label.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? CupertinoColors.systemGrey;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: buttonColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: buttonColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: buttonColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
