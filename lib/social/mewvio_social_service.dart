import 'dart:math';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Closed beta. Real posts and private chats use per-row database authorization.
/// No privileged keys ever ship in the Android client.
class MewvioSocialService {
  MewvioSocialService(this.client);

  final SupabaseClient client;
  static const bucket = 'mewvio-social-images';

  String get me {
    final id = client.auth.currentUser?.id;
    if (id == null) throw StateError('Please sign in to use MEWVIO Social.');
    return id;
  }

  Future<Map<String, dynamic>?> myMember() async {
    final row = await client.from('social_members')
      .select('user_id,handle,display_name').eq('user_id', me).maybeSingle();
    return row;
  }

  Future<void> join(String handle, String displayName) async {
    final normalized = handle.trim().toLowerCase().replaceFirst(RegExp(r'^@'), '');
    if (!RegExp(r'^[a-z0-9_]{3,24}$').hasMatch(normalized)) {
      throw const FormatException('Handle must be 3–24 lowercase letters, digits or underscores.');
    }
    final name = displayName.trim();
    if (name.isEmpty || name.length > 60) {
      throw const FormatException('Display name must contain 1–60 characters.');
    }
    await client.from('social_members').upsert({
      'user_id': me, 'handle': normalized, 'display_name': name
    }, onConflict: 'user_id');
  }

  Future<List<Map<String, dynamic>>> members() async {
    final result = await client.from('social_members')
      .select('user_id,handle,display_name').order('handle').limit(80);
    return List<Map<String, dynamic>>.from(result);
  }

  Future<List<Map<String, dynamic>>> posts() async {
    final result = await client.from('social_posts')
      .select('id,author_id,body,image_path,created_at')
      .order('created_at', ascending: false).limit(35);
    final rows = List<Map<String, dynamic>>.from(result);
    for (final row in rows) {
      final path = row['image_path'] as String?;
      if (path != null) {
        try {
          row['signed_url'] = await client.storage.from(bucket)
            .createSignedUrl(path, 600);
        } catch (_) {
          row['signed_url'] = null;
        }
      }
    }
    return rows;
  }

  Future<XFile?> choosePhoto() => ImagePicker().pickImage(
    source: ImageSource.gallery, imageQuality: 68,
    maxWidth: 1280, maxHeight: 1600,
  );

  Future<void> publish(String message, XFile? photo) async {
    final body = message.trim();
    if (body.isEmpty && photo == null) throw const FormatException('Enter text or select a photo.');
    if (body.length > 500) throw const FormatException('Maximum 500 characters.');
    String? path;
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      if (bytes.length > 3 * 1024 * 1024) {
        throw const FormatException('Photos must be smaller than 3 MB.');
      }
      final ext = _photoExtension(bytes);
      final unique = Random.secure().nextInt(1 << 32).toRadixString(16);
      path = '$me/${DateTime.now().microsecondsSinceEpoch}_$unique.$ext';
      await client.storage.from(bucket).uploadBinary(path, Uint8List.fromList(bytes),
        fileOptions: FileOptions(contentType: ext == 'png'
            ? 'image/png' : ext == 'webp' ? 'image/webp' : 'image/jpeg', upsert: false));
    }
    try {
      await client.from('social_posts').insert({
        'author_id': me, 'body': body, 'image_path': path,
      });
    } catch (_) {
      if (path != null) {
        try { await client.storage.from(bucket).remove([path]); } catch (_) {}
      }
      rethrow;
    }
  }

  String _photoExtension(Uint8List b) {
    if (b.length >= 3 && b[0] == 0xff && b[1] == 0xd8 && b[2] == 0xff) return 'jpg';
    if (b.length >= 8 && b[0] == 137 && b[1] == 80 && b[2] == 78 && b[3] == 71) return 'png';
    if (b.length >= 12 && String.fromCharCodes(b.sublist(0, 4)) == 'RIFF'
      && String.fromCharCodes(b.sublist(8, 12)) == 'WEBP') return 'webp';
    throw const FormatException('Choose a JPG, PNG or WebP photo.');
  }

  Future<void> deletePost(int id) async =>
    client.from('social_posts').delete().eq('id', id).eq('author_id', me);

  Future<List<Map<String, dynamic>>> requests() async {
    final result = await client.from('social_requests')
      .select('id,sender_id,receiver_id,status,created_at')
      .or('sender_id.eq.$me,receiver_id.eq.$me')
      .order('created_at', ascending: false).limit(100);
    return List<Map<String, dynamic>>.from(result);
  }

  Future<void> requestFriend(String peer) async {
    if (peer == me) throw const FormatException('Cannot send a request to yourself.');
    await client.from('social_requests').insert({
      'sender_id': me, 'receiver_id': peer, 'status': 'pending',
    });
  }

  Future<void> respond(int requestId, {required bool accept}) async {
    await client.from('social_requests').update({
      'status': accept ? 'accepted' : 'declined'
    }).eq('id', requestId).eq('receiver_id', me);
  }

  Future<void> cancelRequest(int requestId) async {
    await client.from('social_requests').delete()
      .eq('id', requestId).eq('sender_id', me);
  }

  Future<List<Map<String, dynamic>>> messages(int requestId) async {
    final result = await client.from('social_messages')
      .select('id,sender_id,receiver_id,body,created_at')
      .eq('request_id', requestId).order('created_at').limit(150);
    return List<Map<String, dynamic>>.from(result);
  }

  Future<void> sendMessage(int requestId, String receiver, String text) async {
    final body = text.trim();
    if (body.isEmpty || body.length > 700) throw const FormatException('Enter 1–700 characters.');
    await client.from('social_messages').insert({
      'request_id': requestId, 'sender_id': me,
      'receiver_id': receiver, 'body': body,
    });
  }

  Future<void> report({String? member, int? post, int? message,
    String reason = 'other'}) async {
    await client.from('social_reports').insert({
      'reporter_id': me, 'reported_user_id': member,
      'post_id': post, 'message_id': message, 'reason': reason,
    });
  }

  Future<void> block(String member) async {
    await client.from('social_blocks').upsert({
      'blocker_id': me, 'blocked_id': member,
    });
  }

  Future<void> unblock(String member) async {
    await client.from('social_blocks').delete()
      .eq('blocker_id', me).eq('blocked_id', member);
  }
}
