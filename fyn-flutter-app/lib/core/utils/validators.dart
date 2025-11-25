class Validators {
  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }
    if (value.length > 128) {
      return 'Mật khẩu không được quá 128 ký tự';
    }
    return null;
  }

  /// Validate username
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username không được để trống';
    }
    if (value.length < 3) {
      return 'Username phải có ít nhất 3 ký tự';
    }
    if (value.length > 30) {
      return 'Username không được quá 30 ký tự';
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username chỉ được chứa chữ cái, số và dấu gạch dưới';
    }
    return null;
  }

  /// Validate phone (E.164 format)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    // E.164 format: +[country code][number], total 8-15 digits
    // Example: +84901234567
    final phoneRegex = RegExp(r'^\+[1-9][0-9]{7,14}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Số điện thoại phải bắt đầu bằng + và có 8-15 chữ số (VD: +84901234567)';
    }
    return null;
  }
  
  /// Format phone number to E.164 format
  static String? formatPhone(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    // Remove all non-digit characters
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) {
      return null;
    }
    // Add + if not present, assume Vietnam (+84) if starts with 0
    if (value.startsWith('+')) {
      return value;
    } else if (digits.startsWith('0')) {
      // Vietnam number: 0912345678 -> +84912345678
      return '+84${digits.substring(1)}';
    } else {
      // Assume Vietnam number without 0
      return '+84$digits';
    }
  }

  /// Validate full name
  static String? validateFullName(String? value) {
    if (value != null && value.length > 120) {
      return 'Họ tên không được quá 120 ký tự';
    }
    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, {String fieldName = 'Trường này'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  /// Validate content (for posts, comments)
  static String? validateContent(String? value, {int maxLength = 2048}) {
    if (value == null || value.isEmpty) {
      return 'Nội dung không được để trống';
    }
    if (value.length > maxLength) {
      return 'Nội dung không được quá $maxLength ký tự';
    }
    return null;
  }
}






