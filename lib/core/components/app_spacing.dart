abstract final class AppSpacing {
  /// 4 — hairline gaps, icon-to-label nudges.
  static const double xs = 4;

  /// 8 — gap between a label and its field, chips in a wrap.
  static const double sm = 8;

  /// 12 — gap between list rows.
  static const double md = 12;

  /// 16 — gap inside a group of related content.
  static const double lg = 16;

  /// 20 — gap between blocks on a page.
  static const double xl = 20;

  /// 28 — gap between sections.
  static const double xxl = 28;

  /// 32 — gap between a page's major regions.
  static const double xxxl = 32;

  /// Horizontal page padding. Every screen's content starts and ends here.
  static const double gutter = 20;

  /// Inner padding of a card.
  static const double cardPadding = 20;

  /// Bottom padding a scrollable needs so its last card clears the floating
  /// `CustomNavBar` instead of hiding behind it.
  static const double navBarInset = 110;
}
