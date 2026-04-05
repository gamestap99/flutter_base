---
description: Tạo Item Detail theo chuẩn Pro VIP với BaseItemProBloc
---

# Tạo Item Pro VIP

Workflow này hướng dẫn tạo Item Detail sử dụng `BaseItemProBloc` + `BaseItemProWidget` từ package `flutter_base`.

## Prerequisites

Đảm bảo project đã có dependency:
```yaml
dependencies:
  flutter_base:
    git:
      url: https://github.com/gamestap99/flutter_base.git
      ref: main
```

## Step 1: Tạo ItemRepository

Tạo file repository implement `ItemRepository<T, F>`:

```dart
import 'package:flutter_base/flutter_base.dart';

class [Name]DetailRepository implements ItemRepository<[Entity], [IdType]> {
  final Api api;
  
  [Name]DetailRepository(this.api);

  @override
  Future<Result<[Entity]>> getItem([IdType] id) async {
    try {
      final response = await api.getDetail(id);
      return Result.success([Entity].fromJson(response.data));
    } on DioException catch (e, st) {
      return Result.failure(NetworkFailure.fromDioException(e, st));
    } catch (e, st) {
      return Result.failure(UnknownFailure.fromException(e, st));
    }
  }

  @override
  Future<Result<[Entity]>> updateItem([Entity] item) async {
    try {
      final response = await api.update(item.id, item.toJson());
      return Result.success([Entity].fromJson(response.data));
    } catch (e, st) {
      return Result.failure(UnknownFailure.fromException(e, st));
    }
  }

  @override
  Future<Result<[Entity]>> patchItem([Entity] item, Map<String, dynamic> changes) async {
    try {
      final response = await api.patch(item.id, changes);
      return Result.success([Entity].fromJson(response.data));
    } catch (e, st) {
      return Result.failure(UnknownFailure.fromException(e, st));
    }
  }

  @override
  Future<Result<void>> deleteItem([Entity] item) async {
    try {
      await api.delete(item.id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(UnknownFailure.fromException(e, st));
    }
  }
}
```

## Step 2: Tạo ItemBloc

Tạo BLoC extend `BaseItemProBloc<T, F>`:

```dart
import 'package:flutter_base/flutter_base.dart';

class [Name]DetailBloc extends BaseItemProBloc<[Entity], [IdType]> {
  [Name]DetailBloc({required [Name]DetailRepository repository})
      : super(
          repository: repository,
          staleDuration: const Duration(minutes: 5),  // Thời gian data coi là stale
          retryConfig: const RetryConfig(
            maxAttempts: 3,
            initialDelay: Duration(seconds: 1),
          ),
          onAnalytics: (event) {
            debugPrint('📊 [Name]Detail: $event');
          },
        );
}
```

## Step 3: Tạo Screen với BaseItemProWidget

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/flutter_base.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class [Name]DetailScreen extends StatelessWidget {
  final [IdType] id;
  
  const [Name]DetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    // QUAN TRỌNG: Phải dùng BlocProvider<BaseItemProBloc<Entity, IdType>>
    // để BaseItemProWidget có thể tìm thấy bloc
    return BlocProvider<BaseItemProBloc<[Entity], [IdType]>>(
      create: (_) => [Name]DetailBloc(
        repository: [Name]DetailRepository(context.read<Api>()),
      )..load(filter: id), // Load với ID
      child: _[Name]DetailContent(id: id),
    );
  }
}

class _[Name]DetailContent extends StatelessWidget {
  final [IdType] id;
  
  const _[Name]DetailContent({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[Detail Title]'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            // Dùng BaseItemProBloc<Entity, IdType> thay vì tên Bloc cụ thể
            onPressed: () => context.read<BaseItemProBloc<[Entity], [IdType]>>().refresh(force: true),
          ),
        ],
      ),
      body: BaseItemProWidget<[Entity], [IdType]>(
        queryParameters: id,
        autoRefresh: true,  // Tự động refresh khi data stale
        
        // Build loaded content as slivers
        buildLoadedSlivers: (item, state) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(item.description),
                  
                  // State info
                  if (state is ItemLoaded<[Entity]>) ...[
                    const SizedBox(height: 16),
                    Text('Loaded at: ${state.loadedAt}'),
                    Text('Is stale: ${state.isStale}'),
                  ],
                  
                  // Actions
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Edit item
                    },
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ),
          ),
        ],
        
        // Custom loading state
        buildLoading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        
        // Custom error state với retry
        buildError: (failure, retry) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(failure.message),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: retry,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Hoặc dùng buildCustomLoaded thay vì Slivers

```dart
BaseItemProWidget<[Entity], [IdType]>(
  queryParameters: id,
  
  // Dùng custom loaded builder (không dùng slivers)
  buildCustomLoaded: (item, onRefresh) => RefreshIndicator(
    onRefresh: onRefresh,
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Text(item.name),
          Text(item.description),
        ],
      ),
    ),
  ),
  
  buildLoading: () => const LoadingWidget(),
  buildError: (failure, retry) => ErrorWidget(failure, retry),
)
```

## API Methods của BaseItemProBloc

```dart
final bloc = context.read<[Name]DetailBloc>();

// Load & Refresh
bloc.load(filter: id);                 // Load item theo ID
bloc.refresh();                        // Refresh (chỉ khi stale hoặc error)
bloc.refresh(force: true);             // Force refresh

// Update operations
bloc.update(updatedItem);              // Full update
bloc.patch({'status': 'active'});      // Partial update

// Optimistic update
bloc.optimisticUpdate(
  optimisticItem: tempItem,
  operation: () => api.update(item),
);

// Delete
bloc.delete();                         // Delete item

// State management
bloc.set(item);                        // Set item manually
bloc.reset();                          // Reset về initial state
```

## State Pattern Matching

```dart
BlocBuilder<[Name]DetailBloc, BaseItemProState<[Entity]>>(
  builder: (context, state) {
    return switch (state) {
      ItemInitial() => const SizedBox(),
      ItemLoading(:final previousItem) => previousItem != null
          ? DetailView(item: previousItem, isLoading: true)
          : const LoadingWidget(),
      ItemLoaded(:final item, :final isStale, :final isUpdating) =>
          DetailView(item: item, isUpdating: isUpdating),
      ItemError(:final failure, :final previousItem) =>
          previousItem != null
              ? DetailView(item: previousItem, error: failure)
              : ErrorWidget(failure),
    };
  },
)
```

## State Properties

```dart
state.item              // Item hiện tại (nullable)
state.hasItem           // Có item không?
state.isLoading         // Đang loading?
state.isLoaded          // Đã load xong?
state.isError           // Có lỗi?
state.isRefreshing      // Đang refresh?
state.isUpdating        // Đang update?
state.failure           // Failure object (nếu error)
state.asLoaded          // Cast sang ItemLoaded (throws nếu không phải)
state.asLoadedOrNull    // Cast sang ItemLoaded hoặc null

// Chỉ có trong ItemLoaded state:
state.asLoaded.loadedAt  // Thời điểm load
state.asLoaded.isStale   // Data đã cũ chưa?
```

## Ví dụ tham khảo

Xem file example đầy đủ tại:
- `flutter_base/example/lib/screens/item_pro_example.dart`
- `flutter_base/lib/src/compoments/bloc_pro_examples.dart`
