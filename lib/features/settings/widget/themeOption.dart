import 'package:flutter/material.dart';

Widget themeOption(
  String label,
  ThemeMode mode,
  ThemeMode currentThemeMode,
  void Function(ThemeMode) onThemeModeChanged,
) {
  final selected = currentThemeMode == mode;
  return GestureDetector(
    onTap: () => onThemeModeChanged(mode),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: selected ? Colors.deepPurple : Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            mode == ThemeMode.light
                ? Icons.light_mode
                : mode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.brightness_4,
            color: selected ? Colors.deepPurple : Colors.grey,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: selected ? Colors.deepPurple : Colors.grey)),
        ],
      ),
    ),
  );
}