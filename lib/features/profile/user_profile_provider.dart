import 'dart:async';

import 'package:berseri/core/supabase/supabase_service.dart';
import 'package:berseri/features/auth/auth_session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  const UserProfile({required this.name, this.email = ''});

  factory UserProfile.fromUser(User user) {
    final email = user.email ?? '';
    return UserProfile(
      name: metadataFullName(user) ?? _emailPrefix(email),
      email: email,
    );
  }

  final String name;
  final String email;

  @override
  bool operator ==(Object other) =>
      other is UserProfile && other.name == name && other.email == email;

  @override
  int get hashCode => Object.hash(name, email);

  static String _emailPrefix(String email) {
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : '';
  }
}

String? metadataFullName(User user) {
  final raw = user.userMetadata?['full_name'];
  if (raw is! String) return null;
  final trimmed = raw.trim();
  return trimmed.isEmpty ? null : trimmed;
}

class UserProfileNotifier extends Notifier<UserProfile?> {
  int _generation = 0;

  @override
  UserProfile? build() {
    final user = ref.watch(authUserProvider);
    final generation = ++_generation;
    if (user == null) return null;

    final profile = UserProfile.fromUser(user);
    if (metadataFullName(user) == null) {
      unawaited(_fillNameFromProfiles(profile, user.id, generation));
    }
    return profile;
  }

  Future<void> _fillNameFromProfiles(
    UserProfile profile,
    String userId,
    int generation,
  ) async {
    final client = ref.read(supabaseClientProvider);

    final String? stored;
    try {
      final row = await client
          .from('profiles')
          .select('full_name')
          .eq('id', userId)
          .maybeSingle()
          .timeout(const Duration(seconds: 3));
      final value = row?['full_name'];
      stored = value is String ? value.trim() : null;
    } catch (_) {
      // Table missing, RLS denied, or offline: the email prefix already shows.
      return;
    }

    if (stored == null || stored.isEmpty) return;
    if (!ref.mounted || generation != _generation) return;
    if (stored == state?.name) return;
    state = UserProfile(name: stored, email: profile.email);
  }
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
