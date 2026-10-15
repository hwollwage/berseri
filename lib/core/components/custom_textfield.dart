import 'package:berseri/core/components/app_spacing.dart';
import 'package:flutter/material.dart';

class CustomTextfield extends StatefulWidget {
  final String label;
  final String? hint;

  final IconData? icon;

  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  final Widget? labelAction;

  const CustomTextfield({
    super.key,
    required this.label,
    this.icon,
    this.hint,
    this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.labelAction,
  });

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  late bool obsecure = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Expanded so a long label (or a large text scale) wraps instead
            // of overflowing the row.
            Expanded(
              child: Text(
                widget.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (widget.labelAction != null) widget.labelAction!,
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        TextFormField(
          controller: widget.controller,
          obscureText: obsecure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.icon == null
                ? null
                : Icon(widget.icon, size: 20),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      obsecure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => obsecure = !obsecure),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
