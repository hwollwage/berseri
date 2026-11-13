import 'dart:async';
import 'dart:math' as math;

import 'package:berseri/core/components/app_radius.dart';
import 'package:berseri/core/components/app_spacing.dart';
import 'package:berseri/core/components/brand.dart';
import 'package:berseri/core/components/custom_button.dart';
import 'package:berseri/features/analysis/analysis_repository.dart';
import 'package:berseri/features/diagnosis/widgets/skin_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AnalysisLoadingPage extends ConsumerStatefulWidget {
  const AnalysisLoadingPage({super.key});

  @override
  ConsumerState<AnalysisLoadingPage> createState() => _AnalysisLoadingPageState();
}

class _AnalysisLoadingPageState extends ConsumerState<AnalysisLoadingPage> {
  static const List<String> _steps = [
    'Uploading your photo',
    'Saving your analysis',
    'Preparing your result',
  ];

  static const double _ringSize = 160;

  int _done = 0; // jumlah langkah yang sudah selesai
  Object? _error;
  bool _started = false;

  bool _missingDraft = false;

  String? _photoPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _save());
  }

  Future<void> _save() async {
    if (_started) return;
    _started = true;

    final draft = ref.read(analysisDraftProvider);
    if (draft == null || draft.skinType == null) {
      if (!mounted) return;
      setState(() => _missingDraft = true);
      return;
    }

    final repository = ref.read(analysisRepositoryProvider);

    try {
      setState(() {
        _error = null;
        _done = 0;
      });

      final photoPath = _photoPath ?? await repository.uploadPhoto(draft.photo);
      if (!mounted) return;
      setState(() {
        _photoPath = photoPath;
        _done = 1;
      });

      final entry = await repository.save(draft, photoPath: photoPath);

      if (!mounted) return;
      setState(() => _done = _steps.length);

      ref.read(analysisDraftProvider.notifier).clear();
      ref.invalidate(analysisHistoryEntriesProvider);
      ref.invalidate(latestAnalysisEntryProvider);

      context.pushReplacement('/analysis-result', extra: entry);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _started = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _done = 0;
      _error = null;
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final draft = ref.watch(analysisDraftProvider);
    final stepNumber = math.min(_done + 1, _steps.length);
    final progress = _error != null || _missingDraft
        ? 0.0
        : (_done + 0.5) / _steps.length;

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
                      trackColor: scheme.surfaceContainerHighest,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ClipOval(
                        child: SkinPhoto(path: draft?.photo?.path),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            Text(
              _missingDraft
                  ? 'Nothing to save'
                  : (_error == null ? 'Analyzing Your Skin' : 'Could not save'),
              textAlign: TextAlign.center,
              style: BrandText.headline(context, fontSize: 24),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _missingDraft
                  ? 'Take a photo first, answer the questions, then come back '
                        'to this screen.'
                  : (_error == null
                        ? 'Step $stepNumber of ${_steps.length}, please keep '
                              'the app open.'
                        : 'Your scan is still here. Check your connection and '
                              'try again.'),
              textAlign: TextAlign.center,
              style: BrandText.body(context),
            ),

            const SizedBox(height: AppSpacing.xxl),

            if (_missingDraft)
              CustomButton(
                text: 'Start a scan',
                onPressed: () => context.go('/camera'),
              )
            else if (_error != null)
              CustomButton(text: 'Try again', onPressed: _retry)
            else
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
