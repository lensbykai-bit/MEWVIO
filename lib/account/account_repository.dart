import 'package:supabase_flutter/supabase_flutter.dart';

class AccountSession {
  const AccountSession({required this.userId, required this.email});
  final String userId;
  final String email;
}

class AccountProfile {
  const AccountProfile({
    required this.id,
    required this.displayName,
    this.username,
    this.bio = '',
  });

  final String id;
  final String displayName;
  final String? username;
  final String bio;

  factory AccountProfile.fromJson(Map<String, dynamic> row) => AccountProfile(
        id: row['id'] as String,
        displayName: row['display_name'] as String,
        username: row['username'] as String?,
        bio: row['bio'] as String,
      );
}

class AccountFailure implements Exception {
  const AccountFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

abstract interface class AccountRepository {
  AccountSession? get currentSession;
  Stream<AccountSession?> get sessionChanges;
  Future<bool> signUp({
    required String displayName,
    required String email,
    required String password,
  });
  Future<void> signIn({required String email, required String password});
  Future<void> resendConfirmation(String email);
  Future<AccountProfile> loadProfile();
  Future<AccountProfile> saveProfile({
    required String displayName,
    required String? username,
    required String bio,
  });
  Future<void> signOut();
}

/// Uses only the publishable key. Ownership is enforced by database RLS.
class SupabaseAccountRepository implements AccountRepository {
  SupabaseAccountRepository(this._client);
  final SupabaseClient _client;
  static const _columns = 'id,display_name,username,bio';

  AccountSession? _session(Session? session) => session == null
      ? null
      : AccountSession(
          userId: session.user.id,
          email: session.user.email ?? '',
        );

  @override
  AccountSession? get currentSession => _session(_client.auth.currentSession);

  @override
  Stream<AccountSession?> get sessionChanges => _client.auth.onAuthStateChange
      .map((event) => _session(event.session));

  Future<T> _request<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException catch (error) {
      final message = switch (error.code) {
        'invalid_credentials' => 'Email or password is incorrect.',
        'email_not_confirmed' =>
          'Confirm your email before signing in. You can resend the email below.',
        'over_email_send_rate_limit' || 'over_request_rate_limit' =>
          'Too many requests. Please wait a few minutes and try again.',
        'email_address_not_authorized' =>
          'Email delivery is not available for this address yet. Contact MEWVIO support.',
        'user_already_exists' =>
          'Unable to register. Try signing in with your email.',
        'weak_password' => 'Choose a stronger password with at least 12 characters.',
        'signup_disabled' => 'Registration is currently unavailable.',
        _ => 'Unable to complete this account request. Please try again.',
      };
      throw AccountFailure(message);
    } on PostgrestException catch (error) {
      throw AccountFailure(error.code == '23505'
          ? 'That username is unavailable. Please choose another.'
          : 'Unable to access your profile. Please try again.');
    } on AccountFailure {
      rethrow;
    } catch (_) {
      throw const AccountFailure(
          'Unable to connect. Check your internet connection and try again.');
    }
  }

  @override
  Future<bool> signUp({
    required String displayName,
    required String email,
    required String password,
  }) =>
      _request(() async {
        final result = await _client.auth.signUp(
          email: email.trim(),
          password: password,
          // Display information only; never used for permissions.
          data: {'display_name': displayName.trim()},
        );
        return result.session != null;
      });

  @override
  Future<void> signIn({required String email, required String password}) =>
      _request(() async {
        await _client.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );
      });

  @override
  Future<void> resendConfirmation(String email) => _request(() async {
        await _client.auth.resend(type: OtpType.signup, email: email.trim());
      });

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AccountFailure('Please sign in again.');
    return id;
  }

  @override
  Future<AccountProfile> loadProfile() => _request(() async {
        final id = _userId;
        final row = await _client
            .from('profiles')
            .select(_columns)
            .eq('id', id)
            .maybeSingle();
        if (row != null) return AccountProfile.fromJson(row);

        final name = _client.auth.currentUser?.userMetadata?['display_name'];
        final displayName = name is String &&
                name.trim().isNotEmpty &&
                name.trim().length <= 60
            ? name.trim()
            : 'MEWVIO Friend';
        try {
          final created = await _client.from('profiles').insert({
            'id': id,
            'display_name': displayName,
          }).select(_columns).single();
          return AccountProfile.fromJson(created);
        } on PostgrestException catch (error) {
          // A second device may have created the profile during this request.
          if (error.code != '23505') rethrow;
          final created = await _client
              .from('profiles')
              .select(_columns)
              .eq('id', id)
              .single();
          return AccountProfile.fromJson(created);
        }
      });

  @override
  Future<AccountProfile> saveProfile({
    required String displayName,
    required String? username,
    required String bio,
  }) =>
      _request(() async {
        final row = await _client
            .from('profiles')
            .update({
              'display_name': displayName.trim(),
              'username': username == null || username.trim().isEmpty
                  ? null
                  : username.trim().toLowerCase(),
              'bio': bio.trim(),
            })
            .eq('id', _userId)
            .select(_columns)
            .single();
        return AccountProfile.fromJson(row);
      });

  @override
  Future<void> signOut() => _request(() => _client.auth.signOut());
}
