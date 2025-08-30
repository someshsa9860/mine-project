import 'package:flutter/material.dart';

import '../print/bluetoothConnection.dart';
import '../screens/dashboard_page.dart';
import '../screens/login_page.dart';
import '../services/auth_manager.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    AuthManager.instance.init();
    BluetoothConnection.instance.setPrinter();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthStatus>(
      valueListenable: AuthManager.instance.authStatus,
      builder: (context, status, _) {
        switch (status) {
          case AuthStatus.authenticated:
            return const DashboardPage();
          case AuthStatus.blocked:
            return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text('Account Blocked')),
            ); // Create a simple UI saying "User Blocked"
          case AuthStatus.sessionExpired:
            return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text('Session Expired')),
            ); // ptional: "Session expired. Please login again."
          case AuthStatus.unauthenticated:
          case AuthStatus.unknown:
            return const LoginPage();
        }
      },
    );
  }
}
