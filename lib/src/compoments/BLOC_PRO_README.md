# BLoC Pro VIP Documentation

Bộ thư viện BLoC nâng cao với các tính năng enterprise-grade cho Flutter.

## Mục lục

- [Cài đặt](#cài-đặt)
- [Core Concepts](#core-concepts)
- [List Pro](#list-pro)
- [Item Pro](#item-pro)
- [Form Pro](#form-pro)
- [Utilities](#utilities)
- [Migration Guide](#migration-guide)

---

## Cài đặt

BLoC Pro VIP đã được tích hợp sẵn trong package `flutter_base`. Import như sau:

```dart
import 'package:flutter_base/flutter_base.dart';
```

Dependencies cần thiết (đã có trong pubspec.yaml):
- `flutter_bloc: ^9.0.0`
- `bloc_concurrency: ^0.2.0`
- `equatable: ^2.0.5`

---

## Core Concepts

### 1. Result Pattern

Thay thế try-catch với type-safe error handling:

```dart
// Trước (old)
try {
  final user = await api.getUser(id);
  return user;
} catch (e) {
  throw e; // dynamic error - không type-safe
}

// Sau (Pro VIP)
Future<Result<User>> getUser(String id) async {
  try {
    final response = await api.get('/users/$id');
    return Result.success(User.fromJson(response.data));
  } on DioException catch (e, st) {
    return Result.failure(NetworkFailure.fromDioException(e, st));
  }
}

// Sử dụng
final result = await getUser('123');
result.when(
  success: (user) => showProfile(user),
  failure: (f) => showError(f.userFriendlyMessage),
);
```

### 2. Failure Types

```dart
sealed class Failure {
  // NetworkFailure - lỗi mạng, timeout, no internet
  // ServerFailure - lỗi server 5xx
  // ClientFailure - lỗi client 4xx
  // ValidationFailure - lỗi validation với fieldErrors
  // CacheFailure - lỗi đọc/ghi cache
  // ParseFailure - lỗi parse JSON
  // UnknownFailure - lỗi không xác định
}

// Mỗi failure có:
failure.message          // Message chính
failure.code             // Error code (optional)
failure.isRetryable      // Có nên retry không
failure.userFriendlyMessage  // Message hiển thị cho user
```

### 3. Sealed Class States

Thay vì 11 enum values, giờ chỉ có 4 states với pattern matching:

```dart
return switch (state) {
  ListInitial() => buildInitial(),
  ListLoading(:final previousItems) => buildLoading(previousItems),
  ListLoaded(:final items, :final hasMore) => buildList(items, hasMore),
  ListError(:final failure) => buildError(failure),
};
```

---

## List Pro

### Tạo Repository

```dart
class ProductRepository implements ListRepository<Product, ProductFilter> {
  final Dio dio;
  
  ProductRepository(this.dio);

  @override
  Future<Result<ListResponse<Product>>> getItems({
    required int page,
    required int limit,
    ProductFilter? filter,
  }) async {
    try {
      final response = await dio.get('/products', queryParameters: {
        'page': page,
        'limit': limit,
        ...?filter?.toQueryParams(),
      });
      
      return Result.success(ListResponse(
        items: (response.data['data'] as List)
            .map((e) => Product.fromJson(e)).toList(),
        hasMore: response.data['meta']['next_page'] != null,
        totalCount: response.data['meta']['total'],
      ));
    } on DioException catch (e, st) {
      return Result.failure(NetworkFailure.fromDioException(e, st));
    }
  }

  @override
  Future<Result<Product>> createItem(Product item) async { ... }
  
  @override
  Future<Result<Product>> updateItem(Product item) async { ... }
  
  @override
  Future<Result<void>> deleteItem(Product item) async { ... }
}
```

### Tạo BLoC

```dart
class ProductListBloc extends BaseListProBloc<Product, ProductFilter> {
  ProductListBloc({required ProductRepository repository})
      : super(
          repository: repository,
          pageSize: 20,
          cacheSize: 5,
          cacheTTL: const Duration(minutes: 5),
          retryConfig: const RetryConfig(maxAttempts: 3),
          onAnalytics: (event) => print('Analytics: $event'),
        );
}
```

### Sử dụng Widget

```dart
BlocProvider(
  create: (_) => ProductListBloc(repository: repo)..load(),
  child: BaseListProWidget<Product, ProductFilter>(
    buildItem: (product, index) => ProductCard(product),
    buildLoading: () => ProductSkeleton(),
    buildEmpty: () => EmptyView(text: 'Không có sản phẩm'),
    buildError: (failure, retry) => ErrorView(
      message: failure.message,
      onRetry: retry,
    ),
    padding: EdgeInsets.all(16),
    isGrid: true,
    crossAxisCount: 2,
  ),
)
```

### API Methods

```dart
final bloc = context.read<ProductListBloc>();

// Load data
bloc.load(filter: ProductFilter(category: 'electronics'));

// Refresh
bloc.refresh();

// Load more (thường được gọi tự động bởi widget)
bloc.loadMore();

// Search với debounce
bloc.search('iphone', debounceMs: 300);

// Optimistic delete
bloc.deleteItem(product, predicate: (p) => p.id == product.id, optimistic: true);

// Optimistic add
bloc.addItem(newProduct, position: 0, optimistic: true);

// Update item
bloc.updateItem(updatedProduct, predicate: (p) => p.id == product.id);

// Clear cache
bloc.clearCache();

// Reset to initial
bloc.reset();
```

---

## Item Pro

### Tạo BLoC

```dart
class ProductDetailBloc extends BaseItemProBloc<Product, int> {
  ProductDetailBloc({required ProductDetailRepository repository})
      : super(
          repository: repository,
          staleDuration: const Duration(minutes: 5),
          retryConfig: const RetryConfig(maxAttempts: 3),
        );
}
```

### Sử dụng Widget

```dart
BlocProvider(
  create: (_) => ProductDetailBloc(repository: repo)..load(filter: productId),
  child: BaseItemProWidget<Product, int>(
    queryParameters: productId,
    buildLoadedSlivers: (product, state) => [
      SliverAppBar(
        title: Text(product.name),
        expandedHeight: 200,
      ),
      SliverToBoxAdapter(
        child: ProductInfo(product),
      ),
    ],
    buildLoading: () => ProductDetailSkeleton(),
    buildError: (failure, retry) => ErrorView(failure.message, onRetry: retry),
    autoRefresh: true, // Tự động refresh khi queryParameters thay đổi
  ),
)
```

### API Methods

```dart
final bloc = context.read<ProductDetailBloc>();

// Load
bloc.load(filter: productId);

// Smart refresh (skip nếu data vẫn fresh)
bloc.refresh(force: false);

// Force refresh
bloc.refresh(force: true);

// Optimistic update
bloc.optimisticUpdate(updatedProduct, persistToServer: true);

// Patch (partial update)
bloc.patch(
  {'price': 99.99},
  applyChanges: (current, changes) => current.copyWith(
    price: changes['price'],
  ),
);

// Set item directly
bloc.setItem(product);
```

---

## Form Pro

### Tạo BLoC với Validators

```dart
class RegistrationFormBloc extends WFormProBloc<User> {
  RegistrationFormBloc({
    required RegistrationRepository repository,
    required Dio dio,
  }) : super(
          repository: repository,
          enableAutoSave: true,
          autoSaveDebounce: const Duration(seconds: 30),
          
          // Sync validators
          syncValidators: {
            'name': [requiredValidator, minLengthValidator(2)],
            'email': [requiredValidator, emailValidator],
            'password': [requiredValidator, passwordStrengthValidator],
            'confirmPassword': [requiredValidator, confirmPasswordValidator('password')],
          },
          
          // Async validators (check email exists, etc.)
          asyncValidators: {
            'email': EmailExistsValidator(dio),
          },
          
          // Field dependencies
          fieldDependencies: {
            'province': ['district', 'ward'], // Clear district & ward khi province thay đổi
            'district': ['ward'],
          },
        );
}
```

### Built-in Validators

```dart
// Sync validators
requiredValidator           // Bắt buộc nhập
emailValidator              // Định dạng email
phoneValidator              // Định dạng SĐT Việt Nam
minLengthValidator(n)       // Tối thiểu n ký tự
maxLengthValidator(n)       // Tối đa n ký tự
passwordStrengthValidator   // Mật khẩu mạnh (8+ chars, upper, lower, number)
confirmPasswordValidator(field)  // Xác nhận mật khẩu
numberRangeValidator(min, max)   // Số trong khoảng
patternValidator(regex, msg)     // Regex pattern

// Async validators
EmailExistsValidator        // Check email tồn tại
UsernameExistsValidator     // Check username tồn tại
PhoneExistsValidator        // Check SĐT tồn tại
ApiValidator               // Custom API validation
```

### Sử dụng trong Widget

```dart
BlocBuilder<RegistrationFormBloc, WFormProState<User>>(
  builder: (context, state) {
    final bloc = context.read<RegistrationFormBloc>();
    
    return Form(
      key: bloc.formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Email',
              // Show loading indicator khi đang validate async
              suffixIcon: state.getFieldState('email').isValidating
                  ? CircularProgressIndicator()
                  : null,
            ),
            onChanged: (v) => bloc.setValue('email', v),
            validator: (_) => state.getFieldError('email'),
          ),
          
          // Submit button
          ElevatedButton(
            onPressed: state.isSubmitting ? null : () => bloc.submit(),
            child: state.isSubmitting
                ? CircularProgressIndicator()
                : Text('Đăng ký'),
          ),
          
          // Auto-save indicator
          if (state.lastAutoSaved != null)
            Text('Đã lưu lúc ${state.lastAutoSaved}'),
        ],
      ),
    );
  },
)
```

### API Methods

```dart
final bloc = context.read<RegistrationFormBloc>();

// Get/Set values
bloc.getValue('email');
bloc.setValue('email', 'test@example.com');
bloc.setValues({'name': 'John', 'email': 'john@example.com'});

// Validation
bloc.validate();  // Validate all fields
final values = bloc.getValuesIfValid(); // Get values if form is valid

// Submit
bloc.submit(showDialog: true);

// Reset
bloc.reset();

// Draft management
bloc.loadDraft();
```

---

## Utilities

### Retry Configuration

```dart
// Default: 3 attempts, 500ms delay, 2x multiplier
const RetryConfig()

// Aggressive: cho operations quan trọng
const RetryConfig.aggressive

// Conservative: cho operations ít quan trọng
const RetryConfig.conservative

// No retry
const RetryConfig.none

// Custom
RetryConfig(
  maxAttempts: 5,
  initialDelay: Duration(milliseconds: 200),
  multiplier: 1.5,
  maxDelay: Duration(seconds: 30),
  useJitter: true, // Thêm random để tránh thundering herd
)
```

### LRU Cache

```dart
final cache = LRUCache<String, Data>(
  maxSize: 10,
  defaultTtl: Duration(minutes: 5),
  onEvict: (key, value) => print('Evicted: $key'),
);

cache.put('key', data);
final cached = cache.get('key'); // null nếu expired hoặc không có

// Get or create pattern
final data = await cache.getOrCreate('key', () async {
  return await fetchFromApi();
});
```

### BLoC Observer

```dart
void main() {
  Bloc.observer = BlocProObserver(
    enableLogging: kDebugMode,
    logLevel: BlocLogLevel.info,
    onTransitionCallback: (bloc, transition) {
      // Send to analytics
    },
    onErrorCallback: (bloc, error, stackTrace) {
      // Send to crash reporting
    },
  );
  
  runApp(MyApp());
}
```

---

## Migration Guide

### Từ BaseListBloc sang BaseListProBloc

```dart
// Trước
class MyBloc extends BaseListBloc<MyItem, MyFilter> {
  MyBloc() : super();
  
  @override
  Future<ItemsResEntity<MyItem>> onApiCall(int page, int limit, MyFilter? filter) {
    return api.getItems(page, limit, filter);
  }
}

// Sau
class MyBloc extends BaseListProBloc<MyItem, MyFilter> {
  MyBloc({required MyRepository repository})
      : super(repository: repository);
}

// Hoặc sử dụng legacy API
class MyBloc extends BaseListProBloc<MyItem, MyFilter> {
  MyBloc() : super(
    legacyApi: (page, limit, filter) async {
      try {
        final res = await api.getItems(page, limit, filter);
        return Result.success(ListResponse(
          items: res.items,
          hasMore: res.meta?.nextPage != null,
        ));
      } catch (e, st) {
        return Result.failure(UnknownFailure.fromException(e, st));
      }
    },
  );
}
```

### State Pattern Matching

```dart
// Trước (enum checking)
if (state.status == EBlocStateStatus.loading) { ... }
if (state.status == EBlocStateStatus.success) { ... }

// Sau (sealed class pattern matching)
switch (state) {
  case ListLoading():
    return buildLoading();
  case ListLoaded(:final items):
    return buildList(items);
  // ... exhaustive - compiler ensures all cases handled
}
```

---

## Best Practices

1. **Luôn sử dụng Repository Pattern** - Giúp testable và maintainable
2. **Configure Retry phù hợp** - Critical operations dùng aggressive, background dùng conservative
3. **Sử dụng Cache TTL hợp lý** - Data hay thay đổi: 1-2 phút, static data: 24 giờ
4. **Enable Analytics** - Track cache hit/miss, errors để optimize
5. **Optimistic Updates** - Cho UX tốt hơn, nhưng handle rollback properly
6. **Auto-save Form Drafts** - Prevent data loss khi user navigate away

---

## Troubleshooting

### Cache không hoạt động
- Kiểm tra `cacheKeyBuilder` có trả về unique key cho mỗi filter không
- Kiểm tra TTL có quá ngắn không

### Retry không hoạt động
- Kiểm tra `failure.isRetryable` - chỉ NetworkFailure và ServerFailure mới retry được
- Kiểm tra `maxAttempts` > 0

### Form validation không chạy
- Đảm bảo đã add validator vào `syncValidators` hoặc `asyncValidators`
- Kiểm tra field name match với key trong validators map
