---
description: Tạo Form theo chuẩn Pro VIP với WFormProBloc
---

# Tạo Form Pro VIP

Workflow này hướng dẫn tạo Form sử dụng `WFormProBloc` từ package `flutter_base`.

## Prerequisites

Đảm bảo project đã có dependency:
```yaml
dependencies:
  flutter_base:
    git:
      url: https://github.com/gamestap99/flutter_base.git
      ref: main
```

## Step 1: Tạo FormRepository

Tạo file repository extend `FormRepository<T>`:

```dart
import 'package:flutter_base/flutter_base.dart';

class [Name]FormRepository extends FormRepository<[ResultType]> {
  final Api api; // hoặc data source của bạn
  
  [Name]FormRepository(this.api);

  @override
  Future<Result<[ResultType]>> submit(Map<String, dynamic> values) async {
    try {
      // Gọi API submit form
      final response = await api.submitForm(values);
      return Result.success([ResultType].fromJson(response.data));
    } on DioException catch (e, st) {
      return Result.failure(NetworkFailure.fromDioException(e, st));
    } catch (e, st) {
      return Result.failure(UnknownFailure.fromException(e, st));
    }
  }

  @override
  Future<Result<void>> saveDraft(Map<String, dynamic> values) async {
    // Optional: lưu draft vào local storage
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
```

## Step 2: Tạo FormBloc

Tạo BLoC extend `WFormProBloc<T>`:

```dart
import 'package:flutter_base/flutter_base.dart';

class [Name]FormBloc extends WFormProBloc<[ResultType]> {
  [Name]FormBloc({required [Name]FormRepository repository})
      : super(
          repository: repository,
          enableAutoSave: false, // true nếu muốn auto-save draft
          
          // Sync validators - chạy ngay khi user nhập
          syncValidators: {
            'field_name': [requiredValidator],
            'email': [requiredValidator, emailValidator],
            'phone': [requiredValidator, phoneValidator],
            'password': [requiredValidator, passwordStrengthValidator],
            'confirm_password': [requiredValidator, confirmPasswordValidator('password')],
          },
          
          // Field dependencies - clear field phụ thuộc khi field chính thay đổi
          fieldDependencies: {
            'province': ['district', 'ward'], // Clear district và ward khi province thay đổi
            'district': ['ward'],
          },
        );
}
```

### Built-in Validators có sẵn:
- `requiredValidator` - Bắt buộc nhập
- `emailValidator` - Định dạng email
- `phoneValidator` - Định dạng SĐT Việt Nam
- `minLengthValidator(n)` - Tối thiểu n ký tự
- `maxLengthValidator(n)` - Tối đa n ký tự
- `passwordStrengthValidator` - Mật khẩu mạnh
- `confirmPasswordValidator(field)` - Xác nhận password
- `numberRangeValidator(min, max)` - Số trong khoảng
- `patternValidator(regex, msg)` - Regex pattern

## Step 3: Tạo Form Widget

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/flutter_base.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class [Name]FormScreen extends StatelessWidget {
  const [Name]FormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => [Name]FormBloc(
        repository: [Name]FormRepository(context.read<Api>()),
      ),
      child: const _[Name]FormContent(),
    );
  }
}

class _[Name]FormContent extends StatelessWidget {
  const _[Name]FormContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('[Form Title]')),
      body: BlocConsumer<[Name]FormBloc, WFormProState<[ResultType]>>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.isSuccess) {
            // Handle success - navigate, show message, etc.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thành công!')),
            );
          } else if (state.isError && state.failure != null) {
            // Handle error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure!.message)),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<[Name]FormBloc>();
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: bloc.formKey,
              child: Column(
                children: [
                  // Text field example
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: state.getFieldError('email'),
                    ),
                    onChanged: (v) => bloc.setValue('email', v),
                  ),
                  
                  // Dynamic select example
                  DropdownButtonFormField<String>(
                    value: state.getValue('province') as String?,
                    items: provinces.map((e) => DropdownMenuItem(
                      value: e.id,
                      child: Text(e.name),
                    )).toList(),
                    onChanged: (v) => bloc.setValue('province', v),
                    decoration: InputDecoration(
                      labelText: 'Tỉnh/Thành phố',
                      errorText: state.getFieldError('province'),
                    ),
                  ),
                  
                  // Dependent field - disabled khi chưa chọn province
                  DropdownButtonFormField<String>(
                    value: state.getValue('district') as String?,
                    items: getDistricts(state.getValue('province')).map((e) => 
                      DropdownMenuItem(value: e.id, child: Text(e.name)),
                    ).toList(),
                    onChanged: state.getValue('province') != null 
                      ? (v) => bloc.setValue('district', v)
                      : null,
                    decoration: InputDecoration(
                      labelText: 'Quận/Huyện',
                      errorText: state.getFieldError('district'),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Submit button
                  ElevatedButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () => bloc.submit(showDialog: true),
                    child: state.isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text('Submit'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

## API Methods của WFormProBloc

```dart
final bloc = context.read<[Name]FormBloc>();

// Get/Set values
bloc.getValue('email');                    // Lấy giá trị field
bloc.setValue('email', 'test@email.com');  // Set giá trị field
bloc.setValues({'name': 'John', 'age': 25}); // Set nhiều fields

// Validation
bloc.validate();           // Validate tất cả fields
bloc.blurField('email');   // Đánh dấu field đã touched

// Form actions
bloc.submit(showDialog: true);  // Submit form
bloc.reset();                   // Reset form về trạng thái ban đầu

// Draft management
bloc.loadDraft();   // Load draft từ storage
```

## State Properties

```dart
state.isValid           // Form hợp lệ không?
state.isDirty           // Đã có thay đổi chưa?
state.isSubmitting      // Đang submit?
state.isSuccess         // Submit thành công?
state.isError           // Submit lỗi?
state.values            // Map tất cả giá trị
state.allErrors         // Map tất cả lỗi
state.result            // Kết quả submit (nếu success)
state.failure           // Failure object (nếu error)

state.getValue('email')           // Lấy giá trị 1 field
state.getFieldError('email')      // Lấy lỗi 1 field
state.getFieldState('email')      // Lấy FieldState object
```

## Ví dụ tham khảo

Xem file example đầy đủ tại:
- `flutter_base/example/lib/screens/form_pro_example.dart`
- `flutter_base/lib/src/compoments/bloc_pro_examples.dart`
