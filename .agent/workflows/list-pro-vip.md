---
description: Tạo List theo chuẩn Pro VIP với BaseListProBloc
---

# Tạo List Pro VIP

Workflow này hướng dẫn tạo List sử dụng `BaseListProBloc` + `BaseListProWidget` từ package `flutter_base`.

## Prerequisites

Đảm bảo project đã có dependency:
```yaml
dependencies:
  flutter_base:
    git:
      url: https://github.com/gamestap99/flutter_base.git
      ref: main
```

## Step 1: Tạo ListRepository

Tạo file repository implement `ListRepository<T, F>`:

```dart
import 'package:flutter_base/flutter_base.dart';

class [Name]Repository implements ListRepository<[Entity], [FilterType]> {
  final Api api;
  
  [Name]Repository(this.api);

  @override
  Future<Result<ListResponse<[Entity]>>> getItems({
    required int page,
    required int limit,
    [FilterType]? filter,
  }) async {
    try {
      final response = await api.getList(
        page: page,
        limit: limit,
        filter: filter,
      );
      
      return Result.success(ListResponse(
        items: response.data.map((e) => [Entity].fromJson(e)).toList(),
        hasMore: response.meta.nextPage != null,
        totalCount: response.meta.total,
        currentPage: page,
        meta: response.meta,
      ));
    } on DioException catch (e, st) {
      return Result.failure(NetworkFailure.fromDioException(e, st));
    } catch (e, st) {
      return Result.failure(UnknownFailure.fromException(e, st));
    }
  }

  @override
  Future<Result<[Entity]>> createItem([Entity] item) async {
    try {
      final response = await api.create(item.toJson());
      return Result.success([Entity].fromJson(response.data));
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
  Future<Result<void>> deleteItem([Entity] item) async {
    try {
      await api.delete(item.id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(UnknownFailure.fromException(e, st));
    }
  }

  @override
  Future<Result<void>> deleteItems(List<[Entity]> items) async {
    for (final item in items) {
      final result = await deleteItem(item);
      if (result.isFailure) return result;
    }
    return const Result.success(null);
  }
}
```

## Step 2: Tạo ListBloc

Tạo BLoC extend `BaseListProBloc<T, F>`:

```dart
import 'package:flutter_base/flutter_base.dart';

class [Name]ListBloc extends BaseListProBloc<[Entity], [FilterType]> {
  [Name]ListBloc({required [Name]Repository repository})
      : super(
          repository: repository,
          pageSize: 20,                              // Số item mỗi trang
          cacheTTL: const Duration(minutes: 5),     // Thời gian cache
          retryConfig: const RetryConfig(           // Cấu hình retry
            maxAttempts: 3,
            initialDelay: Duration(seconds: 1),
          ),
          onAnalytics: (event) {                    // Analytics callback
            debugPrint('📊 [Name]List: $event');
          },
        );
}
```

## Step 3: Tạo Screen với BaseListProWidget

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/flutter_base.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class [Name]ListScreen extends StatelessWidget {
  const [Name]ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // QUAN TRỌNG: Phải dùng BlocProvider<BaseListProBloc<Entity, Filter>>
    // để BaseListProWidget có thể tìm thấy bloc
    return BlocProvider<BaseListProBloc<[Entity], [FilterType]>>(
      create: (_) => [Name]ListBloc(
        repository: [Name]Repository(context.read<Api>()),
      )..load(), // Load ngay khi khởi tạo
      child: const _[Name]ListContent(),
    );
  }
}

class _[Name]ListContent extends StatelessWidget {
  const _[Name]ListContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[List Title]'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            // Dùng BaseListProBloc<Entity, Filter> thay vì tên Bloc cụ thể
            onPressed: () => context.read<BaseListProBloc<[Entity], [FilterType]>>().refresh(),
          ),
        ],
      ),
      body: BaseListProWidget<[Entity], [FilterType]>(
        // Build từng item
        buildItem: (item, index) => _ItemCard(item: item),
        
        // Custom loading state
        buildLoading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        
        // Custom empty state
        buildEmpty: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Không có dữ liệu'),
            ],
          ),
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
        
        // Layout options
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final [Entity] item;
  
  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(item.name),
        subtitle: Text(item.description),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to detail
        },
      ),
    );
  }
}

