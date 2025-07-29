import 'package:flutter/material.dart';
import '../widget/getChatBoxBorder.dart' show getChatBoxBorder;

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
    // Remove the automatic forward() call and the problematic listener
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: getChatBoxBorder(context),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    hintText: 'Write your thoughts...',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Spacer to push the send button to the right
                const Spacer(),

                // Send button container with fixed size, border, and background
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  width: 2.5 * 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface, // Button background matches theme
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      // Animated background trail that grows as the icon moves
                      AnimatedBuilder(
                        animation: _iconAnimationController,
                        builder: (context, child) {
                          final double maxOffset = (2.5 * 48 - 48);
                          return Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            // The width of the trail matches the icon's position
                            width: maxOffset * _iconAnimationController.value + 48,
                            child: Container(
                              decoration: BoxDecoration(
                                // Use withAlpha for theme-matching, semi-transparent color
                                color: Theme.of(context).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          );
                        },
                      ),
                      // Animated icon that moves from left to right inside the button
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
                              onPressed: () async {
                                if (_controller.text.trim().isNotEmpty) {
                                  await _iconAnimationController.forward();
                                  await Future.delayed(const Duration(milliseconds: 200));
                                  _controller.clear();
                                  await _iconAnimationController.reverse();
                                }
                              },
                              icon: const Icon(Icons.send_rounded),
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
            ),
          ],
        ),
      ),
    );
  }
}