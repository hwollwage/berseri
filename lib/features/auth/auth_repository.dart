import 'package:berseri/core/supabase/supabase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: <String, dynamic>{'full_name': fullName},
    );
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> verifyPassword(String password) async {
    final email = currentEmail;
    if (email == null) throw AuthSessionMissingException();

    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<UserResponse> updatePassword(String password) {
    return _client.auth.updateUser(UserAttributes(password: password));
  }

  Future<UserResponse> updateEmail(String email) {
    return _client.auth.updateUser(UserAttributes(email: email));
  }

  String? get currentEmail => _client.auth.currentUser?.email;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});