import 'package:flutter/material.dart';
import '../data/entry_model.dart';
import 'countdown_timer.dart';

/// Widget that displays a single entry card with auto-deletion countdown
class EntryCard extends StatelessWidget {
  final Entry entry;
  final VoidCallback onDelete;
  final VoidCallback onSave;
  final VoidCallback onToggleExpand;

  const EntryCard({
    super.key,
    required this.entry,
    required this.onDelete,
    required this.onSave,
    required this.onToggleExpand,
  });

  /// Maximum characters to show before truncating
  static const int _maxCharacters = 280;

  @override
  Widget build(BuildContext context) {
    final isLongContent = entry.content.length > _maxCharacters;
    final displayContent = entry.isExpanded 
        ? entry.content 
        : entry.content.length > _maxCharacters 
            ? '${entry.content.substring(0, _maxCharacters)}...'
            : entry.content;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with avatar, author, time, and countdown
            _buildHeader(context),
            
            const SizedBox(height: 12),
            
            // Content section with expandable text
            _buildContent(context, displayContent, isLongContent),
            
            const SizedBox(height: 12),
            
            // Action buttons section
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  /// Build the header section with avatar, author info, and countdown timer
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          backgroundColor: entry.color.withAlpha(39),
          child: Text(
            entry.author.split(' ').map((e) => e[0]).take(2).join(),
            style: TextStyle(
              color: entry.color, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Author and time info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.author, 
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              Text(
                entry.formattedTime, 
                style: const TextStyle(
                  fontSize: 12, 
                  color: Colors.grey
                )
              ),
            ],
          ),
        ),
        
        // Countdown timer
        CountdownTimer(
          entry: entry,
          onExpired: () {
            // This will be handled by the bloc's auto-deletion timer
          },
        ),
      ],
    );
  }

  /// Build the content section with expandable text
  Widget _buildContent(BuildContext context, String displayContent, bool isLongContent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main content text
        Text(
          displayContent,
          style: const TextStyle(fontSize: 16),
        ),
        
        // Show "Read more" button for long content
        if (isLongContent) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onToggleExpand,
            child: Text(
              entry.isExpanded ? 'Read less' : 'Read more',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Build the action buttons section
  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        // Preserve/Save button
        OutlinedButton.icon(
          key: ValueKey('save_${entry.id}'),
          onPressed: onSave,
          icon: Icon(
            entry.isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: entry.isSaved ? Colors.blue : Colors.grey,
          ),
          label: Text(
            entry.isSaved ? 'Preserved' : 'Preserve',
            style: TextStyle(
              color: entry.isSaved ? Colors.blue : Colors.grey,
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Delete button
        OutlinedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete, color: Colors.red),
          label: const Text(
            'Delete', 
            style: TextStyle(color: Colors.red)
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
          ),
        ),
      ],
    );
  }
} 

