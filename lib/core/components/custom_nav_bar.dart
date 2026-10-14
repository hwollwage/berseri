import 'package:flutter/material.dart';

/// Floating bottom navigation bar with a capsule pill container and a
/// prominent center action button for the camera/analysis tab.
///
/// Can be reused across any screen in the app.
class CustomNavBar extends StatelessWidget {
  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.destinations,
    this.onCameraTap,
  });

  /// Index of the highlighted destination (0 = Home, 1 = Analyze/Camera, 2 = Ingredients).
  final int selectedIndex;

  /// Called with the index of the destination the user tapped.
  final ValueChanged<int> onDestinationSelected;

  /// Optional list of destinations. If omitted, defaults to Home, Analyze,
  /// and Ingredients.
  final List<NavigationDestination>? destinations;

  /// Optional custom callback when the center camera button is pressed.
  /// If null, [onDestinationSelected] with index 1 is called.
  final VoidCallback? onCameraTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final leftDest = destinations != null && destinations!.isNotEmpty
        ? destinations![0]
        : const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          );

    final centerDest = destinations != null && destinations!.length > 1
        ? destinations![1]
        : const NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'Analyze',
          );

    final rightDest = destinations != null && destinations!.length > 2
        ? destinations![2]
        : const NavigationDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon: Icon(Icons.science),
            label: 'Ingredients',
          );

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Row(
              children: [
                Expanded(
                  child: _NavBarTab(
                    destination: leftDest,
                    isSelected: selectedIndex == 0,
                    onTap: () => onDestinationSelected(0),
                  ),
                ),
                _CenterActionButton(
                  destination: centerDest,
                  isSelected: selectedIndex == 1,
                  onTap: () {
                    if (onCameraTap != null) {
                      onCameraTap!();
                    } else {
                      onDestinationSelected(1);
                    }
                  },
                ),
                Expanded(
                  child: _NavBarTab(
                    destination: rightDest,
                    isSelected: selectedIndex == 2,
                    onTap: () => onDestinationSelected(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarTab extends StatelessWidget {
  const _NavBarTab({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final NavigationDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final iconWidget = isSelected
        ? (destination.selectedIcon ?? destination.icon)
        : destination.icon;

    return InkWell(
      borderRadius: BorderRadius.circular(34),
      onTap: onTap,
      child: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: IconThemeData(
                size: 24,
                color: isSelected ? scheme.primary : scheme.onSurface,
              ),
              child: iconWidget,
            ),
            const SizedBox(height: 3),
            Text(
              destination.label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? scheme.primary : scheme.onSurface,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterActionButton extends StatelessWidget {
  const _CenterActionButton({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final NavigationDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final iconWidget = isSelected
        ? (destination.selectedIcon ?? destination.icon)
        : destination.icon;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: scheme.primary,
        shape: const CircleBorder(),
        elevation: isSelected ? 3 : 1,
        shadowColor: scheme.primary.withValues(alpha: 0.4),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Center(
              child: IconTheme(
                data: IconThemeData(
                  size: 26,
                  color: scheme.onPrimary,
                ),
                child: iconWidget,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
