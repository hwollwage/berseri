import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasOverride = backgroundColor != null || textColor != null;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: hasOverride
            ? FilledButton.styleFrom(
                backgroundColor: backgroundColor ?? scheme.primary,
                foregroundColor: textColor ?? scheme.onPrimary,
              )
            : null,
        child: Text(text),
      ),
    );
  }
}
