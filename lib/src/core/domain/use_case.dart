/// UseCase interfaces for Clean Architecture
/// Part of BLoC Pro VIP Architecture
library;

import '../failure/failure.dart';
import '../result/result.dart';
import '../repository/repository.dart';

// ============================================================================
// Base UseCase Classes
// ============================================================================

/// Base class for all use cases
abstract class BaseUseCase<T> {
  const BaseUseCase();
}

/// Use case with parameters - returns Result for error handling
abstract class UseCase<T, P> extends BaseUseCase<T> {
  const UseCase() : super();

  /// Execute the use case with given parameters
  Future<Result<T>> call(P params);
}

/// Use case without parameters
abstract class NoParamsUseCase<T> extends BaseUseCase<T> {
  const NoParamsUseCase() : super();

  /// Execute the use case without parameters
  Future<Result<T>> call();
}

// ============================================================================
// List-specific UseCase
// ============================================================================

/// Parameters for list fetching operations
class ListParams<F> {
  final int page;
  final int limit;
  final F? filter;
  final String? sort;
  final String? order;

  const ListParams({
    required this.page,
    required this.limit,
    this.filter,
    this.sort,
    this.order,
  });

  /// Create first page params
  factory ListParams.firstPage({
    int limit = 20,
    F? filter,
    String? sort,
    String? order,
  }) {
    return ListParams(
      page: 1,
      limit: limit,
      filter: filter,
      sort: sort,
      order: order,
    );
  }

  /// Create next page params from current
  ListParams<F> nextPage() {
    return ListParams(
      page: page + 1,
      limit: limit,
      filter: filter,
      sort: sort,
      order: order,
    );
  }

  /// Copy with new values
  ListParams<F> copyWith({
    int? page,
    int? limit,
    F? filter,
    String? sort,
    String? order,
  }) {
    return ListParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      order: order ?? this.order,
    );
  }

  /// Convert to query parameters map for API calls
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (sort?.isNotEmpty ?? false) 'sort': sort,
      if (order?.isNotEmpty ?? false) 'order': order,
    };

    // Merge filter if it's a Map
    if (filter != null) {
      if (filter is Map<String, dynamic>) {
        params.addAll(filter as Map<String, dynamic>);
      } else if (filter is ListParamsFilterMixin) {
        params.addAll((filter as ListParamsFilterMixin).toQueryParams());
      }
    }

    params.removeWhere((key, value) => value == null);

    return params;
  }

  @override
  String toString() => 'ListParams(page: $page, limit: $limit, filter: $filter)';
}

/// Mixin for custom filter objects to convert to query params
mixin ListParamsFilterMixin {
  Map<String, dynamic> toQueryParams();
}

// ============================================================================
// Specialized UseCase Interfaces for List Pro
// ============================================================================

/// UseCase for fetching paginated list
/// Can be used standalone without full Repository implementation
abstract class GetListUseCase<T, F> extends UseCase<ListResponse<T>, ListParams<F>> {
  const GetListUseCase() : super();

  @override
  Future<Result<ListResponse<T>>> call(ListParams<F> params);
}

/// UseCase for creating an item
abstract class CreateItemUseCase<T> extends UseCase<T, T> {
  const CreateItemUseCase() : super();

  @override
  Future<Result<T>> call(T item);
}

/// UseCase for updating an item
abstract class UpdateItemUseCase<T> extends UseCase<T, T> {
  const UpdateItemUseCase() : super();

  @override
  Future<Result<T>> call(T item);
}

/// UseCase for deleting an item
abstract class DeleteItemUseCase<T> extends UseCase<void, T> {
  const DeleteItemUseCase() : super();

  @override
  Future<Result<void>> call(T item);
}

// ============================================================================
// Specialized UseCase Interfaces for Item Pro
// ============================================================================

/// UseCase for fetching single item
abstract class GetItemUseCase<T, F> extends UseCase<T, F> {
  const GetItemUseCase() : super();

  @override
  Future<Result<T>> call(F filter);
}

