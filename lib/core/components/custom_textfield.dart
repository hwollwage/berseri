import 'package:flutter/material.dart';

class CustomTextfield extends StatefulWidget {
  final String label;
  final String? hint;
  final IconData icon;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Widget? labelAction;

  const CustomTextfield({
    super.key,
    required this.label,
    required this.icon,
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

  OutlineInputBorder border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(
              widget.label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (widget.labelAction != null) widget.labelAction!,
          ],
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: widget.controller,
          obscureText: obsecure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            fillColor: cs.surfaceContainerLowest,
            prefixIcon: Icon(widget.icon, size: 20),
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
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: border(cs.outlineVariant),
            focusedBorder: border(cs.primary, width: 1.5),
            errorBorder: border(cs.error),
            focusedErrorBorder: border(cs.error, width: 1.5),
          ),
        ),
      ],
    );
  }
}
