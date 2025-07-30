import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/user_model.dart';

/// Service for handling authentication and user management
class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';
  static const String _profileImagesDir = 'profile_images';

  /// Generate a secure UUID
  String _generateUUID() {
    final random = Random.secure();
    final bytes = Uint8List(16);
    for (int i = 0; i < 16; i++) {
      bytes[i] = random.nextInt(256);
    }
    
    // Set version (4) and variant bits
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    
    return [
      bytes.take(4).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      bytes.skip(4).take(2).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      bytes.skip(6).take(2).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      bytes.skip(8).take(2).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      bytes.skip(10).take(6).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
    ].join('-');
  }

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
      id: _generateUUID(),
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
  Future<User> updateProfile({
    required String userId,
    String? newUsername,
    String? newPassword,
    String? newProfileImagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];
    
    // Find and update user
    User? updatedUser;
    final updatedUsersJson = usersJson.map((userJson) {
      final user = User.fromJson(jsonDecode(userJson));
      if (user.id == userId) {
        // Check if new username already exists (if changing username)
        if (newUsername != null && newUsername != user.username) {
          for (final existingUserJson in usersJson) {
            final existingUser = User.fromJson(jsonDecode(existingUserJson));
            if (existingUser.id != userId && 
                existingUser.username.toLowerCase() == newUsername.toLowerCase()) {
              throw Exception('Username already exists');
            }
          }
        }

        // Handle profile image
        String? finalImagePath = user.profileImagePath;
        if (newProfileImagePath != null) {
          // Copy image to secure location
          _copyImageToSecureLocation(newProfileImagePath).then((path) {
            finalImagePath = path;
          });
        }

        updatedUser = user.copyWith(
          username: newUsername ?? user.username,
          passwordHash: newPassword != null ? _hashPassword(newPassword) : user.passwordHash,
          profileImagePath: finalImagePath ?? user.profileImagePath,
        );
        
        return jsonEncode(updatedUser!.toJson());
      }
      return userJson;
    }).toList();

    if (updatedUser == null) {
      throw Exception('User not found');
    }

    // Save updated users
    await prefs.setStringList(_usersKey, updatedUsersJson);
    
    // Update current user if it's the same user
    final currentUser = await getCurrentUser();
    if (currentUser?.id == userId) {
      await prefs.setString(_currentUserKey, jsonEncode(updatedUser!.toJson()));
    }

    return updatedUser!;
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