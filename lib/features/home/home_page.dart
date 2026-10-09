import 'package:berseri/core/components/custom_nav_bar.dart';
import 'package:berseri/features/camera/camera_page.dart';
import 'package:berseri/features/home/dashboard_page.dart';
import 'package:berseri/features/ingredients/ingredients_page.dart';
import 'package:flutter/material.dart';

/// App shell: Home dashboard, Analyze (camera) and the ingredient library.
///
/// The dashboard tab owns its own [CustomNavBar] overlay so the Analyze and
/// Ingredients tabs can each control their own chrome without conflict.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int _homeTab = 0;
  static const int _analyzeTab = 1;
  static const int _ingredientsTab = 2;

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.camera_alt_outlined),
      selectedIcon: Icon(Icons.camera_alt),
      label: 'Analyze',
    ),
    NavigationDestination(
      icon: Icon(Icons.science_outlined),
      selectedIcon: Icon(Icons.science),
      label: 'Ingredients',
    ),
  ];

  int selectedIndex = _homeTab;

  void _selectTab(int index) {
    if (index == selectedIndex) return;
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // The dashboard embeds its own navbar, so only non-home tabs
    // need the shell-level bar.
    if (selectedIndex == _homeTab) {
      return DashboardPage(
        onStartAnalysis: () => _selectTab(_analyzeTab),
        onOpenIngredients: () => _selectTab(_ingredientsTab),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: const [
          SizedBox.shrink(), // placeholder for home – never shown here
          CameraPage(),
          IngredientsPage(),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: _destinations,
      ),
    );
  }
}
