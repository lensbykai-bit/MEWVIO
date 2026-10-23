import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'account_repository.dart';
import '../profile_local_photos.dart';

const _purple = Color(0xFF6941E7);

class AccountPage extends StatelessWidget {
  const AccountPage({super.key, required this.repository});
  final AccountRepository repository;

  @override
  Widget build(BuildContext context) => StreamBuilder<AccountSession?>(
        stream: repository.sessionChanges,
        initialData: repository.currentSession,
        builder: (context, snapshot) {
          final session = snapshot.data;
          return session == null
              ? _AuthForm(repository: repository)
              : _ProfileView(
                  key: ValueKey(session.userId),
                  repository: repository,
                  session: session,
                );
        },
      );
}

class _AuthForm extends StatefulWidget {
  const _AuthForm({required this.repository});
  final AccountRepository repository;
  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String? _error;
  String? _pendingEmail;
  String? _notice;
  Timer? _cooldown;
  int _seconds = 0;

  @override
  void dispose() {
    _cooldown?.cancel();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldown?.cancel();
    _seconds = 60;
    _cooldown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _seconds--);
      if (_seconds == 0) timer.cancel();
    });
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      if (_register) {
        final signedIn = await widget.repository.signUp(
          displayName: _name.text,
          email: _email.text,
          password: _password.text,
        );
        if (!mounted) return;
        if (!signedIn) {
          setState(() {
            _pendingEmail = _email.text.trim();
            _register = false;
            _startCooldown();
          });
        }
      } else {
        await widget.repository.signIn(
          email: _email.text,
          password: _password.text,
        );
      }
      if (!mounted) return;
      _password.clear();
      _confirm.clear();
    } on AccountFailure catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    final email = _pendingEmail ?? _email.text.trim();
    if (_busy || _seconds > 0) return;
    if (!_validEmail(email)) {
      setState(() => _error = 'Enter your email address first.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      await widget.repository.resendConfirmation(email);
      if (!mounted) return;
      setState(() {
        _notice = 'If confirmation is needed, check your inbox and spam folder.';
        _startCooldown();
      });
    } on AccountFailure catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('My Profile',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          _Card(child: Column(children: [
            SvgPicture.asset('assets/images/mewvio-cat.svg', height: 90),
            const SizedBox(height: 12),
            Text(_register ? 'Join MEWVIO' : 'Welcome to MEWVIO',
                style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Sign in to save and manage your private profile.',
                textAlign: TextAlign.center),
          ])),
          if (_pendingEmail != null) ...[
            const SizedBox(height: 16),
            _Message(
              text: 'Check your email: $_pendingEmail\n'
                  'Open the confirmation link, then return here and sign in. '
                  'Your account may already exist; try signing in if you have confirmed it.',
            ),
          ],
          const SizedBox(height: 16),
          _Card(child: Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (_register) ...[
                TextFormField(
                  controller: _name,
                  enabled: !_busy,
                  decoration: const InputDecoration(labelText: 'Display name'),
                  maxLength: 60,
                  textCapitalization: TextCapitalization.words,
                  validator: _validateName,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                key: const Key('account-email'),
                controller: _email,
                enabled: !_busy,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                validator: (value) => _validEmail(value?.trim() ?? '')
                    ? null : 'Enter a valid email address.',
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('account-password'),
                controller: _password,
                enabled: !_busy,
                decoration: InputDecoration(
                  labelText: 'Password',
                  helperText: _register ? 'At least 12 characters' : null,
                ),
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                autofillHints: [
                  _register ? AutofillHints.newPassword : AutofillHints.password,
                ],
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your password.'
                    : _register && value.length < 12
                        ? 'Use at least 12 characters.' : null,
                onFieldSubmitted: (_) { if (!_register) _submit(); },
              ),
              if (_register) ...[
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('account-confirm'),
                  controller: _confirm,
                  enabled: !_busy,
                  decoration: const InputDecoration(labelText: 'Confirm password'),
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  validator: (value) => value == _password.text
                      ? null : 'Passwords do not match.',
                  onFieldSubmitted: (_) => _submit(),
                ),
              ],
              if (_error != null) _Message(text: _error!, error: true),
              if (_notice != null) _Message(text: _notice!),
              const SizedBox(height: 20),
              FilledButton(
                key: const Key('account-submit'),
                onPressed: _busy ? null : _submit,
                child: Text(_busy ? 'Please wait…' : _register ? 'Create account' : 'Sign in'),
              ),
              TextButton(
                onPressed: _busy ? null : () => setState(() {
                  _register = !_register;
                  _form.currentState?.reset();
                  _password.clear();
                  _confirm.clear();
                  _error = null;
                  _notice = null;
                }),
                child: Text(_register ? 'Already have an account? Sign in' : 'Create a new account'),
              ),
              if (!_register) TextButton(
                key: const Key('resend-confirmation'),
                onPressed: _busy || _seconds > 0 ? null : _resend,
                child: Text(_seconds > 0
                    ? 'Resend confirmation in ${_seconds}s' : 'Resend confirmation email'),
              ),
            ]),
          )),
          const SizedBox(height: 16),
          const Text('Profiles are private in this beta. Chat, matching, voice rooms '
              'and shopping remain demo features.', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          const Text('MEWVIO v0.1.9', textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      );
}

