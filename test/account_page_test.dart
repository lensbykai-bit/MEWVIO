import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewvio/account/account_page.dart';
import 'package:mewvio/account/account_repository.dart';

class FakeAccounts implements AccountRepository {
  final changes = StreamController<AccountSession?>.broadcast();
  AccountSession? session;
  AccountFailure? failure;
  bool immediateSignUp = false;
  int signUpCalls = 0;
  int signInCalls = 0;
  int saveCalls = 0;
  final profiles = <String, AccountProfile>{
    'alice': const AccountProfile(id: 'alice', displayName: 'Alice', bio: 'Private bio'),
    'bob': const AccountProfile(id: 'bob', displayName: 'Bob'),
  };

  void changeUser(String? id) {
    session = id == null ? null : AccountSession(userId: id, email: '$id@example.com');
    changes.add(session);
  }

  @override
  AccountSession? get currentSession => session;
  @override
  Stream<AccountSession?> get sessionChanges => changes.stream;
  @override
  Future<bool> signUp({required String displayName, required String email, required String password}) async {
    signUpCalls++;
    if (failure != null) throw failure!;
    if (immediateSignUp) changeUser('alice');
    return immediateSignUp;
  }
  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalls++;
    if (failure != null) throw failure!;
    changeUser('alice');
  }
  @override
  Future<void> resendConfirmation(String email) async {
    if (failure != null) throw failure!;
  }
  @override
  Future<AccountProfile> loadProfile() async => profiles[session!.userId]!;
  @override
  Future<AccountProfile> saveProfile({required String displayName, required String? username, required String bio}) async {
    saveCalls++;
    if (failure != null) throw failure!;
    final profile = AccountProfile(
      id: session!.userId, displayName: displayName.trim(),
      username: username?.trim().toLowerCase(), bio: bio.trim(),
    );
    profiles[profile.id] = profile;
    return profile;
  }
  @override
  Future<void> signOut() async => changeUser(null);
}

Future<void> showAccount(WidgetTester tester, FakeAccounts accounts) async {
  tester.view.physicalSize = const Size(1000, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(accounts.changes.close);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: AccountPage(repository: accounts))));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('registration validates before calling Auth', (tester) async {
    final accounts = FakeAccounts();
    await showAccount(tester, accounts);
    await tester.tap(find.text('Create a new account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('account-email')), 'invalid');
    await tester.enterText(find.byKey(const Key('account-password')), 'short');
    await tester.tap(find.byKey(const Key('account-submit')));
    await tester.pumpAndSettle();
    expect(accounts.signUpCalls, 0);
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Use at least 12 characters.'), findsOneWidget);
  });

  testWidgets('registration without session waits for email confirmation', (tester) async {
    final accounts = FakeAccounts();
    await showAccount(tester, accounts);
    await tester.tap(find.text('Create a new account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Display name'), 'Alice');
    await tester.enterText(find.byKey(const Key('account-email')), 'alice@example.com');
    await tester.enterText(find.byKey(const Key('account-password')), 'A-long-password-123');
    await tester.enterText(find.byKey(const Key('account-confirm')), 'A-long-password-123');
    await tester.tap(find.byKey(const Key('account-submit')));
    await tester.pumpAndSettle();
    expect(accounts.signUpCalls, 1);
    expect(find.textContaining('Open the confirmation link'), findsOneWidget);
    expect(find.byKey(const Key('profile-save')), findsNothing);
    final password = tester.widget<TextFormField>(find.byKey(const Key('account-password')));
    expect(password.controller!.text, isEmpty);
    // Remove the form so its resend cooldown cannot outlive the test.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('sign in loads profile, saves edits, and sign out clears it', (tester) async {
    final accounts = FakeAccounts();
    await showAccount(tester, accounts);
    await tester.enterText(find.byKey(const Key('account-email')), 'alice@example.com');
    await tester.enterText(find.byKey(const Key('account-password')), 'existing-password');
    await tester.tap(find.byKey(const Key('account-submit')));
    await tester.pumpAndSettle();
    expect(accounts.signInCalls, 1);
    expect(find.text('Alice'), findsOneWidget);
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('profile-name')), 'Alice Updated');
    await tester.enterText(find.byKey(const Key('profile-username')), 'Alice_01');
    await tester.enterText(find.byKey(const Key('profile-bio')), 'My new private bio');
    await tester.tap(find.byKey(const Key('profile-save')));
    await tester.pumpAndSettle();
    expect(accounts.profiles['alice']!.displayName, 'Alice Updated');
    expect(accounts.profiles['alice']!.username, 'alice_01');
    expect(find.text('Profile saved.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('account-sign-out')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile-name')), findsNothing);
    expect(find.text('alice@example.com'), findsNothing);
    expect(find.text('Alice Updated'), findsNothing);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('failed save keeps edits and does not claim success', (tester) async {
    final accounts = FakeAccounts()..changeUser('alice');
    await showAccount(tester, accounts);
    accounts.failure = const AccountFailure('That username is unavailable. Please choose another.');
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('profile-name')), 'Unsaved edit');
    await tester.tap(find.byKey(const Key('profile-save')));
    await tester.pumpAndSettle();
    expect(accounts.saveCalls, 1);
    expect(accounts.profiles['alice']!.displayName, 'Alice');
    expect(find.text('Profile saved.'), findsNothing);
    expect(find.textContaining('username is unavailable'), findsOneWidget);
    final name = tester.widget<TextFormField>(find.byKey(const Key('profile-name')));
    expect(name.controller!.text, 'Unsaved edit');
  });

  testWidgets('switching users removes the previous private profile', (tester) async {
    final accounts = FakeAccounts()..changeUser('alice');
    await showAccount(tester, accounts);
    expect(find.text('Alice'), findsOneWidget);
    accounts.changeUser('bob');
    await tester.pumpAndSettle();
    expect(find.text('Alice'), findsNothing);
    expect(find.text('alice@example.com'), findsNothing);
    expect(find.text('Bob'), findsOneWidget);
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();
    final bio = tester.widget<TextFormField>(find.byKey(const Key('profile-bio')));
    expect(bio.controller!.text, isEmpty);
  });

  testWidgets('sign in failure displays error without exposing a profile', (tester) async {
    final accounts = FakeAccounts()..failure = const AccountFailure('Email or password is incorrect.');
    await showAccount(tester, accounts);
    await tester.enterText(find.byKey(const Key('account-email')), 'alice@example.com');
    await tester.enterText(find.byKey(const Key('account-password')), 'wrong-password');
    await tester.tap(find.byKey(const Key('account-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Email or password is incorrect.'), findsOneWidget);
    expect(find.byKey(const Key('profile-save')), findsNothing);
  });
}
