import 'package:flutter/material.dart';

const kOrange = Color(0xFFF59E0B);
const kCream = Color(0xFFFCFAF5);

class QuestionProgressBar extends StatelessWidget {
  final int current; // 0-based
  final int total;

  const QuestionProgressBar({super.key, required this.current, this.total = 5});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: i <= current ? kOrange : const Color(0xFFE5E2DA),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}