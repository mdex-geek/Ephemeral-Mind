import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'entry_model.dart';

// Part file for Isar code generation
part 'entry_isar_model.g.dart';

/// Isar model for Entry entity with NoSQL database support
/// This model handles user entries with auto-deletion functionality
@Collection()
class EntryIsar {
  /// Auto-incrementing database ID (used by Isar internally)
  Id id = Isar.autoIncrement;

  /// Unique identifier for the entry using UUID
  /// This serves as the business key for entry identification
  @Index()
  late String uuid;

  /// ID of the user who created this entry
  /// Used for filtering entries by user
  @Index()
  late String userId;

  /// Author name for the entry
  late String author;

  /// Content/text of the entry
  late String content;

  /// Timestamp when the entry was created
  late DateTime createdAt;

  /// Timestamp when the entry will be automatically deleted
  /// Only applies if entry is not saved
  late DateTime autoDeleteAt;

  /// Color value stored as integer
  /// Will be converted to/from Flutter Color object
  late int colorValue;

  /// Whether the entry is preserved (saved entries don't auto-delete)
  late bool isSaved;

  /// Whether the full content is shown (for UI expansion state)
  late bool isExpanded;

  /// Default constructor for Isar
  EntryIsar();

  /// Named constructor to create entry with required fields
  EntryIsar.create({
    required this.userId,
    required this.author,
    required this.content,
    required Color color,
    DateTime? createdAt,
    DateTime? autoDeleteAt,
    this.isSaved = false,
    this.isExpanded = false,
  }) {
    // Generate unique UUID for new entry
    uuid = const Uuid().v4();

    // Set timestamps
    final now = DateTime.now();
    this.createdAt = createdAt ?? now;

    // Default auto-delete after 24 hours if not specified
    this.autoDeleteAt = autoDeleteAt ?? now.add(const Duration(hours: 24));

    // Store color as integer value
    colorValue = color.value;
  }

  /// Factory constructor to create entry from existing Entry model
  /// This helps with migration from the old model to Isar
  factory EntryIsar.fromEntry(Entry entry) {
    return EntryIsar()
      ..uuid = entry.id
      ..userId = entry.userId
      ..author = entry.author
      ..content = entry.content
      ..createdAt = entry.createdAt
      ..autoDeleteAt = entry.autoDeleteAt
      ..colorValue = entry.color.value
      ..isSaved = entry.isSaved
      ..isExpanded = entry.isExpanded;
  }

  /// Convert Isar entry back to regular Entry model
  /// This maintains compatibility with existing BLoC logic
  Entry toEntry() {
    return Entry(
      id: uuid,
      userId: userId,
      author: author,
      content: content,
      createdAt: createdAt,
      autoDeleteAt: autoDeleteAt,
      color: Color(colorValue),
      isSaved: isSaved,
      isExpanded: isExpanded,
    );
  }

  /// Get the Flutter Color object from stored integer value
  /// This is ignored by Isar since Color is not a supported type
  @ignore
  Color get color => Color(colorValue);

  /// Set the color from Flutter Color object
  /// Note: Setters cannot be ignored, but this uses the stored colorValue
  set color(Color newColor) => colorValue = newColor.value;

  /// Get the time remaining before auto-deletion
  /// This is ignored by Isar since it's a computed property
  @ignore
  Duration get timeUntilDeletion {
    final now = DateTime.now();
    if (autoDeleteAt.isBefore(now)) {
      return Duration.zero;
    }
    return autoDeleteAt.difference(now);
  }

  /// Check if the entry should be auto-deleted
  /// This is ignored by Isar since it's a computed property
  @ignore
  bool get shouldAutoDelete {
    return !isSaved && DateTime.now().isAfter(autoDeleteAt);
  }

  /// Get formatted time string (e.g., "2 hours ago", "5 minutes left")
  /// This is ignored by Isar since it's a computed property
  @ignore
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
  /// This is ignored by Isar since it's a computed property
  @ignore
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

  /// Toggle the saved status of the entry
  void toggleSaved() {
    isSaved = !isSaved;
  }

  /// Toggle the expanded status of the entry (for UI)
  void toggleExpanded() {
    isExpanded = !isExpanded;
  }

  /// Update the auto-delete time (extend or shorten lifespan)
  void updateAutoDeleteTime(DateTime newAutoDeleteAt) {
    autoDeleteAt = newAutoDeleteAt;
  }

  /// Mark entry as saved to prevent auto-deletion
  void markAsSaved() {
    isSaved = true;
  }

  /// Unmark entry as saved (allow auto-deletion)
  void unmarkAsSaved() {
    isSaved = false;
  }
}
