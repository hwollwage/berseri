import 'package:flutter/material.dart';

const double faceOutlineAspect = 1.06;

Path faceOutlinePath(Size size) {
  final w = size.width;
  final h = size.height;

  return Path()
    ..moveTo(w * 0.50, h * 0.03)
    ..cubicTo(w * 0.73, h * 0.03, w * 0.89, h * 0.20, w * 0.96, h * 0.47)
    ..cubicTo(w * 1.01, h * 0.68, w * 0.88, h * 0.88, w * 0.68, h * 0.96)
    ..cubicTo(w * 0.58, h * 0.99, w * 0.42, h * 0.99, w * 0.32, h * 0.96)
    ..cubicTo(w * 0.12, h * 0.88, w * -0.01, h * 0.68, w * 0.04, h * 0.47)
    ..cubicTo(w * 0.11, h * 0.20, w * 0.27, h * 0.03, w * 0.50, h * 0.03)
    ..close();
}
