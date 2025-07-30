import 'package:ephemeral_mind/features/auth/data/user_isar_model.dart';
import 'package:ephemeral_mind/features/review/data/entry_isar_model.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
// import '../features/auth/data/user_isar_model.dart';
// import '../features/review/data/entry_isar_model.dart';

/// Isar Database Service - Singleton pattern for managing NoSQL database operations
/// This service provides a clean interface for all database operations using Isar
class IsarService {
  static IsarService? _instance;
  static Isar? _isar;

  /// Private constructor for singleton pattern
  IsarService._();

  /// Get the singleton instance of IsarService
  static IsarService get instance {
    _instance ??= IsarService._();
    return _instance!;
  }

  /// Get the Isar database instance
  /// Throws exception if database is not initialized
  static Isar get isar {
    if (_isar == null) {
      throw Exception(
        'Isar database not initialized. Call initialize() first.',
      );
    }
    return _isar!;
  }

  /// Initialize the Isar database
  /// This should be called once when the app starts
  /// Returns true if initialization is successful
  static Future<bool> initialize() async {
    try {
      // Get the application documents directory
      final dir = await getApplicationDocumentsDirectory();

      // Open Isar database with schemas
      _isar = await Isar.open(
        [
          UserIsarSchema, // Schema for user collection
          EntryIsarSchema, // Schema for entry collection
        ],
        directory: dir.path,
        name: 'shitpost_db', // Database name
      );

      return true;
    } catch (e) {
      // Log error and return false
      print('Failed to initialize Isar database: $e');
      return false;
    }
  }

