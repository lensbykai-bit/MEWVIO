import 'dart:async';
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

