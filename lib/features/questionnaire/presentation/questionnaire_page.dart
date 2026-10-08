import 'package:flutter/material.dart';

import '../data/questionnaire_data.dart';
import 'summary_page.dart';
import 'widgets/option_tile.dart';
import 'widgets/progress_bar.dart';

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  int _index = 0;
  final List<int?> _answers = List.filled(questions.length, null);

  void _back() {
    if (_index == 0) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => _index--);
    }
  }

  Future<void> _next() async {
    if (_index < questions.length - 1) {
      setState(() => _index++);
      return;
    }

    final retake = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SummaryPage(answers: _answers),
      ),
    );

    if (!mounted) return;

    if (retake == true) {
      setState(() {
        _index = 0;
        _answers.fillRange(0, _answers.length, null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[_index];

    return Scaffold(
      backgroundColor: const Color(0xFF292828),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: const Color(0xFFFCFAF5),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxWidth < 420;
                    final horizontalPadding = isSmallScreen ? 24.0 : 44.0;
                    final titleSize = isSmallScreen ? 32.0 : 42.0;

                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        isSmallScreen ? 32 : 64,
                        horizontalPadding,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Material(
                                color: Colors.white,
                                shape: const CircleBorder(
                                  side: BorderSide(
                                    color: Color(0xFFEDE7DE),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: _back,
                                  customBorder: const CircleBorder(),
                                  child: const SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: Icon(
                                      Icons.arrow_back,
                                      size: 22,
                                      color: Color(0xFF242424),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: QuestionProgressBar(
                                  current: _index,
                                  total: questions.length,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'Question ${_index + 1} of ${questions.length}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFC47A00),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            question.title,
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w600,
                              height: 1.08,
                              color: const Color(0xFF24211F),
                            ),
                          ),
                          const SizedBox(height: 26),
                          ...List.generate(question.options.length, (i) {
                            return OptionTile(
                              label: question.options[i].label,
                              selected: _answers[_index] == i,
                              onTap: () {
                                setState(() => _answers[_index] = i);
                              },
                            );
                          }),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed:
                                  _answers[_index] == null ? null : _next,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kOrange,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    kOrange.withValues(alpha: 0.4),
                                disabledForegroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Next  >',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}