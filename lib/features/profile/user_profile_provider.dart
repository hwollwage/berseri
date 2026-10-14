import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The signed-in user. Only the display name is needed by the dashboard.
class UserProfile {
  const UserProfile({required this.name});

  final String name;
}

/// Holds the signed-in user for the running session.
///
/// Nothing populates it yet: the auth screens are still placeholders, so the
/// dashboard greets the user without a name until [setName] is called from
/// the sign-in flow.
class UserProfileNotifier extends Notifier<UserProfile?> {
  @override
  UserProfile? build() => null;

  void setName(String name) {
    final trimmed = name.trim();
    state = trimmed.isEmpty ? null : UserProfile(name: trimmed);
  }

  void clear() => state = null;
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfile?>(
      UserProfileNotifier.new,
    );

/// `Good morning` / `Good afternoon` / `Good evening` for [time].
String greetingFor(DateTime time) {
  if (time.hour < 12) return 'Good morning';
  if (time.hour < 18) return 'Good afternoon';
  return 'Good evening';
}