## Step 4: Sử dụng với NestedScrollView (headerBuilder)

Khi cần custom scroll container (ví dụ: `NestedScrollView` với `SliverAppBar` phức tạp), sử dụng `headerBuilder`:

```dart
class _[Name]ListContent extends StatelessWidget {
  const _[Name]ListContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseListProWidget<[Entity], [FilterType]>(
        buildItem: (item, index) => _ItemCard(item: item),
        
        // Custom headerBuilder cho NestedScrollView
        headerBuilder: ({
          required slivers,
          required scrollController,
          required refreshIndicatorKey,
          required onRefresh,
        }) {
          return NestedScrollView(
            controller: scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                title: const Text('[List Title]'),
                pinned: true,
                floating: true,
                forceElevated: innerBoxIsScrolled,
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    'https://example.com/header.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => context.read<BaseListProBloc<[Entity], [FilterType]>>().refresh(),
                  ),
                ],
              ),
              // Thêm các sliver header khác nếu cần
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Header Content'),
                ),
              ),
            ],
            body: RefreshIndicator(
              key: refreshIndicatorKey,
              onRefresh: onRefresh,
              child: CustomScrollView(
                slivers: slivers,
              ),
            ),
          );
        },
        
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}
```

**Tham số headerBuilder nhận vào:**
- `slivers`: List các sliver widgets (buildTop, content, loadMore indicator)
- `scrollController`: ScrollController để quản lý scroll
- `refreshIndicatorKey`: Key cho RefreshIndicator  
- `onRefresh`: Function gọi khi pull-to-refresh

## API Methods của BaseListProBloc

```dart
final bloc = context.read<[Name]ListBloc>();

// Load & Refresh
bloc.load();                          // Load lần đầu
bloc.load(filter: myFilter);          // Load với filter
bloc.refresh();                       // Pull to refresh
bloc.refresh(force: true);            // Force refresh (bypass cache)
bloc.loadMore();                      // Load more (pagination)

// Search
bloc.search('keyword');               // Search với debounce 300ms
bloc.search('keyword', debounce: Duration(milliseconds: 500));

// CRUD operations
bloc.addItem(newItem);                // Thêm item vào đầu list
bloc.updateItem(updatedItem);         // Cập nhật item
bloc.removeItem(item);                // Xóa item
bloc.removeItems([item1, item2]);     // Xóa nhiều items

// Optimistic updates
bloc.optimisticUpdate(               // Update lạc quan (rollback nếu lỗi)
  optimisticItem: tempItem,
  operation: () => api.update(item),
);
```

## State Pattern Matching

```dart
BlocBuilder<[Name]ListBloc, BaseListProState<[Entity]>>(
  builder: (context, state) {
    return switch (state) {
      ListInitial() => const SizedBox(),
      ListLoading(:final previousItems) => previousItems.isEmpty
          ? const LoadingWidget()
          : ListView(children: previousItems.map(buildItem).toList()),
      ListLoaded(:final items, :final hasMore, :final isLoadingMore) =>
          ListView.builder(
            itemCount: items.length + (hasMore ? 1 : 0),
            itemBuilder: (_, i) => i < items.length
                ? buildItem(items[i])
                : const LoadingMoreIndicator(),
          ),
      ListError(:final failure, :final previousItems) =>
          ErrorWidget(failure, previousItems),
    };
  },
)
```

## State Properties

```dart
state.items             // List items hiện tại
state.hasItems          // Có items không?
state.isLoading         // Đang loading?
state.isLoaded          // Đã load xong?
state.isError           // Có lỗi?
state.isRefreshing      // Đang refresh?
state.isLoadingMore     // Đang load more?
state.hasMore           // Còn data để load thêm?
state.failure           // Failure object (nếu error)
state.asLoaded          // Cast sang ListLoaded (throws nếu không phải)
state.asLoadedOrNull    // Cast sang ListLoaded hoặc null
```

## Ví dụ tham khảo

Xem file example đầy đủ tại:
- `flutter_base/example/lib/screens/list_pro_example.dart`
- `flutter_base/lib/src/compoments/bloc_pro_examples.dart`
