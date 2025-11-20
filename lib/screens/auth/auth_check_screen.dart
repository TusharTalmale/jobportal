import 'package:flutter/material.dart';
import 'package:jobportal/provider/auth_viewmodel.dart';
import 'package:jobportal/utils/app_routes.dart';
import 'package:provider/provider.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule a callback for after the first frame.
    // This prevents the "setState() or markNeedsBuild() called during build" error.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    // Use listen: false because we are in a method and not the build method.
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.initializeAuth();

    if (mounted) {
      // Check the auth status and navigate accordingly.
      if (authViewModel.isUserLoggedIn) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while checking auth status.
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
