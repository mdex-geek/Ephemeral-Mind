import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/view/login_page.dart';
import 'app.dart';

/// Wrapper that handles authentication routing
/// Shows login page if not authenticated, main app if authenticated
class AuthWrapper extends StatelessWidget {
  final Function(ThemeMode) onThemeModeChanged;
  final ThemeMode currentThemeMode;

  const AuthWrapper({
    super.key,
    required this.onThemeModeChanged,
    required this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Show loading while checking auth status
        if (state is AuthInitial ||
            state is AuthLoading ||
            state is AuthChecking) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show main app if authenticated (includes ProfileUpdated state)
        if (state is AuthAuthenticated || state is ProfileUpdated) {
          return App(
            onThemeModeChanged: onThemeModeChanged,
            currentThemeMode: currentThemeMode,
          );
        }

        // Show login page if not authenticated (including after account deletion)
        return const LoginPage();
      },
    );
  }
}
