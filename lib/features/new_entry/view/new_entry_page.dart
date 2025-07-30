import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../review/bloc/entry_bloc.dart';
import '../../review/bloc/entry_event.dart';
import '../../review/bloc/entry_state.dart';
import '../widget/getChatBoxBorder.dart' show getChatBoxBorder;

/// Page for creating new entries with auto-deletion functionality
class NewEntryPage extends StatefulWidget {
  const NewEntryPage({super.key});

  @override
  State<NewEntryPage> createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _iconAnimationController;

  @override
  void initState() {
    super.initState();
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<EntryBloc, EntryState>(
        listener: (context, state) {
          // Handle different states
          if (state is EntryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is EntryLoaded) {
            // Entry was successfully added
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Entry saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Character counter
              _buildCharacterCounter(),

              const SizedBox(height: 16),

              // Text input area
              Expanded(child: _buildTextInputArea()),

              const SizedBox(height: 24),

              // Send button
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the character counter widget
  Widget _buildCharacterCounter() {
    final characterCount = _controller.text.length;
    final isOverLimit = characterCount > 1000; // Optional character limit

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$characterCount characters',
          style: TextStyle(
            fontSize: 12,
            color: isOverLimit ? Colors.red : Colors.grey,
            fontWeight: isOverLimit ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  /// Build the text input area
  Widget _buildTextInputArea() {
    return Container(
      decoration: BoxDecoration(
        border: getChatBoxBorder(context),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _controller,
        maxLines: null,
        expands: true,
        maxLength: 1000, // Optional character limit
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          hintText: 'Write your thoughts...',
          counterText: '', // Hide the default counter
        ),
        onChanged: (value) {
          // Trigger rebuild to update character counter
          setState(() {});
        },
      ),
    );
  }

  /// Build the send button with animation
  Widget _buildSendButton() {
    return BlocBuilder<EntryBloc, EntryState>(
      builder: (context, state) {
        final isLoading = state is EntryAdding;

        return Row(
          children: [
            const Spacer(),

            // Send button container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              width: 2.5 * 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  // Animated background trail
                  AnimatedBuilder(
                    animation: _iconAnimationController,
                    builder: (context, child) {
                      final double maxOffset = (2.5 * 48 - 48);
                      return Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: maxOffset * _iconAnimationController.value + 48,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary
                                .withAlpha((0.2 * 255).toInt()),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      );
                    },
                  ),

                  // Animated icon
                  AnimatedBuilder(
                    animation: _iconAnimationController,
                    builder: (context, child) {
                      final double maxOffset = (2.5 * 48 - 48);
                      return Positioned(
                        left: maxOffset * _iconAnimationController.value,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          tooltip: "send",
                          onPressed: isLoading ? null : _handleSend,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                          color: Theme.of(context).colorScheme.primary,
                          iconSize: 32,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Handle sending the entry
  Future<void> _handleSend() async {
    final content = _controller.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some text before sending.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Get current user information
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to create entries.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Play send animation
    await _iconAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 200));

    // Add entry to bloc
    context.read<EntryBloc>().add(
      AddEntry(
        content: content,
        author: authState.user.username, // Use current user's username
        color: _getRandomColor(), // Random color for variety
        autoDeleteAfter: const Duration(hours: 24), // 24 hours default
      ),
    );

    // Clear the text field
    _controller.clear();

    // Reverse animation
    await _iconAnimationController.reverse();
  }

  /// Get a random color for the entry
  Color _getRandomColor() {
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    return colors[DateTime.now().millisecond % colors.length];
  }
}
