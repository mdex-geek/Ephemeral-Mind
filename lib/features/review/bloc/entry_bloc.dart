import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/entry_model.dart';
import 'entry_event.dart';
import 'entry_state.dart';

/// BLoC for managing entries with auto-deletion functionality
class EntryBloc extends Bloc<EntryEvent, EntryState> {
  static const String _storageKey = 'entries';
  static const Duration _autoDeleteCheckInterval = Duration(seconds: 30);
  
  Timer? _autoDeleteTimer;
  List<Entry> _entries = [];
  String? _currentUserId;

  EntryBloc() : super(const EntryInitial()) {
    // Register event handlers
    on<LoadEntries>(_onLoadEntries);
    on<AddEntry>(_onAddEntry);
    on<DeleteEntry>(_onDeleteEntry);
    on<ToggleSaveEntry>(_onToggleSaveEntry);
    on<ToggleExpandEntry>(_onToggleExpandEntry);
    on<RemoveExpiredEntries>(_onRemoveExpiredEntries);
    on<SaveEntries>(_onSaveEntries);

    // Start auto-deletion timer
    _startAutoDeleteTimer();
  }

  @override
  Future<void> close() {
    _autoDeleteTimer?.cancel();
    return super.close();
  }

  /// Set the current user ID for filtering entries
  void setCurrentUser(String userId) {
    _currentUserId = userId;
  }

  /// Start timer to periodically check for expired entries
  void _startAutoDeleteTimer() {
    _autoDeleteTimer = Timer.periodic(_autoDeleteCheckInterval, (timer) {
      add(const RemoveExpiredEntries());
    });
  }

  /// Load entries from local storage
  Future<void> _onLoadEntries(LoadEntries event, Emitter<EntryState> emit) async {
    try {
      emit(const EntryLoading());
      
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList(_storageKey) ?? [];
      
      _entries = entriesJson
          .map((json) => Entry.fromJson(jsonDecode(json)))
          .toList();
      
      // Filter entries for current user if userId is set
      if (_currentUserId != null) {
        _entries = _entries.where((entry) => entry.userId == _currentUserId).toList();
      }
      
      // Remove expired entries on load
      _removeExpiredEntries();
      
      emit(EntryLoaded(
        entries: _entries,
        expiredEntries: _getExpiredEntries(),
      ));
    } catch (e) {
      emit(EntryError(message: 'Failed to load entries: $e'));
    }
  }

  /// Add a new entry
  Future<void> _onAddEntry(AddEntry event, Emitter<EntryState> emit) async {
    try {
      emit(const EntryAdding());
      
      if (_currentUserId == null) {
        emit(const EntryError(message: 'User not authenticated'));
        return;
      }
      
      final now = DateTime.now();
      final newEntry = Entry(
        id: _generateId(),
        userId: _currentUserId!,
        author: event.author,
        content: event.content,
        createdAt: now,
        autoDeleteAt: now.add(event.autoDeleteAfter),
        color: event.color,
      );
      
      _entries.insert(0, newEntry); // Add to beginning of list
      
      // Save to storage
      await _saveToStorage();
      
      emit(EntryLoaded(
        entries: _entries,
        expiredEntries: _getExpiredEntries(),
      ));
    } catch (e) {
      emit(EntryError(message: 'Failed to add entry: $e'));
    }
  }

  /// Delete an entry
  Future<void> _onDeleteEntry(DeleteEntry event, Emitter<EntryState> emit) async {
    try {
      emit(const EntryDeleting());
      
      _entries.removeWhere((entry) => entry.id == event.entryId);
      
      // Save to storage
      await _saveToStorage();
      
      emit(EntryLoaded(
        entries: _entries,
        expiredEntries: _getExpiredEntries(),
      ));
    } catch (e) {
      emit(EntryError(message: 'Failed to delete entry: $e'));
    }
  }

  /// Toggle save/preserve status of an entry
  Future<void> _onToggleSaveEntry(ToggleSaveEntry event, Emitter<EntryState> emit) async {
    try {
      final index = _entries.indexWhere((entry) => entry.id == event.entryId);
      if (index != -1) {
        final entry = _entries[index];
        final updatedEntry = entry.copyWith(isSaved: !entry.isSaved);
        _entries[index] = updatedEntry;
        
        // Save to storage
        await _saveToStorage();
        
        emit(EntryLoaded(
          entries: _entries,
          expiredEntries: _getExpiredEntries(),
        ));
      }
    } catch (e) {
      emit(EntryError(message: 'Failed to toggle save status: $e'));
    }
  }

  /// Toggle expand/collapse of entry content
  Future<void> _onToggleExpandEntry(ToggleExpandEntry event, Emitter<EntryState> emit) async {
    try {
      final index = _entries.indexWhere((entry) => entry.id == event.entryId);
      if (index != -1) {
        final entry = _entries[index];
        final updatedEntry = entry.copyWith(isExpanded: !entry.isExpanded);
        _entries[index] = updatedEntry;
        
        emit(EntryLoaded(
          entries: _entries,
          expiredEntries: _getExpiredEntries(),
        ));
      }
    } catch (e) {
      emit(EntryError(message: 'Failed to toggle expand status: $e'));
    }
  }

  /// Remove expired entries
  Future<void> _onRemoveExpiredEntries(RemoveExpiredEntries event, Emitter<EntryState> emit) async {
    try {
      final initialCount = _entries.length;
      _removeExpiredEntries();
      
      // Only emit new state if entries were actually removed
      if (_entries.length != initialCount) {
        await _saveToStorage();
        
        emit(EntryLoaded(
          entries: _entries,
          expiredEntries: _getExpiredEntries(),
        ));
      }
    } catch (e) {
      emit(EntryError(message: 'Failed to remove expired entries: $e'));
    }
  }

  /// Save entries to local storage
  Future<void> _onSaveEntries(SaveEntries event, Emitter<EntryState> emit) async {
    try {
      emit(const EntrySaving());
      await _saveToStorage();
      
      emit(EntryLoaded(
        entries: _entries,
        expiredEntries: _getExpiredEntries(),
      ));
    } catch (e) {
      emit(EntryError(message: 'Failed to save entries: $e'));
    }
  }

  /// Remove expired entries from the list
  void _removeExpiredEntries() {
    _entries.removeWhere((entry) => entry.shouldAutoDelete);
  }

  /// Get list of expired entries
  List<Entry> _getExpiredEntries() {
    return _entries.where((entry) => entry.shouldAutoDelete).toList();
  }

  /// Save entries to SharedPreferences
  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load all entries first
    final allEntriesJson = prefs.getStringList(_storageKey) ?? [];
    final allEntries = allEntriesJson
        .map((json) => Entry.fromJson(jsonDecode(json)))
        .toList();
    
    // Remove current user's entries
    final otherUsersEntries = allEntries
        .where((entry) => entry.userId != _currentUserId)
        .toList();
    
    // Add current user's entries
    final updatedEntries = [...otherUsersEntries, ..._entries];
    
    // Save back to storage
    final updatedEntriesJson = updatedEntries
        .map((entry) => jsonEncode(entry.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, updatedEntriesJson);
  }

  /// Generate a unique ID for entries
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           (1000 + _entries.length).toString();
  }
} 