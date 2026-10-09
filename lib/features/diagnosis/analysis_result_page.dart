import 'package:berseri/core/components/app_colors.dart';
import 'package:berseri/features/diagnosis/analysis_result_model.dart';
import 'package:berseri/features/diagnosis/widgets/skin_photo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnalysisResultPage extends StatelessWidget {
  final AnalysisResult result;
  const AnalysisResultPage({super.key, required this.result});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get _dateText {
    final d = result.date;
    return '${_months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.cream, AppColors.peach],
          ),
        ),
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  _Header(
                    date: _dateText,
                    skinType: result.skinType,
                    onBack: () =>
                        context.canPop() ? context.pop() : context.go('/'),
                  ),
                  const SizedBox(height: 190), // ruang untuk foto yang menimpa header
                  _Body(result: result),
                ],
              ),
              Positioned(
                top: 200,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 200,
                    height: 270,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.orange, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SkinPhoto(path: result.imagePath),
                    ),
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

class _Header extends StatelessWidget {
  final String date;
  final String skinType;
  final VoidCallback onBack;
  const _Header({required this.date, required this.skinType, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 290,
      decoration: const BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: onBack,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFCE3B0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_left, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 20),
              Text(date, style: const TextStyle(fontSize: 12, color: Colors.white)),
              const SizedBox(height: 6),
              Text(
                'Skin Type - $skinType',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final AnalysisResult result;
  const _Body({required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 32), // 80 = sisa tinggi foto di bawah header
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Skin Conditions',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brown,
                ),
              ),
              Text(
                '${result.conditions.length} detected',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.conditions
                .map(
                  (c) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(c, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recommended Ingredients',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.brown,
            ),
          ),
          const SizedBox(height: 10),
          ...result.ingredients.map(
            (ing) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.orange,
                    child: Text(
                      ing.name[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ing.name, style: const TextStyle(fontSize: 18)),
                      Text(ing.purpose, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}