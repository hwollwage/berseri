import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

const _brand = Color(0xFFF4B700);

class AnalysisLoadingOverlay extends StatefulWidget {
  const AnalysisLoadingOverlay({super.key});

  @override
  State<AnalysisLoadingOverlay> createState() => _AnalysisLoadingOverlayState();
}

class _AnalysisLoadingOverlayState extends State<AnalysisLoadingOverlay>
    with SingleTickerProviderStateMixin {
  static const _messages = [
    'Reading your photo…',
    'Checking your skin condition…',
    'Preparing your results…',
  ];

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      // Berhenti di pesan terakhir, tidak berputar kembali ke awal.
      setState(() => _index = math.min(_index + 1, _messages.length - 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: ColoredBox(
            color: Colors.black.withValues(alpha: 0.65),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _pulse,
                          builder: (context, child) {
                            final t = _pulse.value;
                            final size = 84 + 56 * t;
                            return Opacity(
                              opacity: (1 - t) * 0.6,
                              child: Container(
                                width: size,
                                height: size,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _brand, width: 3),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: Stack(
                            alignment: Alignment.center,
                            children: const [
                              SizedBox(
                                width: 84,
                                height: 84,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                  color: _brand,
                                ),
                              ),
                              Icon(Icons.auto_awesome,
                                  color: _brand, size: 30),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _messages[_index],
                      key: ValueKey(_index),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please keep the app open',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}