import 'package:flutter/material.dart';
import 'dart:async';
import '../data/entry_model.dart';

/// Widget that displays a countdown timer for entry auto-deletion
class CountdownTimer extends StatefulWidget {
  final Entry entry;
  final VoidCallback? onExpired;

  const CountdownTimer({
    super.key,
    required this.entry,
    this.onExpired,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTimeRemaining();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.id != widget.entry.id) {
      _updateTimeRemaining();
    }
  }

  /// Start the countdown timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateTimeRemaining();
        });
        
        // Check if entry has expired
        if (_timeRemaining.inSeconds <= 0) {
          widget.onExpired?.call();
        }
      }
    });
  }

  /// Update the remaining time
  void _updateTimeRemaining() {
    _timeRemaining = widget.entry.timeUntilDeletion;
  }

  @override
  Widget build(BuildContext context) {
    // Don't show timer for saved entries
    if (widget.entry.isSaved) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark,
              size: 14,
              color: Colors.green,
            ),
            const SizedBox(width: 4),
            Text(
              'Preserved',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Show countdown for non-saved entries
    final isExpired = _timeRemaining.inSeconds <= 0;
    final isWarning = _timeRemaining.inMinutes < 5; // Warning when less than 5 minutes

    Color backgroundColor;
    Color textColor;
    IconData iconData;

    if (isExpired) {
      backgroundColor = Colors.red.withOpacity(0.1);
      textColor = Colors.red;
      iconData = Icons.timer_off;
    } else if (isWarning) {
      backgroundColor = Colors.orange.withOpacity(0.1);
      textColor = Colors.orange;
      iconData = Icons.timer;
    } else {
      backgroundColor = Colors.grey.withOpacity(0.1);
      textColor = Colors.grey;
      iconData = Icons.timer_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDuration(_timeRemaining),
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    if (duration.inSeconds <= 0) {
      return 'Expired';
    }
    
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
} 