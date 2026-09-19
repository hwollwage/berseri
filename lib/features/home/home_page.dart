import 'package:berseri/app/theme.dart';
import 'package:berseri/core/components/berseri_logo.dart';
import 'package:berseri/features/camera/camera_page.dart';
import 'package:berseri/features/diagnosis/diagnosis_page.dart';
import 'package:berseri/features/routine/routine_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    CameraPage(), 
    DiagnosisPage(), 
    RoutinePage()
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: BerseriLogo(
          icon: isDark ? Icons.dark_mode : Icons.light_mode,
          onIconTap: () => ref
              .read(themeModeNotifier.notifier)
              .setMode(isDark ? ThemeMode.light : ThemeMode.dark),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 16,
                  child: Icon(Icons.person, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),

      body: pages[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: "Scan"),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.heartPulse),
            label: "Diagnostic",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.wandMagicSparkles, size: 20),
            label: "Routine",
          ),
        ],
      ),
    );
  }
}
