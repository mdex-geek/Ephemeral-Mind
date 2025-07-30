import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/entry_bloc.dart';
import '../bloc/entry_event.dart';
import '../bloc/entry_state.dart';
import '../widgets/entry_card.dart';

/// Page that displays all entries with auto-deletion countdown timers
class ReviewEntriesPage extends StatefulWidget {
  const ReviewEntriesPage({super.key});

  @override
  State<ReviewEntriesPage> createState() => _ReviewEntriesPageState();
}

class _ReviewEntriesPageState extends State<ReviewEntriesPage> {
  @override
  void initState() {
    super.initState();
    // Load entries when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EntryBloc>().add(const LoadEntries());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Entries'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<EntryBloc>().add(const LoadEntries());
            },
            tooltip: 'Refresh entries',
          ),
        ],
      ),
      body: BlocConsumer<EntryBloc, EntryState>(
        listener: (context, state) {
          // Show error messages if any
          if (state is EntryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return _buildBody(state);
        },
      ),
    );
  }

  /// Build the appropriate body based on the current state
  Widget _buildBody(EntryState state) {
    if (state is EntryInitial || state is EntryLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is EntryLoaded) {
      if (state.entries.isEmpty) {
        return _buildEmptyState();
      }

      return _buildEntriesList(state.entries);
    }

    if (state is EntryError) {
      return _buildErrorState(state.message);
    }

    // Default loading state
    return const Center(child: CircularProgressIndicator());
  }

  /// Build the empty state when no entries exist
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No entries yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first entry in the New Entry tab',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build the error state
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Error loading entries',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<EntryBloc>().add(const LoadEntries());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Build the list of entries
  Widget _buildEntriesList(List<dynamic> entries) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return EntryCard(
          entry: entry,
          onDelete: () => _handleDeleteEntry(entry.id),
          onSave: () => _handleToggleSaveEntry(entry.id),
          onToggleExpand: () => _handleToggleExpandEntry(entry.id),
        );
      },
    );
  }

  /// Handle deleting an entry
  void _handleDeleteEntry(String entryId) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
          'Are you sure you want to delete this entry? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<EntryBloc>().add(DeleteEntry(entryId: entryId));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Handle toggling save status of an entry
  void _handleToggleSaveEntry(String entryId) {
    context.read<EntryBloc>().add(ToggleSaveEntry(entryId: entryId));
  }

  /// Handle toggling expand status of an entry
  void _handleToggleExpandEntry(String entryId) {
    context.read<EntryBloc>().add(ToggleExpandEntry(entryId: entryId));
  }
}