class _ProfileView extends StatefulWidget {
  const _ProfileView({super.key, required this.repository, required this.session});
  final AccountRepository repository;
  final AccountSession session;
  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _bio = TextEditingController();
  AccountProfile? _profile;
  String? _error;
  String? _notice;
  bool _loading = true;
  bool _busy = false;
  bool _editing = false;
  int _activeTab = 0;
  File? _coverImage;
  Uint8List? _coverBytes;
  Uint8List? _avatarBytes;
  bool _changedImages = false;
  bool _choosingCover = false;

  Future<void> _loadPhotos() async {
    try {
      final photos = await ProfileLocalPhotos.load('account_${widget.session.userId}');
      if (!mounted) return;
      setState(() {
        _avatarBytes = photos.avatar;
        _coverBytes = photos.cover;
      });
    } catch (_) {
      // This account never falls back to photos from a different user.
    }
  }

  Future<void> _chooseAvatar() async {
    if (_busy || _choosingCover) return;
    try {
      final bytes = await ProfileLocalPhotos.pick(cover: false);
      if (bytes != null && mounted) {
        setState(() {
          _avatarBytes = bytes;
          _changedImages = true;
          _editing = true;
          _notice = 'Photo selected. Tap Save profile to keep it.';
        });
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to choose profile photo: $error')));
    }
  }

  Future<void> _chooseCover() async {
    if (_choosingCover) return;
    setState(() => _choosingCover = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 65, maxWidth: 1200, maxHeight: 900,
      );
      if (picked != null && mounted) {
        setState(() { _coverImage = File(picked.path); _changedImages = true; _editing = true; _notice = 'Cover selected. Tap Save profile to keep it.'; });
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open gallery. Check photo permissions.')),
      );
    } finally {
      if (mounted) setState(() => _choosingCover = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
    _loadPhotos();
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final profile = await widget.repository.loadProfile();
      if (!mounted) return;
      // Never display a response belonging to a different session.
      if (profile.id != widget.session.userId) {
        throw const AccountFailure('Your session changed. Please sign in again.');
      }
      setState(() {
        _profile = profile;
        _name.text = profile.displayName;
        _username.text = profile.username ?? '';
        _bio.text = profile.bio;
      });
    } on AccountFailure catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() { _busy = true; _error = null; _notice = null; });
    try {
      final profile = await widget.repository.saveProfile(
        displayName: _name.text, username: _username.text, bio: _bio.text,
      );
      if (!mounted) return;
      if (profile.id != widget.session.userId) {
        throw const AccountFailure('Your session changed. Please sign in again.');
      }
      if (_changedImages) {
        final cover = _coverImage == null ? _coverBytes : await _coverImage!.readAsBytes();
        await ProfileLocalPhotos.save('account_${widget.session.userId}',
          avatar: _avatarBytes, cover: cover);
        if (!mounted) return;
        _coverBytes = cover;
        _coverImage = null;
        _changedImages = false;
      }
      setState(() {
        _profile = profile;
        _name.text = profile.displayName;
        _username.text = profile.username ?? '';
        _bio.text = profile.bio;
        _notice = 'Profile saved.';
      });
    } on AccountFailure catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (error) {
      if (mounted) setState(() =>
        _error = 'Photo could not be saved locally: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; _notice = null; });
    try {
      await widget.repository.signOut();
    } on AccountFailure catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _mewvioMenu() {
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true,
      backgroundColor: const Color(0xFF141322), showDragHandle: true,
      builder: (sheet) => SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 5, 18, 22),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('MEWVIO Space', style: TextStyle(color: Colors.white,
            fontSize: 25, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Your creative corner', style: TextStyle(color: Colors.white60)),
          const SizedBox(height: 18),
          ListTile(
            leading: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF7FDDF9)),
            title: const Text('Creator Studio', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Coming soon', style: TextStyle(color: Colors.white54)),
            onTap: () {
              Navigator.pop(sheet);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Creator Studio is planned for a later release.')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined, color: Color(0xFFB38BFF)),
            title: const Text('Settings & Privacy', style: TextStyle(color: Colors.white)),
            onTap: () { Navigator.pop(sheet); _settings(); },
          ),
        ]),
      )),
    );
  }

  void _settings() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const SafeArea(child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Settings & privacy', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
          ListTile(
            leading: Icon(Icons.lock_outline, color: _purple),
            title: Text('Private profile'),
            subtitle: Text('Only your account can read and edit your profile. Sharing is unavailable in this beta.'),
          ),
          ListTile(
            leading: Icon(Icons.shield_outlined, color: _purple),
            title: Text('Safety center'),
            subtitle: Text('Social features are demos. Reporting, blocking and moderation must be connected before public launch.'),
          ),
        ]),
      )),
    );
  }

  Widget _stat(String label) => Expanded(child: Column(children: [
    const Text('0', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19)),
    Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
  ]));

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Row(children: [
            const SizedBox(width: 46),
            Expanded(child: Text(
              _profile?.username == null ? 'My Profile' : '@${_profile!.username}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            )),
            IconButton(tooltip: 'Settings and privacy', onPressed: _mewvioMenu,
                icon: const Icon(Icons.menu_rounded)),
          ]),
          const SizedBox(height: 16),
          if (_loading) const Center(child: CircularProgressIndicator())
          else if (_profile == null) ...[
            _Message(text: _error ?? 'Unable to load your profile.', error: true),
            FilledButton(onPressed: _load, child: const Text('Retry')),
          ] else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: SizedBox(height: 175, child: Stack(fit: StackFit.expand, children: [
                const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF4534A6), Color(0xFF9B56EB), Color(0xFFF48BCB)],
                ))),
                if (_coverImage != null)
                  Image.file(_coverImage!, fit: BoxFit.cover, errorBuilder: (_, __, ___) =>
                    const Center(child: Icon(Icons.image_not_supported, color: Colors.white)))
                else if (_coverBytes != null)
                  Image.memory(_coverBytes!, fit: BoxFit.cover)
                else const Center(child: Text('🐱  MEWVIO  💜',
                    style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900))),
                Positioned(bottom: 11, right: 12, child: FilledButton.icon(
                  onPressed: _busy || _choosingCover ? null : _chooseCover,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xCC231443),
                      foregroundColor: Colors.white),
                  icon: const Icon(Icons.photo_camera_outlined, size: 17),
                  label: Text(_coverImage == null ? 'Add cover' : 'Change cover'),
                )),
              ])),
            ),
            const Text('MEWVIO Cover • private Android photo', textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 11)),
            Transform.translate(offset: const Offset(0, -16), child: Center(child: Container(
              width: 104, height: 104, padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white,
                  border: Border.all(color: _purple, width: 3)),
              child: _avatarBytes == null
                ? SvgPicture.asset('assets/images/mewvio-cat.svg')
                : ClipOval(child: Image.memory(_avatarBytes!, fit: BoxFit.cover)),
            ))),
            const SizedBox(height: 12),
            Text(_profile!.displayName, key: const Key('profile-display-name'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(widget.session.email, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Row(children: [_stat('Following'), _stat('Followers'), _stat('Likes')]),
            const SizedBox(height: 4),
            const Text('Social features preview', textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: FilledButton(
                onPressed: _busy ? null : () => setState(() => _editing = !_editing),
                child: Text(_editing ? 'Close editor' : 'Edit profile'),
              )),
              const SizedBox(width: 9),
              Expanded(child: OutlinedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile sharing is unavailable while profiles are private.')),
                ),
                child: const Text('Share profile'),
              )),
            ]),
            const SizedBox(height: 15),
            if (_profile!.bio.isNotEmpty) Text(_profile!.bio, textAlign: TextAlign.center),
            const Center(child: Chip(avatar: Icon(Icons.lock_outline, size: 18),
                label: Text('Private profile'))),
            if (_error != null && !_editing) _Message(text: _error!, error: true),
            if (_editing) _Card(child: Form(
              key: _form,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Text('Profile and Cover Photos',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: ProfilePhotoPreview(
                    label: 'Profile Photo', bytes: _avatarBytes, cover: false,
                    disabled: _busy,
                    onPick: _chooseAvatar,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Cover Photo',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: SizedBox(height: 95,
                          child: _coverImage != null
                            ? Image.file(_coverImage!, fit: BoxFit.cover)
                            : _coverBytes != null
                              ? Image.memory(_coverBytes!, fit: BoxFit.cover)
                              : const ColoredBox(color: Color(0xFF33245E),
                                  child: Icon(Icons.landscape_outlined,
                                    color: Colors.white, size: 38))),
                      ),
                      const SizedBox(height: 7),
                      OutlinedButton.icon(
                        key: const Key('pick-cover-photo'),
                        onPressed: _busy || _choosingCover ? null : _chooseCover,
                        icon: const Icon(Icons.photo_library_outlined, size: 17),
                        label: const Text('Choose cover'),
                      ),
                    ],
                  )),
                ]),
                const SizedBox(height: 8),
                const Text('Gallery photos are stored privately on this device '
                  'after tapping Save profile. They are not uploaded to Web.',
                  style: TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('profile-name'),
                  controller: _name, enabled: !_busy,
                  decoration: const InputDecoration(labelText: 'Display name'),
                  maxLength: 60, validator: _validateName,
                ),
                TextFormField(
                  key: const Key('profile-username'),
                  controller: _username, enabled: !_busy,
                  decoration: const InputDecoration(labelText: 'Username (optional)', prefixText: '@'),
                  maxLength: 24, autocorrect: false,
                  validator: (value) {
                    final username = value?.trim().toLowerCase() ?? '';
                    return username.isEmpty || RegExp(r'^[a-z0-9_]{3,24}$').hasMatch(username)
                        ? null : 'Use 3–24 letters, numbers or underscores.';
                  },
                ),
                TextFormField(
                  key: const Key('profile-bio'),
                  controller: _bio, enabled: !_busy,
                  decoration: const InputDecoration(labelText: 'Bio'),
                  maxLength: 280, minLines: 2, maxLines: 4,
                ),
                if (_error != null) _Message(text: _error!, error: true),
                if (_notice != null) _Message(text: _notice!),
                const SizedBox(height: 12),
                FilledButton(
                  key: const Key('profile-save'),
                  onPressed: _busy ? null : _save,
                  child: Text(_busy ? 'Please wait…' : 'Save profile'),
                ),
              ]),
            )),
            const SizedBox(height: 20),
            const Divider(height: 1),
            Row(children: [
              for (var index = 0; index < 3; index++) Expanded(child: InkWell(
                onTap: () => setState(() => _activeTab = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(
                    color: _activeTab == index ? _purple : Colors.transparent, width: 3,
                  ))),
                  child: Icon([Icons.grid_on_rounded, Icons.lock_outline_rounded,
                      Icons.favorite_border_rounded][index],
                      color: _activeTab == index ? _purple : Colors.grey),
                ),
              )),
            ]),
            const SizedBox(height: 30),
            Icon([Icons.video_library_outlined, Icons.lock_outline_rounded,
                Icons.favorite_border_rounded][_activeTab], size: 45, color: Colors.grey),
            const SizedBox(height: 12),
            Text(['No posts yet', 'Private posts', 'Liked videos'][_activeTab],
                textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text('Uploads and saved video activity are not connected in this beta.',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            key: const Key('account-sign-out'),
            onPressed: _busy ? null : _signOut,
            icon: const Icon(Icons.logout), label: const Text('Sign out'),
          ),
          const SizedBox(height: 12),
          const Text('© 2026 MEWVIO Technologies. All rights reserved.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      );
}

bool _validEmail(String value) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);

String? _validateName(String? value) => value == null || value.trim().isEmpty
    ? 'Enter your display name.'
    : value.trim().length > 60 ? 'Use at most 60 characters.' : null;

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
        child: child,
      );
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.error = false});
  final String text;
  final bool error;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(text, style: TextStyle(color: error ? Colors.red.shade800 : _purple)),
      );
}
