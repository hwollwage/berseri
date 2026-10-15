import 'package:berseri/core/components/app_back_button.dart';
import 'package:berseri/core/components/app_radius.dart';
import 'package:berseri/core/components/app_spacing.dart';
import 'package:berseri/core/components/brand.dart';
import 'package:berseri/core/components/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/questionnaire_data.dart';
import '../models/question_model.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key, required this.answers});

  final List<int?> answers;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.lg,
                  AppSpacing.gutter,
                  0,
                ),
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AppBackButton(),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'QUESTIONNAIRE COMPLETE',
                    style: BrandText.eyebrow(context),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Review Your Answer',
                    style: BrandText.headline(context),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _AnswersCard(answers: answers),
                ],
              ),
            ),
            _Actions(
              onRetake: () => Navigator.pop(context, true),
              onContinue: () => context.go('/analysis-loading'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswersCard extends StatelessWidget {
  const _AnswersCard({required this.answers});

  final List<int?> answers;

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
          for (var i = 0; i < questions.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _AnswerRow(
              label: questions[i].summaryLabel,
              value: _answerText(
                questions[i],
                i < answers.length ? answers[i] : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _answerText(Question question, int? answer) {
  if (answer == null || answer < 0 || answer >= question.options.length) {
    return '-';
  }
  return question.options[answer].summary;
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.onRetake, required this.onContinue});

  final VoidCallback onRetake;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.lg,
        AppSpacing.gutter,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: onRetake,
            style: TextButton.styleFrom(
              foregroundColor: BrandText.accent(context),
            ),
            child: const Text('Retake'),
          ),
          const SizedBox(height: AppSpacing.sm),
          CustomButton(text: 'Continue', onPressed: onContinue),
        ],
      ),
    );
  }
}
