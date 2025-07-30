import '../data/entry_model.dart';

/// Base class for all entry-related states
abstract class EntryState {
  const EntryState();
}

/// Initial state when the app starts
class EntryInitial extends EntryState {
  const EntryInitial();
}

/// State when entries are being loaded
class EntryLoading extends EntryState {
  const EntryLoading();
}

/// State when entries are successfully loaded
class EntryLoaded extends EntryState {
  final List<Entry> entries;
  final List<Entry> expiredEntries; // Entries that should be auto-deleted

  const EntryLoaded({
    required this.entries,
    required this.expiredEntries,
  });

  /// Create a copy with updated entries
  EntryLoaded copyWith({
    List<Entry>? entries,
    List<Entry>? expiredEntries,
  }) {
    return EntryLoaded(
      entries: entries ?? this.entries,
      expiredEntries: expiredEntries ?? this.expiredEntries,
    );
  }
}

/// State when an error occurs
class EntryError extends EntryState {
  final String message;

  const EntryError({required this.message});
}

/// State when an entry is being added
class EntryAdding extends EntryState {
  const EntryAdding();
}

/// State when an entry is being deleted
class EntryDeleting extends EntryState {
  const EntryDeleting();
}

/// State when entries are being saved to storage
class EntrySaving extends EntryState {
  const EntrySaving();
} 