// ============================================================================
// Base Param Classes (Compatible with user's existing pattern)
// ============================================================================

/// Base class for list parameters - use this for custom param classes
/// Example:
/// ```dart
/// class PostGetListParam extends BaseListParam {
///   final Map<String, String>? customFilter;
///   PostGetListParam({required super.page, required super.limit, this.customFilter});
///   @override
///   Map<String, dynamic> mergeParam() => {...super.mergeParam(), ...?customFilter};
/// }
/// ```
abstract class BaseListParam {
  final int page;
  final int limit;
  final String? sort;
  final String? order;
  final Map<String, dynamic>? filter;

  BaseListParam({
    required this.page,
    required this.limit,
    this.filter,
    this.sort,
    this.order,
  });

  /// Merge all params into query map
  Map<String, dynamic> mergeParam() {
    Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
      if (sort?.isNotEmpty ?? false) 'sort': sort,
      if (order?.isNotEmpty ?? false) 'order': order,
    };

    if (filter?.isNotEmpty ?? false) {
      params.addAll(filter!);
    }

    params.removeWhere((key, value) => value == null);

    return params;
  }
}

/// Raw UseCase that returns T directly (no Result wrapper)
/// Compatible with user's existing UseCase pattern
abstract class RawUseCase<T, P> extends BaseUseCase<T> {
  const RawUseCase() : super();

  /// Execute the use case - may throw exceptions
  Future<T> call(P params);
}

// ============================================================================
// UseCase Adapters for BaseListProBloc
// ============================================================================

/// Adapter to wrap a raw UseCase (no Result) for use with BaseListProBloc.legacyApi
/// 
/// Example:
/// ```dart
/// final bloc = BaseListProBloc<PostEntity, PostGetListParam>(
///   legacyApi: UseCaseAdapter.wrapForList(
///     useCase: getPostsUseCase,
///     paramBuilder: (page, limit, filter) => filter ?? PostGetListParam(page: page, limit: limit),
///     responseMapper: (items) => ListResponse.fromMeta(items: items.items, meta: items.meta),
///   ),
/// );
/// ```
class UseCaseAdapter {
  /// Wrap a raw UseCase into legacyApi format
  /// 
  /// - [useCase] - Your existing UseCase that returns Future of ItemsResEntity
  /// - [paramBuilder] - Function to build your param from (page, limit, filter)
  /// - [responseMapper] - Function to convert your response to ListResponse
  static Future<Result<ListResponse<T>>> Function(int page, int limit, P? filter)
      wrapForList<T, P, R>({
    required RawUseCase<R, P> useCase,
    required P Function(int page, int limit, P? filter) paramBuilder,
    required ListResponse<T> Function(R response) responseMapper,
  }) {
    return (int page, int limit, P? filter) async {
      try {
        final param = paramBuilder(page, limit, filter);
        final response = await useCase.call(param);
        return Result.success(responseMapper(response));
      } catch (e, st) {
        return Result.failure(UnknownFailure.fromException(e, st));
      }
    };
  }

  /// Simplified wrapper when UseCase uses BaseListParam-compatible params
  /// and returns ItemsResEntity-like response with .items and .meta
  static Future<Result<ListResponse<T>>> Function(int page, int limit, P? filter)
      wrapSimple<T, P extends BaseListParam>({
    required Future<dynamic> Function(P param) executor,
    required P Function(int page, int limit, P? existing) paramBuilder,
    required List<T> Function(dynamic response) itemsExtractor,
    required bool Function(dynamic response) hasMoreExtractor,
    dynamic Function(dynamic response)? metaExtractor,
  }) {
    return (int page, int limit, P? filter) async {
      try {
        final param = paramBuilder(page, limit, filter);
        final response = await executor(param);
        return Result.success(ListResponse(
          items: itemsExtractor(response),
          hasMore: hasMoreExtractor(response),
          meta: metaExtractor?.call(response),
        ));
      } catch (e, st) {
        return Result.failure(UnknownFailure.fromException(e, st));
      }
    };
  }
}

