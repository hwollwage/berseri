import 'package:berseri/core/supabase/supabase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthUserNotifier extends Notifier<User?> {
  @override
  User? build() {
    final auth = ref.watch(supabaseClientProvider).auth;

    final subscription = auth.onAuthStateChange.listen(
      (_) => _publish(auth.currentUser),
      onError: (Object _) {},
    );
    ref.onDispose(subscription.cancel);

    return auth.currentUser;
  }

  void _publish(User? user) {
    if (!ref.mounted) return;
    state = user;
  }
}

final authUserProvider = NotifierProvider<AuthUserNotifier, User?>(
  AuthUserNotifier.new,
);
