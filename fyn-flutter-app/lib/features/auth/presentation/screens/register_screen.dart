import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../config/api_config.dart';
import '../../../../core/utils/validators.dart';
import '../../../../theme/app_colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  // Controllers
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final authNotifier = ref.read(authNotifierProvider.notifier);
    
    // Format phone
    String? phone;
    if (_phoneController.text.trim().isNotEmpty) {
      phone = Validators.formatPhone(_phoneController.text.trim());
    }
    
    final success = await authNotifier.register(
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      phone: phone,
      fullName: _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
    );

    if (success && mounted) {
      final email = _emailController.text.trim();
      await _sendRegisterOtp(email);
      await _showVerifyOtpSheet(email);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(authNotifierProvider).error ?? 'Đăng ký thất bại'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _sendRegisterOtp(String email) async {
    final apiClient = ref.read(apiClientProvider);
    try {
      await apiClient.post(
        ApiEndpoints.sendRegisterOtp,
        data: {'email': email},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã gửi mã OTP kích hoạt tới $email'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể gửi OTP kích hoạt: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _showVerifyOtpSheet(String email) async {
    final otpController = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: keyboardPadding),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Xác minh tài khoản',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhập mã OTP đã gửi tới $email để kích hoạt tài khoản.',
                  style: const TextStyle(color: AppColors.secondaryText),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Mã OTP',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _sendRegisterOtp(email),
                      child: const Text('Gửi lại mã'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        final otp = otpController.text.trim();
                        if (otp.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vui lòng nhập mã OTP'),
                            ),
                          );
                          return;
                        }
                        final apiClient = ref.read(apiClientProvider);
                        try {
                          await apiClient.post(
                            ApiEndpoints.verifyRegisterOtp,
                            data: {'email': email, 'otp': otp},
                          );
                          if (!mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Kích hoạt thành công! Vui lòng đăng nhập lại.',
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          context.go('/login');
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Xác minh OTP thất bại: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                      child: const Text('Xác nhận'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.surface, // Nền trắng đồng bộ
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar trong suốt
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22, color: AppColors.primaryText),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Text(
                  'Tạo tài khoản',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.w800, 
                    color: AppColors.primaryText,
                    letterSpacing: -0.5
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tham gia cộng đồng FYN ngay hôm nay',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 16),
                ),
                
                const SizedBox(height: 40),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Full Name
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'Họ và tên',
                        hint: 'Nguyễn Văn A',
                        icon: Icons.badge_outlined,
                        validator: Validators.validateFullName,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'example@email.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 16),

                      // Username
                      _buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        hint: '@username',
                        icon: Icons.alternate_email_rounded,
                        validator: Validators.validateUsername,
                      ),
                      const SizedBox(height: 16),

                      // Phone (Optional)
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Số điện thoại (Tùy chọn)',
                        hint: '0912...',
                        icon: Icons.phone_iphone_rounded,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          if (value.startsWith('+')) return Validators.validatePhone(value);
                          final digits = value.replaceAll(RegExp(r'[^\d]'), '');
                          if (digits.length < 8 || digits.length > 15) return 'SĐT không hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Mật khẩu',
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.secondaryText,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Xác nhận mật khẩu',
                        hint: '••••••••',
                        icon: Icons.lock_reset_rounded, // Icon phù hợp hơn
                        obscureText: _obscureConfirmPassword,
                        isLastField: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.secondaryText,
                          ),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) return 'Mật khẩu không khớp';
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 24, 
                                  width: 24, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                                )
                              : const Text(
                                  'Đăng ký tài khoản',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Đã có tài khoản? ', style: TextStyle(color: AppColors.secondaryText, fontSize: 15)),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget tái sử dụng
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    bool isLastField = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.primaryText,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textInputAction: isLastField ? TextInputAction.done : TextInputAction.next,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.tertiaryText, fontWeight: FontWeight.w400),
            prefixIcon: Icon(icon, color: AppColors.secondaryText),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surfaceElevated, // Nền xám nhạt
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}