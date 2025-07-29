import 'package:flutter/material.dart' ;

Border getChatBoxBorder(BuildContext context, {double width = 2.0}) {
  final theme = Theme.of(context);
  // Use a neutral color from the theme's color scheme
  final borderColor = theme.brightness == Brightness.light
      ? Colors.grey[300]!
      : Colors.grey[700]!;
  return Border.all(
    color: borderColor,
    width: width,
  );
}