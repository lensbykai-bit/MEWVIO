import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart' show MewvioApp;
import 'account_repository.dart';

/// The entertainment preview can launch without access to account services.
/// Offline accounts never create a session or bypass server-side authorization.
class _UnavailableAccountRepository implements AccountRepository {
  const _UnavailableAccountRepository();
  static const _message = 'Account services are temporarily unavailable. Check your connection and try again later.';
  @override
  AccountSession? get currentSession => null;
  @override
  Stream<AccountSession?> get sessionChanges => const Stream<AccountSession?>.empty();
  @override
  Future<bool> signUp({required String displayName, required String email, required String password}) async =>
      throw const AccountFailure(_message);
  @override
  Future<void> signIn({required String email, required String password}) async =>
      throw const AccountFailure(_message);
  @override
  Future<void> resendConfirmation(String email) async => throw const AccountFailure(_message);
  @override
  Future<AccountProfile> loadProfile() async => throw const AccountFailure(_message);
  @override
  Future<AccountProfile> saveProfile({required String displayName, required String? username, required String bio}) async =>
      throw const AccountFailure(_message);
  @override
  Future<void> signOut() async => throw const AccountFailure(_message);
}

class AccountBootstrap extends StatefulWidget {
  const AccountBootstrap({super.key});
  @override
  State<AccountBootstrap> createState() => _AccountBootstrapState();
}

class _AccountBootstrapState extends State<AccountBootstrap> {
  late Future<AccountRepository> _repository = _initialize();

  Future<AccountRepository> _initialize() async {
    try {
      await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL',
            defaultValue: 'https://swbsevzhudttiwwlcdwl.supabase.co'),
        publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY',
            defaultValue: 'sb_publishable_2GgGavPqGxSlpqfnqcQJ0Q_fG2DzelS'),
      );
      return SupabaseAccountRepository(Supabase.instance.client);
    } catch (error) {
      debugPrint('MEWVIO account service initialization failed: ${error.runtimeType}');
      return const _UnavailableAccountRepository();
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AccountRepository>(
        future: _repository,
        builder: (context, snapshot) {
          final repository = snapshot.data;
          if (repository != null) return MewvioApp(accounts: repository);
          if (snapshot.hasError) {
            // This should be rare: even unexpected bootstrap errors cannot
            // prevent a user from viewing bundled offline sample videos.
            return const MewvioApp(accounts: _UnavailableAccountRepository());
          }
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: SafeArea(child: Center(
              child: CircularProgressIndicator(),
            ))),
          );
        },
      );
}
