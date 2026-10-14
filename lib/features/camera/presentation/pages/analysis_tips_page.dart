import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalysisTipsPage extends StatelessWidget {
  const AnalysisTipsPage({super.key, required this.onReady});

  /// Called when the user taps "I'm Ready" — navigates to the real camera.
  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFEFBF6),
              Color(0xFFFDF1DD),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.black.withOpacity(0.05)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 32),

                // Pre-title
                Text(
                  'Before You Start',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFC7841A),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),

                // Main Title
                Text(
                  'Get The Most\nAccurate Result',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w800,
                    fontSize: 32,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 36),

                // Top Divider
                Divider(color: Colors.black.withOpacity(0.05), thickness: 1, height: 1),

                // Tips List
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTipItem(
                          number: '1',
                          title: 'Use good lighting',
                          description:
                              'Take the photo in a bright, evenly lit place. Avoid very dark or harsh lighting.',
                        ),
                        Divider(color: Colors.black.withOpacity(0.05), thickness: 1, height: 1),
                        _buildTipItem(
                          number: '2',
                          title: 'Take the photo without makeup',
                          description:
                              'Avoid makeup or skincare products that may cover your skin, so your skin can be captured clearly.',
                        ),
                        Divider(color: Colors.black.withOpacity(0.05), thickness: 1, height: 1),
                        _buildTipItem(
                          number: '3',
                          title: 'Keep your face clear',
                          description:
                              'Remove anything covering your face, such as masks, glasses, or hair.',
                        ),
                        Divider(color: Colors.black.withOpacity(0.05), thickness: 1, height: 1),
                      ],
                    ),
                  ),
                ),

                // Bottom "I'm Ready" Button
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF39C12),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: onReady,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "I'm Ready",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, size: 22),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem({
    required String number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number.',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF908E8A),
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
