import 'dart:async';
import 'dart:math' as math;

import 'package:berseri/core/components/app_colors.dart';
import 'package:berseri/features/diagnosis/analysis_result_model.dart';
import 'package:berseri/features/diagnosis/widgets/skin_photo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnalysisLoadingPage extends StatefulWidget {
  final String? imagePath;
  const AnalysisLoadingPage({super.key, this.imagePath});

  @override
  State<AnalysisLoadingPage> createState() => _AnalysisLoadingPageState();
}

class _AnalysisLoadingPageState extends State<AnalysisLoadingPage> {
  static const _steps = [
    'Analyzing your skin',
    'Analyzing skin type',
    'Detecting visible conditions',
    'Preparing your result',
  ];

  int _done = 0; // jumlah langkah yang sudah selesai
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // TODO: ganti timer simulasi ini dengan panggilan ke backend (backend/app.py).
    // Setiap kali satu tahap selesai, panggil setState(() => _done++).
    // Setelah semua selesai, panggil _finish() dengan hasil asli.
    _timer = Timer.periodic(const Duration(milliseconds: 1800), (t) {
      if (!mounted) return;
      setState(() => _done++);
      if (_done >= _steps.length) {
        t.cancel();
        _finish();
      }
    });
  }

  Future<void> _finish() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    context.pushReplacement(
      '/analysis-result',
      extra: AnalysisResult.demo(imagePath: widget.imagePath),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepNumber = math.min(_done + 1, _steps.length);
    final progress = (_done + 0.5) / _steps.length;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.cream, AppColors.peach],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                TweenAnimationBuilder<double>(
                  tween: Tween(end: progress.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, _) => SizedBox(
                    width: 160,
                    height: 160,
                    child: CustomPaint(
                      painter: _ArcPainter(value),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: ClipOval(child: SkinPhoto(path: widget.imagePath)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Analyzing Your Skin',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Step $stepNumber of ${_steps.length}, please keep the app open',
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
                const SizedBox(height: 24),
                Row(
                  children: List.generate(5, (i) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.only(right: i == 4 ? 0 : 6),
                        decoration: BoxDecoration(
                          color: i < _done
                              ? AppColors.orange
                              : const Color(0xFFE5E2DA),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                ...List.generate(_steps.length, (i) {
                  final status = i < _done
                      ? _Status.done
                      : (i == _done ? _Status.inProgress : _Status.waiting);
                  return _StepRow(label: _steps[i], status: status);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _Status { done, inProgress, waiting }

class _StepRow extends StatelessWidget {
  final String label;
  final _Status status;
  const _StepRow({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final text = switch (status) {
      _Status.done => 'Done',
      _Status.inProgress => 'In progress',
      _Status.waiting => 'Waiting',
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x14000000))),
      ),
      child: Row(
        children: [
          _StatusIcon(status),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          Text(text, style: const TextStyle(fontSize: 11, color: Colors.black38)),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final _Status status;
  const _StatusIcon(this.status);

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case _Status.done:
        return const CircleAvatar(
          radius: 11,
          backgroundColor: AppColors.orange,
          child: Icon(Icons.check, size: 14, color: Colors.white),
        );
      case _Status.inProgress:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.orange, width: 2),
          ),
          child: const Icon(Icons.check, size: 13, color: AppColors.orange),
        );
      case _Status.waiting:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.orange, width: 2),
          ),
        );
    }
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  _ArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final rect = Offset.zero & size;
    canvas.drawArc(rect.deflate(2.5), -math.pi / 2, 2 * math.pi * progress, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}