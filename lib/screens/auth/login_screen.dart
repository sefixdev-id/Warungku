import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../screens/admin/admin_main_screen.dart';
import '../../screens/user/user_main_screen.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/local_session_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final AuthService _authService;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(ApiService(), LocalSessionService());
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    final response = await _authService.login(
      _email.text.trim(),
      _password.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (!response.success || response.data == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));
      return;
    }
    _openHome(response.data!);
  }

  void _openHome(UserModel user) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => user.isAdmin
            ? AdminMainScreen(user: user)
            : UserMainScreen(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.storefront,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Warungku',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aplikasi Warung Tetangga',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Belanja • Chat • Hutang • Kelola Warung',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  AppTextField(
                    controller: _email,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _password,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'Masuk',
                    icon: Icons.login,
                    isLoading: _loading,
                    onPressed: _login,
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text('Daftar sebagai pelanggan'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
