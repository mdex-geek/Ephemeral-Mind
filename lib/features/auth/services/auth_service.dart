import 'dart:convert';
import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../data/user_model.dart';

/// Service for handling authentication and user management
class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';
  static const String _profileImagesDir = 'profile_images';
  final uuid = Uuid();

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get the directory for storing profile images
  Future<Directory> _getProfileImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${appDir.path}/$_profileImagesDir');
    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }
    return profileDir;
  }

  /// Copy image to app's secure directory
  Future<String> _copyImageToSecureLocation(String sourcePath) async {
    final profileDir = await _getProfileImagesDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destinationPath = '${profileDir.path}/$fileName';

    final sourceFile = File(sourcePath);
    // final destinationFile = File(destinationPath);

    await sourceFile.copy(destinationPath);
    return destinationPath;
  }

  /// Register a new user
  Future<User> registerUser(String username, String password) async {
    // Validate input
    if (username.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Username and password cannot be empty');
    }

    if (username.length < 3) {
      throw Exception('Username must be at least 3 characters long');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters long');
    }

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];

    // Check if username already exists
    for (final userJson in usersJson) {
      final user = User.fromJson(jsonDecode(userJson));
      if (user.username.toLowerCase() == username.toLowerCase()) {
        throw Exception('Username already exists');
      }
    }

    // Create new user
    final newUser = User(
      id: uuid.v4(), // Generate unique user ID
      username: username.trim(),
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    // Save user to storage
    usersJson.add(jsonEncode(newUser.toJson()));
    await prefs.setStringList(_usersKey, usersJson);

    // Set as current user
    await prefs.setString(_currentUserKey, jsonEncode(newUser.toJson()));

    return newUser;
  }

  /// Login user
  Future<User> loginUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];

    // Find user by username
    User? user;
    for (final userJson in usersJson) {
      final currentUser = User.fromJson(jsonDecode(userJson));
      if (currentUser.username.toLowerCase() == username.toLowerCase()) {
        user = currentUser;
        break;
      }
    }

    if (user == null) {
      throw Exception('User not found');
    }

    // Verify password
    if (user.passwordHash != _hashPassword(password)) {
      throw Exception('Invalid password');
    }

    // Update last login time
    final updatedUser = user.copyWith(lastLoginAt: DateTime.now());

    // Update user in storage
    final updatedUsersJson = usersJson.map((userJson) {
      final currentUser = User.fromJson(jsonDecode(userJson));
      if (currentUser.id == user!.id) {
        return jsonEncode(updatedUser.toJson());
      }
      return userJson;
    }).toList();

    await prefs.setStringList(_usersKey, updatedUsersJson);
    await prefs.setString(_currentUserKey, jsonEncode(updatedUser.toJson()));

    return updatedUser;
  }

  /// Get current logged in user
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserJson = prefs.getString(_currentUserKey);

    if (currentUserJson == null) {
      return null;
    }

    return User.fromJson(jsonDecode(currentUserJson));
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  /// Update user profile
  /// Update user profile with proper async handling and data preservation
  Future<User> updateProfile({
    required String userId,
    String? newUsername,
    String? currentPassword,
    String? newPassword,
    String? newProfileImagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];

    // Find the user first to preserve all existing data
    User? targetUser;
    for (final userJson in usersJson) {
      final user = User.fromJson(jsonDecode(userJson));
      if (user.id == userId) {
        targetUser = user;
        break;
      }
    }

    if (targetUser == null) {
      throw Exception('User not found');
    }

    // Validate current password if changing password
    if (newPassword != null) {
      if (currentPassword == null || currentPassword.isEmpty) {
        throw Exception('Current password is required to change password');
      }
      if (_hashPassword(currentPassword) != targetUser.passwordHash) {
        throw Exception('Current password is incorrect');
      }
    }

    // Check if new username already exists (if changing username)
    if (newUsername != null && newUsername != targetUser.username) {
      for (final userJson in usersJson) {
        final user = User.fromJson(jsonDecode(userJson));
        if (user.id != userId &&
            user.username.toLowerCase() == newUsername.toLowerCase()) {
          throw Exception('Username already exists');
        }
      }
    }

    // Handle profile image with proper async handling
    String? finalImagePath = targetUser.profileImagePath;
    if (newProfileImagePath != null) {
      try {
        finalImagePath = await _copyImageToSecureLocation(newProfileImagePath);
      } catch (e) {
        // If image copying fails, keep the old image path
        print('Failed to copy profile image: $e');
        finalImagePath = targetUser.profileImagePath;
      }
    }

    // Create updated user with preserved data
    final updatedUser = targetUser.copyWith(
      username: newUsername ?? targetUser.username,
      passwordHash: newPassword != null
          ? _hashPassword(newPassword)
          : targetUser.passwordHash,
      profileImagePath: finalImagePath,
      // Explicitly preserve existing data
      createdAt: targetUser.createdAt,
      lastLoginAt: targetUser.lastLoginAt,
    );

    // Update the users list
    final updatedUsersJson = usersJson.map((userJson) {
      final user = User.fromJson(jsonDecode(userJson));
      if (user.id == userId) {
        return jsonEncode(updatedUser.toJson());
      }
      return userJson;
    }).toList();

    // Save updated users
    await prefs.setStringList(_usersKey, updatedUsersJson);

    // Update current user if it's the same user
    final currentUser = await getCurrentUser();
    if (currentUser?.id == userId) {
      await prefs.setString(_currentUserKey, jsonEncode(updatedUser.toJson()));
    }

    return updatedUser;
  }

  /// Delete user account
  Future<void> deleteUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];

    // Remove user from storage
    final updatedUsersJson = usersJson.where((userJson) {
      final user = User.fromJson(jsonDecode(userJson));
      return user.id != userId;
    }).toList();

    await prefs.setStringList(_usersKey, updatedUsersJson);

    // Logout if it's the current user
    final currentUser = await getCurrentUser();
    if (currentUser?.id == userId) {
      await logout();
    }
  }

  /// Check if user exists
  Future<bool> userExists(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];

    for (final userJson in usersJson) {
      final user = User.fromJson(jsonDecode(userJson));
      if (user.username.toLowerCase() == username.toLowerCase()) {
        return true;
      }
    }

    return false;
  }
}
