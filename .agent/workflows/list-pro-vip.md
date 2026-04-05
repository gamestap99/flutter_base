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

---

## ⚠️ QUAN TRỌNG: BaseListProWidget đã tự động xử lý gì?

Khi dùng `BaseListProWidget`, widget **ĐÃ TỰ ĐỘNG** xử lý nhiều tác vụ. Hiểu rõ để tránh duplicate code/API calls!

### ✅ BaseListProWidget TỰ ĐỘNG xử lý (KHÔNG cần làm thủ công):

| Tính năng | Mô tả | Tại sao không cần làm thủ công |
|-----------|-------|--------------------------------|
| **Load dữ liệu ban đầu** | Gọi `bloc.load()` trong `initState()` | ❌ **KHÔNG gọi `..load()` trong BlocProvider.create!** |
| **Pull-to-refresh** | Wrap sẵn `RefreshIndicator` + gọi `bloc.refresh()` | Không cần wrap thêm RefreshIndicator |
| **Load more (pagination)** | Dùng `VisibilityDetector` auto gọi `bloc.loadMore()` khi scroll gần cuối | Không cần listen scroll manually |
| **Hiển thị loading state** | Build loading UI từ `buildLoading` callback | Không cần BlocBuilder cho loading |
| **Hiển thị error state** | Build error UI từ `buildError` callback với retry button | Không cần BlocBuilder cho error |
| **Hiển thị empty state** | Build empty UI từ `buildEmpty` callback | Không cần check items.isEmpty |
| **Scroll controller** | Tạo và quản lý ScrollController tự động | Chỉ truyền vào nếu cần share controller |
| **Re-load khi filter thay đổi** | Set `autoFilter: true` để auto reload | Không cần didUpdateWidget manually |

### ❌ SAI - Những lỗi phổ biến cần tránh:

```dart
// ❌ SAI #1: Gọi load() 2 lần
BlocProvider(
  create: (_) => MyBloc()..load(),  // API call #1
  child: BaseListProWidget(...),     // API call #2 trong initState
)

// ❌ SAI #2: Wrap thêm RefreshIndicator (đã có sẵn trong widget)
RefreshIndicator(
  onRefresh: () => bloc.refresh(),
  child: BaseListProWidget(...),  // Đã có RefreshIndicator bên trong!
)

// ❌ SAI #3: Manually gọi loadMore trong scroll listener
NotificationListener<ScrollNotification>(
  onNotification: (notification) {
    if (notification.metrics.pixels > notification.metrics.maxScrollExtent - 200) {
      bloc.loadMore();  // Widget đã auto handle load more!
    }
    return false;
  },
  child: BaseListProWidget(...),
)

// ❌ SAI #4: BlocBuilder cho loading/error (widget đã handle)
BlocBuilder<MyBloc, MyState>(
  builder: (context, state) {
    if (state.isLoading) return Loading();  // Thừa!
    if (state.isError) return Error();      // Thừa!
    return BaseListProWidget(...);
  },
)
```

### ✅ ĐÚNG - Cách dùng chính xác:

```dart
// ✅ ĐÚNG: Không gọi load(), widget tự handle
BlocProvider<BaseListProBloc<Entity, Filter>>(
  create: (_) => MyListBloc(repository: repo),  // Không có ..load()
  child: BaseListProWidget<Entity, Filter>(
    buildItem: (item, index) => ItemCard(item: item),
    buildLoading: () => LoadingSkeleton(),
    buildEmpty: () => EmptyView(),
    buildError: (failure, retry) => ErrorView(failure, onRetry: retry),
  ),
)
```

### 🔧 Khi NÊN tự gọi thủ công:

| Trường hợp | Nên làm gì |
|------------|------------|
| **Load lại sau khi create/update/delete** | Gọi `bloc.refresh()` sau thành công |
| **Filter/Search thay đổi từ UI khác** | Gọi `bloc.load(filter: newFilter)` |
| **Force refresh (bypass cache)** | Gọi `bloc.refresh(force: true)` |
| **Cần load với filter ban đầu** | Dùng `queryParameters` prop của widget |
| **Không dùng BaseListProWidget** | Phải tự gọi `bloc.load()` trong initState |

### 📌 Tóm tắt quan trọng:

```
┌─────────────────────────────────────────────────────────────────────────┐
│  Dùng BaseListProWidget      │  KHÔNG dùng BaseListProWidget           │
├─────────────────────────────────────────────────────────────────────────┤
│  ❌ KHÔNG gọi ..load()       │  ✅ PHẢI gọi ..load() trong create      │
│  ❌ KHÔNG wrap RefreshIndicator  │  ✅ PHẢI tự wrap RefreshIndicator   │
│  ❌ KHÔNG listen scroll      │  ✅ PHẢI tự handle load more            │
│  ❌ KHÔNG BlocBuilder cho    │  ✅ PHẢI tự BlocBuilder cho             │
│     loading/error            │     tất cả states                       │
└─────────────────────────────────────────────────────────────────────────┘
```

---

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

Có 2 cách tạo ListBloc - chọn phù hợp với architecture:

### Option A: Dùng Repository (Simple)

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

### Option B: Dùng GetListUseCase (Clean Architecture với Result)

Khi muốn tách biệt business logic và dùng Result pattern:

