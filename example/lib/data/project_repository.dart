import 'package:flutter_base/flutter_base.dart';

import 'api_res.dart';
import 'fetch_list_data.dart';

/// Repository for ProjectEntity list operations
/// Implements ListRepository pattern for use with BaseListProBloc
class ProjectRepository implements ListRepository<ProjectEntity, dynamic> {
  @override
  Future<Result<ListResponse<ProjectEntity>>> getItems({
    required int page,
    required int limit,
    dynamic filter,
  }) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 700));

      final apiRes = ApiResModel.fromJson(sourceList);

      return Result.success(ListResponse(
        items: apiRes.items?.map((e) => ProjectEntity.fromJson(e)).toList() ?? [],
        hasMore: apiRes.meta?.nextPage != null,
        totalCount: apiRes.meta?.totalCount,
        currentPage: apiRes.meta?.currentPage,
        meta: apiRes.meta,
      ));
    } catch (e, st) {
      return Result.failure(UnknownFailure.fromException(e, st));
    }
  }

  @override
  Future<Result<ProjectEntity>> createItem(ProjectEntity item) async {
    // Not implemented for demo
    throw UnimplementedError();
  }

  @override
  Future<Result<ProjectEntity>> updateItem(ProjectEntity item) async {
    // Not implemented for demo
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteItem(ProjectEntity item) async {
    // Simulate delete
    await Future.delayed(const Duration(milliseconds: 300));
    return const Result.success(null);
  }

  @override
  Future<Result<void>> deleteItems(List<ProjectEntity> items) async {
    for (final item in items) {
      final result = await deleteItem(item);
      if (result.isFailure) return result;
    }
    return const Result.success(null);
  }
}

/// Repository for single ProjectEntity item operations
class ProjectDetailRepository implements ItemRepository<ProjectEntity, String> {
  @override
  Future<Result<ProjectEntity>> getItem(String projectId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final apiRes = ApiResModel.fromJson(sourceList);
      final items = apiRes.items;
      
      if (items == null || items.isEmpty) {
        return Result.failure(const ClientFailure(
          message: 'No projects available',
          statusCode: 404,
        ));
      }
      
      // Tìm item theo ID, nếu không có thì lấy item đầu tiên
      Map<String, dynamic>? item;
      for (final e in items) {
        if (e['id'] == projectId) {
          item = e;
          break;
        }
      }
      item ??= items.first;

      return Result.success(ProjectEntity.fromJson(item!));
    } catch (e, st) {
      return Result.failure(UnknownFailure.fromException(e, st));
    }
  }

  @override
  Future<Result<ProjectEntity>> updateItem(ProjectEntity item) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Result.success(item);
  }

  @override
  Future<Result<ProjectEntity>> patchItem(
    ProjectEntity item,
    Map<String, dynamic> changes,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Result.success(item);
  }

  @override
  Future<Result<void>> deleteItem(ProjectEntity item) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Result.success(null);
  }
}

/// Form repository for demo
class DemoFormRepository extends FormRepository<Map<String, dynamic>> {
  @override
  Future<Result<Map<String, dynamic>>> submit(Map<String, dynamic> values) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      // Simulate successful submission
      return Result.success(values);
    } catch (e, st) {
      return Result.failure(UnknownFailure.fromException(e, st));
    }
  }

  @override
  Future<Result<void>> saveDraft(Map<String, dynamic> values) async {
    // Not implemented for demo
    return const Result.success(null);
  }

  @override
  Future<Result<Map<String, dynamic>?>> loadDraft() async {
    return const Result.success(null);
  }

  @override
  Future<Result<void>> clearDraft() async {
    return const Result.success(null);
  }
}
