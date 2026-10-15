import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisteredAccountsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const <String>{};

  /// `true` when [email] has already been signed up with.
  bool contains(String email) => state.contains(_normalize(email));

  /// Records [email] as signed up; repeat sign-ups are ignored.
  void add(String email) => state = <String>{...state, _normalize(email)};

  static String _normalize(String email) => email.trim().toLowerCase();
}

final registeredAccountsProvider =
    NotifierProvider<RegisteredAccountsNotifier, Set<String>>(
      RegisteredAccountsNotifier.new,
    );