```dart
// 1. Tạo UseCase (extends ResultUseCase)
class Get[Name]sUseCase extends GetListUseCase<[Entity], [FilterType]> {
  final [Name]Repository _repository;
  
  const Get[Name]sUseCase(this._repository);
  
  @override
  Future<Result<ListResponse<[Entity]>>> call(ListParams<[FilterType]> params) {
    // Có thể thêm business logic ở đây
    return _repository.getItems(
      page: params.page,
      limit: params.limit,
      filter: params.filter,
    );
  }
}

// 2. Tạo Bloc với fetchUseCase
class [Name]ListBloc extends BaseListProBloc<[Entity], [FilterType]> {
  [Name]ListBloc({required Get[Name]sUseCase getUseCase})
      : super(
          fetchUseCase: getUseCase,
          pageSize: 20,
        );
}
```

### Option C: Dùng UseCase có sẵn (mà không wrap Result)

Khi đã có UseCase trong project (ví dụ: `UseCase<ItemsResEntity<T>, Param>`):

```dart
// UseCase có sẵn của bạn
class PostGetListUseCase extends UseCase<ItemsResEntity<PostEntity>, PostGetListParam> {
  @override
  Future<ItemsResEntity<PostEntity>> call(PostGetListParam params) => ...
}

// Tạo Bloc với legacyApi adapter
class PostListBloc extends BaseListProBloc<PostEntity, PostGetListParam> {
  PostListBloc({required PostGetListUseCase useCase})
      : super(
          legacyApi: (page, limit, filter) async {
            try {
              final param = filter ?? PostGetListParam(page: page, limit: limit);
              final result = await useCase.call(param);
              return Result.success(ListResponse.fromMeta(
                items: result.items,
                meta: result.meta,
              ));
            } catch (e, st) {
              return Result.failure(UnknownFailure.fromException(e, st));
            }
          },
        );
}
```

**So sánh các options:**
| Option | Khi nào dùng |
|--------|--------------|
| A (Repository) | Project đơn giản, không cần tách UseCase |
| B (GetListUseCase) | Clean Architecture, muốn dùng Result pattern |
| C (legacyApi adapter) | Đã có UseCase không wrap Result |

### Các UseCase classes có sẵn trong flutter_base

Tất cả các UseCase trong flutter_base đều extends `ResultUseCase` và return `Result<T>`:

```dart
// Base classes
abstract class ResultUseCase<T, P> {
  Future<Result<T>> call(P params);
}

abstract class NoParamsResultUseCase<T> {
  Future<Result<T>> call();
}
```

**Specialized UseCase classes:**

| Class | Mục đích | Signature |
|-------|----------|-----------|
| `GetListUseCase<T, F>` | Lấy danh sách có pagination | `call(ListParams<F>)` → `Result<ListResponse<T>>` |
| `GetItemUseCase<T, F>` | Lấy 1 item | `call(F filter)` → `Result<T>` |
| `CreateItemUseCase<T>` | Tạo mới item | `call(T item)` → `Result<T>` |
| `UpdateItemUseCase<T>` | Cập nhật item | `call(T item)` → `Result<T>` |
| `DeleteItemUseCase<T>` | Xóa item | `call(T item)` → `Result<void>` |

**Ví dụ implement đầy đủ:**

```dart
// GetListUseCase
class GetPostsUseCase extends GetListUseCase<PostEntity, PostFilter> {
  final PostRepository _repo;
  GetPostsUseCase(this._repo);
  
  @override
  Future<Result<ListResponse<PostEntity>>> call(ListParams<PostFilter> params) {
    return _repo.getItems(page: params.page, limit: params.limit, filter: params.filter);
  }
}

// GetItemUseCase
class GetPostUseCase extends GetItemUseCase<PostEntity, int> {
  final PostRepository _repo;
  GetPostUseCase(this._repo);
  
  @override
  Future<Result<PostEntity>> call(int id) => _repo.getById(id);
}

// CreateItemUseCase
class CreatePostUseCase extends CreateItemUseCase<PostEntity> {
  final PostRepository _repo;
  CreatePostUseCase(this._repo);
  
  @override
  Future<Result<PostEntity>> call(PostEntity post) => _repo.create(post);
}

// UpdateItemUseCase
class UpdatePostUseCase extends UpdateItemUseCase<PostEntity> {
  final PostRepository _repo;
  UpdatePostUseCase(this._repo);
  
  @override
  Future<Result<PostEntity>> call(PostEntity post) => _repo.update(post);
}

// DeleteItemUseCase  
class DeletePostUseCase extends DeleteItemUseCase<PostEntity> {
  final PostRepository _repo;
  DeletePostUseCase(this._repo);
  
  @override
  Future<Result<void>> call(PostEntity post) => _repo.delete(post.id);
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
      ), // ⚠️ KHÔNG GỌI ..load() Ở ĐÂY! BaseListProWidget sẽ tự động load.
      child: const _[Name]ListContent(),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║ ⚠️ CẢNH BÁO: KHÔNG GỌI load() TRONG BlocProvider.create!                 ║
// ║                                                                          ║
// ║ BaseListProWidget đã TỰ ĐỘNG gọi load() trong initState().               ║
// ║ Nếu bạn gọi ..load() trong BlocProvider.create, API sẽ bị gọi 2 lần!    ║
// ║                                                                          ║
// ║ ❌ SAI:  create: (_) => Bloc()..load()                                   ║
// ║ ✅ ĐÚNG: create: (_) => Bloc()                                           ║
// ╚══════════════════════════════════════════════════════════════════════════╝

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
