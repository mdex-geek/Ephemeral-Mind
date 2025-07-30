import 'package:flutter/material.dart';
// import '../data/entry_model.dart';

/// Base class for all entry-related events
abstract class EntryEvent {
  const EntryEvent();
}

/// Event to add a new entry
class AddEntry extends EntryEvent {
  final String content;
  final String author;
  final Color color;
  final Duration autoDeleteAfter; // How long before auto-deletion

  const AddEntry({
    required this.content,
    required this.author,
    required this.color,
    this.autoDeleteAfter = const Duration(hours: 24), // Default 24 hours
  });
}

/// Event to delete an entry
class DeleteEntry extends EntryEvent {
  final String entryId;

  const DeleteEntry({required this.entryId});
}

/// Event to toggle save/preserve status of an entry
class ToggleSaveEntry extends EntryEvent {
  final String entryId;

  const ToggleSaveEntry({required this.entryId});
}

/// Event to toggle expand/collapse of entry content
class ToggleExpandEntry extends EntryEvent {
  final String entryId;

  const ToggleExpandEntry({required this.entryId});
}

/// Event to remove expired entries
class RemoveExpiredEntries extends EntryEvent {
  const RemoveExpiredEntries();
}

/// Event to load entries from storage
class LoadEntries extends EntryEvent {
  const LoadEntries();
}

/// Event to save entries to storage
class SaveEntries extends EntryEvent {
  const SaveEntries();
} 