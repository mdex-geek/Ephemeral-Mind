import 'package:flutter/material.dart';

/// Model representing a user entry with auto-deletion functionality
class Entry {
  final String id; // Unique identifier for the entry
  final String userId; // ID of the user who created this entry
  final String author;
  final String content;
  final DateTime createdAt; // When the entry was created
  final DateTime autoDeleteAt; // When the entry will be automatically deleted
  final Color color;
  bool isSaved; // Whether the entry is preserved (saved entries don't auto-delete)
  bool isExpanded; // Whether the full content is shown (for long entries)

  Entry({
    required this.id,
    required this.userId,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.autoDeleteAt,
    required this.color,
    this.isSaved = false,
    this.isExpanded = false,
  });

  /// Get the time remaining before auto-deletion
  Duration get timeUntilDeletion {
    final now = DateTime.now();
    if (autoDeleteAt.isBefore(now)) {
      return Duration.zero;
    }
    return autoDeleteAt.difference(now);
  }

  /// Check if the entry should be auto-deleted
  bool get shouldAutoDelete {
    return !isSaved && DateTime.now().isAfter(autoDeleteAt);
  }

  /// Get formatted time string (e.g., "2 hours ago", "5 minutes left")
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Get formatted countdown string for auto-deletion
  String get countdownText {
    if (isSaved) return 'Preserved';
    
    final timeLeft = timeUntilDeletion;
    if (timeLeft.inSeconds <= 0) return 'Expired';
    
    if (timeLeft.inHours > 0) {
      return '${timeLeft.inHours}h ${timeLeft.inMinutes % 60}m left';
    } else if (timeLeft.inMinutes > 0) {
      return '${timeLeft.inMinutes}m ${timeLeft.inSeconds % 60}s left';
    } else {
      return '${timeLeft.inSeconds}s left';
    }
  }

  /// Create a copy of this entry with updated properties
  Entry copyWith({
    String? id,
    String? userId,
    String? author,
    String? content,
    DateTime? createdAt,
    DateTime? autoDeleteAt,
    Color? color,
    bool? isSaved,
    bool? isExpanded,
  }) {
    return Entry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      author: author ?? this.author,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      autoDeleteAt: autoDeleteAt ?? this.autoDeleteAt,
      color: color ?? this.color,
      isSaved: isSaved ?? this.isSaved,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  /// Convert entry to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'author': author,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'autoDeleteAt': autoDeleteAt.millisecondsSinceEpoch,
      'color': color.value,
      'isSaved': isSaved,
      'isExpanded': isExpanded,
    };
  }

  /// Create entry from JSON
  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id'],
      userId: json['userId'] ?? '', // Handle legacy entries without userId
      author: json['author'],
      content: json['content'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      autoDeleteAt: DateTime.fromMillisecondsSinceEpoch(json['autoDeleteAt']),
      color: Color(json['color']),
      isSaved: json['isSaved'] ?? false,
      isExpanded: json['isExpanded'] ?? false,
    );
  }
} 