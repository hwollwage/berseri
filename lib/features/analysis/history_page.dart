import 'dart:io';

import 'package:berseri/features/analysis/analysis_history_provider.dart';
import 'package:berseri/features/analysis/analysis_record.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Past analyses, newest first, filed under a heading per month.
class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final history = ref.watch(analysisHistoryProvider);
    final groups = groupByMonth(history);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _BackButton(onTap: () => context.pop()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Text(
                'Analysis History',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
            ),
            Expanded(
              child: groups.isEmpty
                  ? const _EmptyState()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                      children: [
                        for (final group in groups) ...[
                          _MonthHeading(label: group.label),
                          const SizedBox(height: 12),
                          for (final record in group.records) ...[
                            _HistoryCard(
                              record: record,
                              onTap: () => context.push('/result'),
                            ),
                            if (record != group.records.last)
                              const SizedBox(height: 10),
                          ],
                          if (group != groups.last) const SizedBox(height: 24),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One month of history, ready to render.
class HistoryGroup {
  const HistoryGroup({required this.label, required this.records});

  final String label;
  final List<AnalysisRecord> records;
}

/// Splits [records] into month sections, keeping the incoming (newest first)
/// order both between and inside the groups.
List<HistoryGroup> groupByMonth(List<AnalysisRecord> records) {
  final groups = <HistoryGroup>[];

  for (final record in records) {
    final isSameMonth =
        groups.isNotEmpty &&
        groups.last.records.first.monthKey == record.monthKey;

    if (isSameMonth) {
      groups.last.records.add(record);
    } else {
      groups.add(
        HistoryGroup(label: record.monthLabel, records: <AnalysisRecord>[record]),
      );
    }
  }

  return groups;
}

/// Circular back affordance in the top-left of the page.
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerLowest,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.chevron_left_rounded,
            size: 26,
            color: scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _MonthHeading extends StatelessWidget {
  const _MonthHeading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      label,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
        letterSpacing: -0.2,
      ),
    );
  }
}

/// One scan: photo, date, skin type and the conditions that were found.
class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.record, required this.onTap});

  static const double _photoSize = 78;
  static const double _badgeSize = 34;
  static const EdgeInsets _padding = EdgeInsets.all(14);

  /// Gap between the date and the skin type, sized so the text column fills
  /// the photo's height and the card stays as tall as the thumbnail.
  static const double _dateGap = 26;

  final AnalysisRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: _padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Thumbnail(record: record, size: _photoSize),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      record.shortDate,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: _dateGap),
                    Text(
                      record.skinTypeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    if (record.conditions.isNotEmpty)
                      Text(
                        record.conditions.join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.2,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: _badgeSize,
                  width: _badgeSize,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_outward,
                    size: 18,
                    color: scheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The scanned photo, cropped to a circle. Falls back to an icon for records
/// saved without one, or on platforms that cannot read the file back.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.record, required this.size});

  final AnalysisRecord record;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = record.photoPath;
    final canReadFile = !kIsWeb && path != null && path.isNotEmpty;

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: canReadFile
            ? Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (context, _, _) => _Fallback(size: size),
              )
            : _Fallback(size: size),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: scheme.surfaceContainerHigh,
      child: Icon(
        Icons.face_retouching_natural,
        size: size * 0.5,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: 40,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'No analysis yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Run your first scan from the Analyze tab to build up your '
              'history.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
