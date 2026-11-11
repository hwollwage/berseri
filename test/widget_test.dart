import 'package:berseri/features/analysis/analysis_history_provider.dart';
import 'package:berseri/features/analysis/analysis_record.dart';
import 'package:berseri/features/auth/auth_session_provider.dart';
import 'package:berseri/features/home/dashboard_page.dart';
import 'package:berseri/features/profile/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  testWidgets('greets the restored session user without going through login', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authUserProvider.overrideWith(
            () => _StubAuthUser(_user(fullName: 'Ayu Lestari')),
          ),
          analysisHistoryProvider.overrideWith(
            () => _StubHistory(const <AnalysisRecord>[]),
          ),
        ],
        child: MaterialApp(
          home: DashboardPage(onStartAnalysis: () {}, onOpenIngredients: () {}),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('Ayu Lestari'),
      ),
      findsOneWidget,
    );
    expect(find.text('No analysis yet'), findsOneWidget);
    expect(find.text('Analyze your skin'), findsOneWidget);
  });

  testWidgets('shows the latest analysis when one exists', (tester) async {
    final record = AnalysisRecord(
      date: DateTime(2026, 10, 5),
      skinType: 'combination',
      conditions: const <String>['Acne', 'Redness'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileProvider.overrideWith(() => _StubProfile('Ayu')),
          analysisHistoryProvider.overrideWith(
            () => _StubHistory(<AnalysisRecord>[record]),
          ),
        ],
        child: MaterialApp(
          home: DashboardPage(onStartAnalysis: () {}, onOpenIngredients: () {}),
        ),
      ),
    );

    expect(find.text('Combination'), findsOneWidget);
    expect(find.text('5 Oct 2026'), findsOneWidget);
    expect(find.text('Acne'), findsOneWidget);
    expect(find.text('Redness'), findsOneWidget);
    expect(find.text('See detail result'), findsOneWidget);
    expect(find.text('No analysis yet'), findsNothing);
  });

  testWidgets('starts analysis from the card button', (tester) async {
    var started = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [userProfileProvider.overrideWith(() => _StubProfile('Ayu'))],
        child: MaterialApp(
          home: DashboardPage(
            onStartAnalysis: () => started = true,
            onOpenIngredients: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Start Analysis'));
    await tester.pump();

    expect(started, isTrue);
  });

  group('UserProfile.fromUser', () {
    test('uses the full_name captured at sign-up', () {
      final profile = UserProfile.fromUser(
        _user(fullName: '  Ayu Lestari  ', email: 'ayu@example.com'),
      );

      expect(profile.name, 'Ayu Lestari');
      expect(profile.email, 'ayu@example.com');
    });

    test('falls back to the email prefix when metadata has no name', () {
      final profile = UserProfile.fromUser(
        _user(email: 'janedoe04@gmail.com', metadata: const {}),
      );

      expect(profile.name, 'janedoe04');
      expect(profile.email, 'janedoe04@gmail.com');
    });

    test('ignores a blank full_name', () {
      final profile = UserProfile.fromUser(
        _user(fullName: '   ', email: 'ayu@example.com'),
      );

      expect(profile.name, 'ayu');
    });
  });
}

User _user({
  String email = 'ayu@example.com',
  String? fullName,
  Map<String, dynamic>? metadata,
}) {
  return User(
    id: 'user-id',
    appMetadata: const <String, dynamic>{},
    userMetadata: metadata ?? <String, dynamic>{'full_name': ?fullName},
    aud: 'authenticated',
    email: email,
    createdAt: '2026-01-01T00:00:00Z',
  );
}

class _StubAuthUser extends AuthUserNotifier {
  _StubAuthUser(this._user);

  final User _user;

  @override
  User? build() => _user;
}

class _StubProfile extends UserProfileNotifier {
  _StubProfile(this._name);

  final String _name;

  @override
  UserProfile? build() => UserProfile(name: _name);
}

class _StubHistory extends AnalysisHistoryNotifier {
  _StubHistory(this._records);

  final List<AnalysisRecord> _records;

  @override
  List<AnalysisRecord> build() => _records;
}
