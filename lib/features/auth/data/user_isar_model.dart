import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'user_model.dart';

// Part file for Isar code generation
part 'user_isar_model.g.dart';

/// Isar model for User entity with NoSQL database support
/// This model handles user authentication and profile data using Isar database
@Collection()
class UserIsar {
  /// Auto-incrementing database ID (used by Isar internally)
  Id id = Isar.autoIncrement;

  /// Unique identifier for the user using UUID
  /// This serves as the business key for user identification
  @Index(unique: true)
  late String uuid;

  /// Username for the user account
  /// Must be unique across all users
  @Index(unique: true)
  late String username;

  /// Hashed password for security
  /// Never store plain text passwords
  late String passwordHash;

  /// Optional local path to profile image
  /// Can be null if user hasn't set a profile picture
  String? profileImagePath;

  /// Timestamp when the user account was created
  late DateTime createdAt;

  /// Timestamp of the user's last login
  late DateTime lastLoginAt;

  /// Default constructor for Isar
  UserIsar();

  /// Named constructor to create user with required fields
  UserIsar.create({
    required this.username,
    required this.passwordHash,
    this.profileImagePath,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    // Generate unique UUID for new user
    uuid = const Uuid().v4();

    // Set timestamps
    final now = DateTime.now();
    this.createdAt = createdAt ?? now;
    this.lastLoginAt = lastLoginAt ?? now;
  }

  /// Factory constructor to create user from existing User model
  /// This helps with migration from the old model to Isar
  factory UserIsar.fromUser(User user) {
    return UserIsar()
      ..uuid = user.id
      ..username = user.username
      ..passwordHash = user.passwordHash
      ..profileImagePath = user.profileImagePath
      ..createdAt = user.createdAt
      ..lastLoginAt = user.lastLoginAt;
  }

  /// Convert Isar user back to regular User model
  /// This maintains compatibility with existing BLoC logic
  User toUser() {
    return User(
      id: uuid,
      username: username,
      passwordHash: passwordHash,
      profileImagePath: profileImagePath,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  /// Get the initial letter of username for avatar display
  /// This is ignored by Isar since it's a computed property
  @ignore
  String get initialLetter {
    return username.isNotEmpty ? username[0].toUpperCase() : '?';
  }

  /// Update user's last login timestamp
  void updateLastLogin() {
    lastLoginAt = DateTime.now();
  }

  /// Update user's profile image path
  void updateProfileImage(String? imagePath) {
    profileImagePath = imagePath;
  }

  /// Update username (ensure uniqueness is handled at service level)
  void updateUsername(String newUsername) {
    username = newUsername;
  }

  /// Update password hash
  void updatePasswordHash(String newPasswordHash) {
    passwordHash = newPasswordHash;
  }
}
