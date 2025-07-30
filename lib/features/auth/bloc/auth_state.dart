import '../data/user_model.dart';

/// Base class for all authentication-related states
abstract class AuthState {
  const AuthState();
}

/// Initial state when the app starts
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State when checking authentication status
class AuthChecking extends AuthState {
  const AuthChecking();
}

/// State when user is authenticated
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});
}

/// State when user is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// State when authentication is in progress
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when an error occurs during authentication
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});
}

/// State when profile is being updated
class ProfileUpdating extends AuthState {
  const ProfileUpdating();
}

/// State when profile update is successful
class ProfileUpdated extends AuthState {
  final User user;

  const ProfileUpdated({required this.user});
} 