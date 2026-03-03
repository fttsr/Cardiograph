import 'package:ca_frontend/src/core/di/di.dart';
import 'package:ca_frontend/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ca_frontend/src/features/auth/presentation/bloc/auth_event.dart';
import 'package:ca_frontend/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:ca_frontend/src/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:ca_frontend/src/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final TextEditingController _loginController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();

  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.4, end: 1.0)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutBack,
          ),
        );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeIn,
          ),
        );

    // Запуск анимации после отрисовки виджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed(BuildContext context) {
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        login: _loginController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (p, c) => p.success != c.success,
        listener: (context, state) {
          if (state.success) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                // builder: (_) => const HomeScreen(),
                builder: (_) => const LoginScreen(),
              ),
            );
          }
        },
        builder: (context, state) {
          final loading = state.loading;
          final error = state.error;

          return Scaffold(
            backgroundColor: const Color.fromARGB(
              255,
              64,
              103,
              245,
            ),
            body: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) => Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: _loginCard(context, loading, error),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _loginCard(
    BuildContext context,
    bool loading,
    String? error,
  ) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 14,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('lib/icons/logo.png', height: 48),
          const SizedBox(height: 12),
          const Text(
            'Вход',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _loginController,
            decoration: _inputDecoration('Логин'),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: _inputDecoration('Пароль'),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: loading
                ? null
                : () => _onLoginPressed(context),
            style: _buttonStyle(),
            child: loading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const Text('Войти'),
          ),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ForgotPasswordScreen(),
                ),
              );
            },
            child: const Text('Забыли пароль?'),
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegisterScreen(),
                ),
              );
            },
            child: const Text('Регистрация'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blue[700],
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 32,
      ),
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
