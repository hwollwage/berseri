import 'dart:async';
import 'dart:math' as math;

import 'package:berseri/core/components/app_radius.dart';
import 'package:berseri/core/components/app_spacing.dart';
import 'package:berseri/core/components/brand.dart';
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

  static const double _ringSize = 160;

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
    final scheme = Theme.of(context).colorScheme;
    final stepNumber = math.min(_done + 1, _steps.length);
    final progress = (_done + 0.5) / _steps.length;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.xxxl,
            AppSpacing.gutter,
            AppSpacing.xxxl,
          ),
          children: [
            // ── Progress ring around the captured photo ─────────────────
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: progress.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, _) => SizedBox(
                  width: _ringSize,
                  height: _ringSize,
                  child: CustomPaint(
                    painter: _RingPainter(
                      progress: value,
                      color: scheme.primary,
                      // `surfaceContainerHighest` rather than `outlineVariant`:
                      // the variant sits at 1.06:1 against the cream page, so
                      // the unfilled part of the ring was invisible and the arc
                      // read as a floating sliver.
                      trackColor: scheme.surfaceContainerHighest,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ClipOval(
                        child: SkinPhoto(path: widget.imagePath),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            Text(
              'Analyzing Your Skin',
              textAlign: TextAlign.center,
              style: BrandText.headline(context, fontSize: 24),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Step $stepNumber of ${_steps.length}, please keep the app '
              'open.',
              textAlign: TextAlign.center,
              style: BrandText.body(context),
            ),

            const SizedBox(height: AppSpacing.xxl),

            _StepsCard(steps: _steps, done: _done),
          ],
        ),
      ),
    );
  }
}

enum _Status { done, inProgress, waiting }

class _StepsCard extends StatelessWidget {
  const _StepsCard({required this.steps, required this.done});

  final List<String> steps;
  final int done;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _StepRow(
              label: steps[i],
              status: i < done
                  ? _Status.done
                  : (i == done ? _Status.inProgress : _Status.waiting),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.label, required this.status});

  final String label;
  final _Status status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isWaiting = status == _Status.waiting;

    final text = switch (status) {
      _Status.done => 'Done',
      _Status.inProgress => 'In progress',
      _Status.waiting => 'Waiting',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          _StatusIcon(status),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isWaiting ? scheme.onSurfaceVariant : scheme.onSurface,
              ),
            ),
          ),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: status == _Status.inProgress
                  ? BrandText.accent(context)
                  : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon(this.status);

  final _Status status;

  static const double _size = 22;
  static const double _core = 6;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    switch (status) {
      case _Status.done:
        return Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            color: scheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: 14, color: scheme.onPrimary),
        );
      case _Status.inProgress:
        return Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: scheme.primary, width: 2),
          ),
          child: Center(
            child: Container(
              width: _core,
              height: _core,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      case _Status.waiting:
        return Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: scheme.outline, width: 2),
          ),
        );
    }
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  static const double _strokeWidth = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_strokeWidth / 2);
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * math.pi, false, track);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor;
}
