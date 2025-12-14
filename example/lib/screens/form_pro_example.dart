import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/flutter_base.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/project_repository.dart';

/// Example screen demonstrating WFormProBloc
/// Shows the new Form Pro architecture with:
/// - Sync validators
/// - Async validators
/// - Field dependencies
/// - Auto-save draft
/// - Repository pattern for submission
class FormProExampleScreen extends StatelessWidget {
  const FormProExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegistrationFormBloc(
        repository: DemoFormRepository(),
      ),
      child: const _FormProExampleContent(),
    );
  }
}

/// Registration form BLoC with validators
class RegistrationFormBloc extends WFormProBloc<Map<String, dynamic>> {
  RegistrationFormBloc({required DemoFormRepository repository})
      : super(
          repository: repository,
          enableAutoSave: false,
          syncValidators: {
            'name': [requiredValidator, minLengthValidator(2)],
            'email': [requiredValidator, emailValidator],
            'phone': [requiredValidator, phoneValidator],
            'password': [requiredValidator, passwordStrengthValidator],
            'confirmPassword': [requiredValidator, confirmPasswordValidator('password')],
            'province': [requiredValidator],
            'district': [requiredValidator],
          },
          fieldDependencies: {
            'province': ['district'],
          },
        );
}

class _FormProExampleContent extends StatelessWidget {
  const _FormProExampleContent();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Form Pro Example'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Submit'),
          onPressed: () {
            context.read<RegistrationFormBloc>().submit(showDialog: true);
          },
        ),
      ),
      child: Material(
        child: SafeArea(
          child: BlocConsumer<RegistrationFormBloc, WFormProState<Map<String, dynamic>>>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) {
              if (state.isSuccess && state.result != null) {
                showCupertinoDialog(
                  context: context,
                  builder: (_) => CupertinoAlertDialog(
                    title: const Text('Thành công!'),
                    content: const Text('Form đã được submit thành công.'),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('OK'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              } else if (state.isError && state.failure != null) {
                showCupertinoDialog(
                  context: context,
                  builder: (_) => CupertinoAlertDialog(
                    title: const Text('Lỗi'),
                    content: Text(state.failure!.message),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('OK'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              }
            },
            builder: (context, state) {
              final bloc = context.read<RegistrationFormBloc>();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: bloc.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Đăng ký tài khoản',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.label.resolveFrom(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vui lòng điền đầy đủ thông tin bên dưới',
                        style: TextStyle(
                          color: CupertinoColors.secondaryLabel.resolveFrom(context),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Name field
                      _FormField(
                        label: 'Họ tên',
                        error: state.getFieldError('name'),
                        isValidating: state.getFieldState('name').isValidating,
                        child: CupertinoTextField(
                          placeholder: 'Nhập họ tên',
                          padding: const EdgeInsets.all(12),
                          onChanged: (v) => bloc.setValue('name', v),
                          onEditingComplete: () => bloc.blurField('name'),
                        ),
                      ),

                      // Email field
                      _FormField(
                        label: 'Email',
                        error: state.getFieldError('email'),
                        isValidating: state.getFieldState('email').isValidating,
                        child: CupertinoTextField(
                          placeholder: 'Nhập email',
                          keyboardType: TextInputType.emailAddress,
                          padding: const EdgeInsets.all(12),
                          onChanged: (v) => bloc.setValue('email', v),
                          onEditingComplete: () => bloc.blurField('email'),
                        ),
                      ),

                      // Phone field
                      _FormField(
                        label: 'Số điện thoại',
                        error: state.getFieldError('phone'),
                        isValidating: state.getFieldState('phone').isValidating,
                        child: CupertinoTextField(
                          placeholder: 'Nhập số điện thoại',
                          keyboardType: TextInputType.phone,
                          padding: const EdgeInsets.all(12),
                          onChanged: (v) => bloc.setValue('phone', v),
                          onEditingComplete: () => bloc.blurField('phone'),
                        ),
                      ),

                      // Password field
                      _FormField(
                        label: 'Mật khẩu',
                        error: state.getFieldError('password'),
                        isValidating: state.getFieldState('password').isValidating,
                        child: CupertinoTextField(
                          placeholder: 'Nhập mật khẩu',
                          obscureText: true,
                          padding: const EdgeInsets.all(12),
                          onChanged: (v) => bloc.setValue('password', v),
                          onEditingComplete: () => bloc.blurField('password'),
                        ),
                      ),

                      // Confirm password field
                      _FormField(
                        label: 'Xác nhận mật khẩu',
                        error: state.getFieldError('confirmPassword'),
                        isValidating: state.getFieldState('confirmPassword').isValidating,
                        child: CupertinoTextField(
                          placeholder: 'Nhập lại mật khẩu',
                          obscureText: true,
                          padding: const EdgeInsets.all(12),
                          onChanged: (v) => bloc.setValue('confirmPassword', v),
                          onEditingComplete: () => bloc.blurField('confirmPassword'),
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Dynamic Select Demo (Field Dependencies)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.label.resolveFrom(context),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Province field - Dynamic select
                      _FormField(
                        label: 'Tỉnh/Thành phố',
                        error: state.getFieldError('province'),
                        isValidating: state.getFieldState('province').isValidating,
                        child: _DynamicSelectField(
                          value: state.getValue('province') as String?,
                          placeholder: 'Chọn tỉnh/thành phố',
                          items: _provinces,
                          onChanged: (value) {
                            bloc.setValue('province', value);
                          },
                        ),
                      ),

                      // District field - Depends on Province
                      _FormField(
                        label: 'Quận/Huyện',
                        error: state.getFieldError('district'),
                        isValidating: state.getFieldState('district').isValidating,
                        child: _DynamicSelectField(
                          value: state.getValue('district') as String?,
                          placeholder: 'Chọn quận/huyện',
                          items: _getDistrictsForProvince(state.getValue('province') as String?),
                          enabled: state.getValue('province') != null,
                          onChanged: (value) => bloc.setValue('district', value),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // State info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6.resolveFrom(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Form State Info:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.label.resolveFrom(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Is Valid: ${state.isValid}'),
                            Text('Is Dirty: ${state.isDirty}'),
                            Text('Is Submitting: ${state.isSubmitting}'),
                            Text('All Errors: ${state.allErrors}'),
                            Text('Values: ${state.values}'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton.filled(
                          onPressed: state.isSubmitting
                              ? null
                              : () => bloc.submit(showDialog: true),
                          child: state.isSubmitting
                              ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                              : const Text('Đăng ký'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Reset button
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          onPressed: () => bloc.reset(),
                          child: const Text('Reset Form'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String? error;
  final bool isValidating;
  final Widget child;

  const _FormField({
    required this.label,
    required this.error,
    required this.isValidating,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
              if (isValidating) ...[
                const SizedBox(width: 8),
                const CupertinoActivityIndicator(radius: 8),
              ],
            ],
          ),
          const SizedBox(height: 6),
          child,
          if (error != null) ...[
            const SizedBox(height: 4),
            Text(
              error!,
              style: const TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dynamic Select Field Widget
class _DynamicSelectField extends StatelessWidget {
  final String? value;
  final String placeholder;
  final List<_SelectOption> items;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  const _DynamicSelectField({
    required this.value,
    required this.placeholder,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final selectedItem = items.where((e) => e.value == value).firstOrNull;

    return GestureDetector(
      onTap: enabled ? () => _showPicker(context) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: enabled
              ? CupertinoColors.systemBackground.resolveFrom(context)
              : CupertinoColors.systemGrey5.resolveFrom(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: CupertinoColors.systemGrey4.resolveFrom(context),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedItem?.label ?? placeholder,
                style: TextStyle(
                  color: selectedItem != null
                      ? CupertinoColors.label.resolveFrom(context)
                      : CupertinoColors.placeholderText.resolveFrom(context),
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_down,
              size: 16,
              color: enabled
                  ? CupertinoColors.systemGrey.resolveFrom(context)
                  : CupertinoColors.systemGrey3.resolveFrom(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Hủy'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Xong'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item.value == value;
                  return CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    onPressed: () {
                      onChanged(item.value);
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: CupertinoColors.label.resolveFrom(context),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            CupertinoIcons.checkmark,
                            color: CupertinoColors.activeBlue.resolveFrom(context),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Select option model
class _SelectOption {
  final String value;
  final String label;

  const _SelectOption(this.value, this.label);
}

/// Mock data - Provinces
const _provinces = [
  _SelectOption('hanoi', 'Hà Nội'),
  _SelectOption('hcm', 'TP. Hồ Chí Minh'),
  _SelectOption('danang', 'Đà Nẵng'),
  _SelectOption('haiphong', 'Hải Phòng'),
];

/// Mock data - Districts by Province
List<_SelectOption> _getDistrictsForProvince(String? provinceId) {
  switch (provinceId) {
    case 'hanoi':
      return const [
        _SelectOption('hoankiem', 'Hoàn Kiếm'),
        _SelectOption('badinh', 'Ba Đình'),
        _SelectOption('dongda', 'Đống Đa'),
        _SelectOption('caugiay', 'Cầu Giấy'),
        _SelectOption('thanhxuan', 'Thanh Xuân'),
      ];
    case 'hcm':
      return const [
        _SelectOption('quan1', 'Quận 1'),
        _SelectOption('quan3', 'Quận 3'),
        _SelectOption('quan7', 'Quận 7'),
        _SelectOption('binhtan', 'Bình Tân'),
        _SelectOption('thuduc', 'Thủ Đức'),
      ];
    case 'danang':
      return const [
        _SelectOption('haichau', 'Hải Châu'),
        _SelectOption('thanhkhe', 'Thanh Khê'),
        _SelectOption('sontra', 'Sơn Trà'),
      ];
    case 'haiphong':
      return const [
        _SelectOption('hongbang', 'Hồng Bàng'),
        _SelectOption('lechan', 'Lê Chân'),
        _SelectOption('ngoquyen', 'Ngô Quyền'),
      ];
    default:
      return const [];
  }
}
