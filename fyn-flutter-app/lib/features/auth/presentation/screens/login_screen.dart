import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../config/api_config.dart';
import '../../../../theme/app_colors.dart';
// Đảm bảo import AppButton mới (nếu bạn đã cập nhật file đó, hoặc dùng ElevatedButton custom bên dưới)
// import '../../../../shared/widgets/app_button.dart'; 

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Ẩn bàn phím để trải nghiệm mượt hơn
    FocusScope.of(context).unfocus();

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final success = await authNotifier.login(
      _identifierController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      context.go('/feed');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(authNotifierProvider).error ?? 'Đăng nhập thất bại'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.surface, // Nền trắng sạch sẽ
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Logo Section - Minimal & Clean
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08), // Nền icon rất nhạt
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined, // Hoặc icon app của bạn
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                
                Text(
                  'Chào mừng trở lại!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Đăng nhập để tiếp tục kết nối',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 48),

                // 2. Form Section
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Username/Email Field
                      _buildTextField(
                        controller: _identifierController,
                        label: 'Email hoặc Username',
                        hint: 'nhap@email.com',
                        icon: Icons.person_outline_rounded,
                        validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập thông tin' : null,
                      ),
                      
                      const SizedBox(height: 20),

                      // Password Field
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Mật khẩu',
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        isLastField: true,
                        onSubmitted: (_) => _handleLogin(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.secondaryText,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
                      ),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _showForgotPasswordFlow();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Quên mật khẩu?',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Login Button - Pill Shape
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0, // Flat style
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
                                  'Đăng nhập',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 3. Footer / Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Chưa có tài khoản? ',
                      style: TextStyle(color: AppColors.secondaryText, fontSize: 15),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: const Text(
                        'Đăng ký ngay',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 4. Verify account by OTP (kích hoạt tài khoản sau đăng ký)
                TextButton(
                  onPressed: _showVerifyAccountOtpDialog,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text(
                    'Đã đăng ký nhưng chưa kích hoạt? Xác minh bằng OTP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showForgotPasswordFlow() async {
    final emailController = TextEditingController(
      text: _identifierController.text.contains('@')
          ? _identifierController.text.trim()
          : '',
    );
    final newPassController = TextEditingController();
    final confirmController = TextEditingController();

    // Bước 1: nhập email + mật khẩu mới
    final step1 = await showDialog<Map<String, String>?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quên mật khẩu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPassController,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                decoration:
                    const InputDecoration(labelText: 'Xác nhận mật khẩu mới'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                final email = emailController.text.trim();
                if (email.isEmpty || !email.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập email hợp lệ')),
                  );
                  return;
                }
                if (newPassController.text.isEmpty ||
                    newPassController.text != confirmController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Mật khẩu mới không khớp hoặc trống')),
                  );
                  return;
                }
                Navigator.pop(context, {
                  'email': email,
                  'password': newPassController.text,
                });
              },
              child: const Text('Tiếp tục'),
            ),
          ],
        );
      },
    );

    if (step1 == null) return;

    final email = step1['email']!;
    final newPassword = step1['password']!;

    final apiClient = ref.read(apiClientProvider);

    try {
      // Gửi OTP tới email
      await apiClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể gửi OTP quên mật khẩu: $e'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Bước 2: nhập OTP
    final otpController = TextEditingController();
    final otp = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nhập mã OTP'),
          content: TextField(
            controller: otpController,
            decoration: const InputDecoration(labelText: 'Mã OTP'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, otpController.text.trim()),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );

    if (otp == null || otp.isEmpty) return;

    try {
      await apiClient.post(
        ApiEndpoints.verifyOtp,
        data: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt lại mật khẩu thành công, hãy đăng nhập lại.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xác minh OTP thất bại: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _showVerifyAccountOtpDialog() async {
    final emailController = TextEditingController(
      text: _identifierController.text.contains('@')
          ? _identifierController.text.trim()
          : '',
    );
    final otpController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác minh tài khoản bằng OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: otpController,
                decoration: const InputDecoration(labelText: 'Mã OTP'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final email = emailController.text.trim();
    final otp = otpController.text.trim();
    if (email.isEmpty || !email.contains('@') || otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email và OTP hợp lệ')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tài khoản đã được kích hoạt, hãy đăng nhập lại.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xác minh tài khoản thất bại: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Helper Widget cho TextField để code gọn hơn và đồng bộ style
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    bool isLastField = false,
    Function(String)? onSubmitted,
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
          obscureText: obscureText,
          textInputAction: isLastField ? TextInputAction.done : TextInputAction.next,
          onFieldSubmitted: onSubmitted,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.tertiaryText, fontWeight: FontWeight.w400),
            prefixIcon: Icon(icon, color: AppColors.secondaryText),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surfaceElevated, // Nền xám nhạt (Liquid feel)
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16), // Bo góc mềm mại
              borderSide: BorderSide.none, // Không viền
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
