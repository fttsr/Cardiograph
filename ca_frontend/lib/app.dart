import 'package:ca_frontend/src/core/di/di.dart';
import 'package:ca_frontend/src/core/storage/app_box.dart';
import 'package:ca_frontend/src/features/auth/presentation/screens/login_screen.dart';
import 'package:ca_frontend/src/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appBox = sl<AppBox>();
    final hasSession =
        (appBox.userId != null && appBox.userId!.isNotEmpty);

    return MaterialApp(
      theme: ThemeData(fontFamily: 'Quicksand'),
      home: hasSession
          ? const HomeScreen() // убран повторный логин каждый раз
          : const LoginScreen(),
    );
  }
}
