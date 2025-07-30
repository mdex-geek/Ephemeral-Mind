import 'package:bloc/bloc.dart';
// import '../data/user_model.dart';
import '../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})  : _authService = authService,  super(const AuthInitial()) {
    // Register event handlers
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<RegisterUser>(_onRegisterUser);
    on<LoginUser>(_onLoginUser);
    on<LogoutUser>(_onLogoutUser);
    on<UpdateProfile>(_onUpdateProfile);
    on<DeleteAccount>(_onDeleteAccount);
  }

  /// Check if user is already authenticated
  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    try {
      emit(const AuthChecking());
      
      final user = await _authService.getCurrentUser();
      
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'Failed to check authentication status: $e'));
    }
  }

  /// Register a new user
  Future<void> _onRegisterUser(RegisterUser event, Emitter<AuthState> emit) async {
    try {
      emit(const AuthLoading());
      
      final user = await _authService.registerUser(
        event.username,
        event.password,
      );
      
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Login user
  Future<void> _onLoginUser(LoginUser event, Emitter<AuthState> emit) async {
    try {
      emit(const AuthLoading());
      
      final user = await _authService.loginUser(
        event.username,
        event.password,
      );
      
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Logout user
  Future<void> _onLogoutUser(LogoutUser event, Emitter<AuthState> emit) async {
    try {
      await _authService.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Failed to logout: $e'));
    }
  }

  /// Update user profile
  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<AuthState> emit) async {
    try {
      emit(const ProfileUpdating());
      
      final currentState = state;
      if (currentState is AuthAuthenticated) {
        final updatedUser = await _authService.updateProfile(
          userId: currentState.user.id,
          newUsername: event.newUsername,
          newPassword: event.newPassword,
          newProfileImagePath: event.newProfileImagePath,
        );
        
        emit(ProfileUpdated(user: updatedUser));
        emit(AuthAuthenticated(user: updatedUser));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Delete user account
  Future<void> _onDeleteAccount(DeleteAccount event, Emitter<AuthState> emit) async {
    try {
      final currentState = state;
      if (currentState is AuthAuthenticated) {
        await _authService.deleteUser(currentState.user.id);
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'Failed to delete account: $e'));
    }
  }
} 