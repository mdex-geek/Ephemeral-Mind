// import 'dart:convert';
// import 'dart:typed_data';

/// Model representing a user with authentication and profile data
class User {
  final String id; // UUID for the user
  final String username;
  final String passwordHash; // Hashed password for security
  final String? profileImagePath; // Local path to profile image
  final DateTime createdAt;
  final DateTime lastLoginAt;

  User({
    required this.id,
    required this.username,
    required this.passwordHash,
    this.profileImagePath,
    required this.createdAt,
    required this.lastLoginAt,
  });

  /// Get the initial letter of username for avatar
  String get initialLetter {
    return username.isNotEmpty ? username[0].toUpperCase() : '?';
  }

  /// Create a copy of this user with updated properties
  User copyWith({
    String? id,
    String? username,
    String? passwordHash,
    String? profileImagePath,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// Convert user to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'passwordHash': passwordHash,
      'profileImagePath': profileImagePath,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt.millisecondsSinceEpoch,
    };
  }

  /// Create user from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      passwordHash: json['passwordHash'],
      profileImagePath: json['profileImagePath'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      lastLoginAt: DateTime.fromMillisecondsSinceEpoch(json['lastLoginAt']),
    );
  }
} 