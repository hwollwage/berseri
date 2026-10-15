import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile {
  const UserProfile({required this.name, this.email = ''});

  final String name;
  final String email;
}

class UserProfileNotifier extends Notifier<UserProfile?> {
  @override
  UserProfile? build() => null;

  void setName(String name) {
    final trimmed = name.trim();
    state = trimmed.isEmpty
        ? null
        : UserProfile(name: trimmed, email: state?.email ?? '');
  }

  void updateEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return;
    state = UserProfile(name: state?.name ?? '', email: trimmed);
  }

  void clear() => state = null;
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfile?>(
      UserProfileNotifier.new,
    );

String greetingFor(DateTime time) {
  if (time.hour < 12) return 'Good morning';
  if (time.hour < 18) return 'Good afternoon';
  return 'Good evening';
}
