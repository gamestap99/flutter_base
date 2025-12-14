/// Common async validators
/// Part of BLoC Pro VIP Architecture
library;

import '../bloc/wform_pro_bloc.dart';


/// Email exists validator (check if email is already registered)
class EmailExistsValidator extends AsyncValidator {
  final Future<bool> Function(String email) checkEmail;
  final String message;

  EmailExistsValidator({
    required this.checkEmail,
    this.message = 'Email đã được sử dụng',
  });

  @override
  Future<String?> validate(dynamic value, Map<String, dynamic> allValues) async {
    if (value == null || value.toString().isEmpty) return null;

    try {
      final exists = await checkEmail(value.toString());
      return exists ? message : null;
    } catch (_) {
      return null; // Don't block on error
    }
  }
}

/// Username exists validator
class UsernameExistsValidator extends AsyncValidator {
  final Future<bool> Function(String username) checkUsername;
  final String message;

  UsernameExistsValidator({
    required this.checkUsername,
    this.message = 'Tên người dùng đã được sử dụng',
  });

  @override
  Future<String?> validate(dynamic value, Map<String, dynamic> allValues) async {
    if (value == null || value.toString().isEmpty) return null;

    try {
      final exists = await checkUsername(value.toString());
      return exists ? message : null;
    } catch (_) {
      return null;
    }
  }
}

/// Phone exists validator
class PhoneExistsValidator extends AsyncValidator {
  final Future<bool> Function(String phone) checkPhone;
  final String message;

  PhoneExistsValidator({
    required this.checkPhone,
    this.message = 'Số điện thoại đã được sử dụng',
  });

  @override
  Future<String?> validate(dynamic value, Map<String, dynamic> allValues) async {
    if (value == null || value.toString().isEmpty) return null;

    try {
      final exists = await checkPhone(value.toString());
      return exists ? message : null;
    } catch (_) {
      return null;
    }
  }
}

/// Generic API validator
class ApiValidator extends AsyncValidator {
  final Future<String?> Function(dynamic value, Map<String, dynamic> allValues) apiCheck;

  ApiValidator({required this.apiCheck});

  @override
  Future<String?> validate(dynamic value, Map<String, dynamic> allValues) async {
    return apiCheck(value, allValues);
  }
}

// ========== Common Sync Validators ==========

/// Required validator
String? requiredValidator(dynamic value, Map<String, dynamic> allValues) {
  if (value == null) return 'Trường này là bắt buộc';
  if (value is String && value.trim().isEmpty) return 'Trường này là bắt buộc';
  if (value is List && value.isEmpty) return 'Trường này là bắt buộc';
  return null;
}

/// Email format validator
String? emailValidator(dynamic value, Map<String, dynamic> allValues) {
  if (value == null || value.toString().isEmpty) return null;

  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value.toString())) {
    return 'Email không hợp lệ';
  }
  return null;
}

/// Phone format validator (Vietnam)
String? phoneValidator(dynamic value, Map<String, dynamic> allValues) {
  if (value == null || value.toString().isEmpty) return null;

  final phoneRegex = RegExp(r'^(0|\+84)[0-9]{9,10}$');
  if (!phoneRegex.hasMatch(value.toString().replaceAll(' ', ''))) {
    return 'Số điện thoại không hợp lệ';
  }
  return null;
}

/// Min length validator
SyncValidator minLengthValidator(int minLength) {
  return (value, allValues) {
    if (value == null || value.toString().isEmpty) return null;
    if (value.toString().length < minLength) {
      return 'Tối thiểu $minLength ký tự';
    }
    return null;
  };
}

/// Max length validator
SyncValidator maxLengthValidator(int maxLength) {
  return (value, allValues) {
    if (value == null || value.toString().isEmpty) return null;
    if (value.toString().length > maxLength) {
      return 'Tối đa $maxLength ký tự';
    }
    return null;
  };
}

/// Password strength validator
String? passwordStrengthValidator(dynamic value, Map<String, dynamic> allValues) {
  if (value == null || value.toString().isEmpty) return null;

  final password = value.toString();
  if (password.length < 8) return 'Mật khẩu tối thiểu 8 ký tự';
  if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Mật khẩu cần có ít nhất 1 chữ hoa';
  if (!RegExp(r'[a-z]').hasMatch(password)) return 'Mật khẩu cần có ít nhất 1 chữ thường';
  if (!RegExp(r'[0-9]').hasMatch(password)) return 'Mật khẩu cần có ít nhất 1 số';

  return null;
}

/// Confirm password validator
SyncValidator confirmPasswordValidator(String passwordField) {
  return (value, allValues) {
    if (value == null || value.toString().isEmpty) return null;

    final password = allValues[passwordField];
    if (password != value) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  };
}

/// Number range validator
SyncValidator numberRangeValidator({int? min, int? max}) {
  return (value, allValues) {
    if (value == null) return null;

    final number = num.tryParse(value.toString());
    if (number == null) return 'Giá trị phải là số';

    if (min != null && number < min) return 'Giá trị tối thiểu là $min';
    if (max != null && number > max) return 'Giá trị tối đa là $max';

    return null;
  };
}

/// Pattern validator
SyncValidator patternValidator(RegExp pattern, String message) {
  return (value, allValues) {
    if (value == null || value.toString().isEmpty) return null;
    if (!pattern.hasMatch(value.toString())) return message;
    return null;
  };
}

/// Combine multiple validators
List<SyncValidator> combineValidators(List<SyncValidator> validators) {
  return validators;
}
