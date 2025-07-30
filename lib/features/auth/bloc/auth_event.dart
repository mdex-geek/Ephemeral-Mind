
/// Base class for all authentication-related events
abstract class AuthEvent {
  const AuthEvent();
}

/// Event to register a new user
class RegisterUser extends AuthEvent {
  final String username;
  final String password;

  const RegisterUser({
    required this.username,
    required this.password,
  });
}

/// Event to login user
class LoginUser extends AuthEvent {
  final String username;
  final String password;

  const LoginUser({
    required this.username,
    required this.password,
  });
}

/// Event to logout user
class LogoutUser extends AuthEvent {
  const LogoutUser();
}

/// Event to check if user is already logged in
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

/// Event to update user profile
class UpdateProfile extends AuthEvent {
  final String? newUsername;
  final String? newPassword;
  final String? newProfileImagePath;

  const UpdateProfile({
    this.newUsername,
    this.newPassword,
    this.newProfileImagePath,
  });
}

/// Event to delete user account
class DeleteAccount extends AuthEvent {
  const DeleteAccount();
} 