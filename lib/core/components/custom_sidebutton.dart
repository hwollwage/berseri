import 'package:flutter/material.dart';

class CustomSidebutton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool visible;
  final bool active;

  const CustomSidebutton({
    required this.icon,
    required this.onTap,
    this.visible = true,
    this.active = false,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: visible ? 1 : 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? Colors.white : Colors.black38,
            ),
            child: Icon(
              icon,
              color: active ? Colors.black87 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}