  /// Close the database connection
  /// Should be called when the app is shutting down
  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
    _instance = null;
  }

  /// Clear all data from the database (useful for testing or reset)
  /// USE WITH CAUTION - This will delete all user data
  static Future<void> clearDatabase() async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }

  // ==================== USER OPERATIONS ====================

  /// Create a new user in the database
  /// Returns the created user's ID, or null if creation fails
  Future<int?> createUser(UserIsar user) async {
    try {
      return await isar.writeTxn(() async {
        return await isar.userIsars.put(user);
      });
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  /// Get user by UUID
  /// Returns null if user not found
  Future<UserIsar?> getUserByUuid(String uuid) async {
    try {
      return await isar.userIsars.filter().uuidEqualTo(uuid).findFirst();
    } catch (e) {
      print('Error getting user by UUID: $e');
      return null;
    }
  }

  /// Get user by username
  /// Returns null if user not found
  Future<UserIsar?> getUserByUsername(String username) async {
    try {
      return await isar.userIsars
          .filter()
          .usernameEqualTo(username)
          .findFirst();
    } catch (e) {
      print('Error getting user by username: $e');
      return null;
    }
  }

  /// Update an existing user
  /// Returns true if update is successful
  Future<bool> updateUser(UserIsar user) async {
    try {
      await isar.writeTxn(() async {
        await isar.userIsars.put(user);
      });
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  /// Delete a user by UUID
  /// Also deletes all entries associated with the user
  /// Returns true if deletion is successful
  Future<bool> deleteUser(String uuid) async {
    try {
      return await isar.writeTxn(() async {
        // First delete all entries by this user
        final entriesToDelete = await isar.entryIsars
            .filter()
            .userIdEqualTo(uuid)
            .findAll();

        final entryIds = entriesToDelete.map((e) => e.id).toList();
        await isar.entryIsars.deleteAll(entryIds);

        // Then delete the user
        final user = await isar.userIsars
            .filter()
            .uuidEqualTo(uuid)
            .findFirst();

        if (user != null) {
          return await isar.userIsars.delete(user.id);
        }
        return false;
      });
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  /// Check if username already exists
  /// Returns true if username is taken
  Future<bool> isUsernameTaken(String username) async {
    try {
      final user = await getUserByUsername(username);
      return user != null;
    } catch (e) {
      print('Error checking username: $e');
      return true; // Return true to be safe
    }
  }

  // ==================== ENTRY OPERATIONS ====================

  /// Create a new entry in the database
  /// Returns the created entry's ID, or null if creation fails
  Future<int?> createEntry(EntryIsar entry) async {
    try {
      return await isar.writeTxn(() async {
        return await isar.entryIsars.put(entry);
      });
    } catch (e) {
      print('Error creating entry: $e');
      return null;
    }
  }

  /// Get all entries for a specific user
  /// Returns list of entries ordered by creation date (newest first)
  Future<List<EntryIsar>> getEntriesByUser(String userId) async {
    try {
      return await isar.entryIsars
          .filter()
          .userIdEqualTo(userId)
          .sortByCreatedAtDesc()
          .findAll();
    } catch (e) {
      print('Error getting entries by user: $e');
      return [];
    }
  }

  /// Get entry by UUID
  /// Returns null if entry not found
  Future<EntryIsar?> getEntryByUuid(String uuid) async {
    try {
      return await isar.entryIsars.filter().uuidEqualTo(uuid).findFirst();
    } catch (e) {
      print('Error getting entry by UUID: $e');
      return null;
    }
  }

  /// Update an existing entry
  /// Returns true if update is successful
  Future<bool> updateEntry(EntryIsar entry) async {
    try {
      await isar.writeTxn(() async {
        await isar.entryIsars.put(entry);
      });
      return true;
    } catch (e) {
      print('Error updating entry: $e');
      return false;
    }
  }

  /// Delete an entry by UUID
  /// Returns true if deletion is successful
  Future<bool> deleteEntry(String uuid) async {
    try {
      return await isar.writeTxn(() async {
        final entry = await isar.entryIsars
            .filter()
            .uuidEqualTo(uuid)
            .findFirst();

        if (entry != null) {
          return await isar.entryIsars.delete(entry.id);
        }
        return false;
      });
    } catch (e) {
      print('Error deleting entry: $e');
      return false;
    }
  }

  /// Get all expired entries that should be auto-deleted
  /// Returns list of entries that have passed their auto-delete time and are not saved
  Future<List<EntryIsar>> getExpiredEntries() async {
    try {
      final now = DateTime.now();
      return await isar.entryIsars
          .filter()
          .isSavedEqualTo(false) // Only unsaved entries
          .autoDeleteAtLessThan(now) // Past auto-delete time
          .findAll();
    } catch (e) {
      print('Error getting expired entries: $e');
      return [];
    }
  }

  /// Delete all expired entries
  /// This should be called periodically to clean up expired entries
  /// Returns the number of entries deleted
  Future<int> deleteExpiredEntries() async {
    try {
      final expiredEntries = await getExpiredEntries();
      if (expiredEntries.isEmpty) return 0;

      return await isar.writeTxn(() async {
        final entryIds = expiredEntries.map((e) => e.id).toList();
        return await isar.entryIsars.deleteAll(entryIds);
      });
    } catch (e) {
      print('Error deleting expired entries: $e');
      return 0;
    }
  }

  /// Toggle the saved status of an entry
  /// Returns true if operation is successful
  Future<bool> toggleEntrySaved(String uuid) async {
    try {
      return await isar.writeTxn(() async {
        final entry = await isar.entryIsars
            .filter()
            .uuidEqualTo(uuid)
            .findFirst();

        if (entry != null) {
          entry.toggleSaved();
          await isar.entryIsars.put(entry);
          return true;
        }
        return false;
      });
    } catch (e) {
      print('Error toggling entry saved status: $e');
      return false;
    }
  }

  /// Toggle the expanded status of an entry (for UI state)
  /// Returns true if operation is successful
  Future<bool> toggleEntryExpanded(String uuid) async {
    try {
      return await isar.writeTxn(() async {
        final entry = await isar.entryIsars
            .filter()
            .uuidEqualTo(uuid)
            .findFirst();

        if (entry != null) {
          entry.toggleExpanded();
          await isar.entryIsars.put(entry);
          return true;
        }
        return false;
      });
    } catch (e) {
      print('Error toggling entry expanded status: $e');
      return false;
    }
  }

  // ==================== UTILITY OPERATIONS ====================

  /// Get database statistics
  /// Returns a map with various database metrics
  Future<Map<String, int>> getDatabaseStats() async {
    try {
      final userCount = await isar.userIsars.count();
      final entryCount = await isar.entryIsars.count();
      final savedEntries = await isar.entryIsars
          .filter()
          .isSavedEqualTo(true)
          .count();
      final expiredEntries = await getExpiredEntries();

      return {
        'totalUsers': userCount,
        'totalEntries': entryCount,
        'savedEntries': savedEntries,
        'expiredEntries': expiredEntries.length,
      };
    } catch (e) {
      print('Error getting database stats: $e');
      return {};
    }
  }

  /// Watch for changes in entries for a specific user
  /// Returns a stream that emits whenever entries change
  Stream<List<EntryIsar>> watchEntriesByUser(String userId) {
    return isar.entryIsars
        .filter()
        .userIdEqualTo(userId)
        .watch(fireImmediately: true);
  }

  /// Watch for changes in user data
  /// Returns a stream that emits whenever user data changes
  Stream<UserIsar?> watchUser(String uuid) {
    return isar.userIsars
        .filter()
        .uuidEqualTo(uuid)
        .watch(fireImmediately: true)
        .map((users) => users.isNotEmpty ? users.first : null);
  }
}
