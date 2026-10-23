import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Photos live only in this Android installation. They are not published,
/// uploaded to Supabase, shared with the web beta or other MEWVIO accounts.
class ProfileLocalPhotos {
  static const maxPhotoBytes = 1200000;

  static Future<({Uint8List? avatar, Uint8List? cover})> load(
      String owner) async {
    final prefs = await SharedPreferences.getInstance();
    Uint8List? decode(String suffix) {
      final base64 = prefs.getString('mewvio_photo_${owner}_${suffix}');
      if (base64 == null) return null;
      try {
        return base64Decode(base64);
      } on FormatException {
        return null;
      }
    }

    return (avatar: decode('avatar'), cover: decode('cover'));
  }

  static Future<void> save(String owner,
      {Uint8List? avatar, Uint8List? cover}) async {
    final prefs = await SharedPreferences.getInstance();
    Future<void> store(String suffix, Uint8List? bytes) async {
      if (bytes != null && bytes.lengthInBytes > maxPhotoBytes) {
        throw const FormatException('Choose a smaller photo (under 1.2 MB).');
      }
      final key = 'mewvio_photo_${owner}_${suffix}';
      if (bytes == null) {
        if (!await prefs.remove(key)) {
          throw StateError('Could not remove local profile photo.');
        }
      } else if (!await prefs.setString(key, base64Encode(bytes))) {
        throw StateError('Could not save local profile photo.');
      }
    }

    await store('avatar', avatar);
    await store('cover', cover);
  }

  static Future<Uint8List?> pick({required bool cover}) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 65,
      maxWidth: cover ? 1280 : 768,
      maxHeight: cover ? 960 : 768,
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    if (bytes.lengthInBytes > maxPhotoBytes) {
      throw const FormatException('Choose a smaller photo (under 1.2 MB).');
    }
    return bytes;
  }
}

class ProfilePhotoPreview extends StatelessWidget {
  const ProfilePhotoPreview({
    super.key,
    required this.label,
    required this.bytes,
    required this.cover,
    required this.onPick,
    this.disabled = false,
  });

  final String label;
  final Uint8List? bytes;
  final bool cover;
  final VoidCallback onPick;
  final bool disabled;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(
              height: cover ? 110 : 95,
              child: bytes == null
                  ? ColoredBox(
                      color: const Color(0xFF33245E),
                      child: Center(
                        child: Icon(
                          cover ? Icons.landscape_outlined : Icons.person,
                          color: Colors.white70,
                          size: 43,
                        ),
                      ),
                    )
                  : Image.memory(bytes!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 7),
          OutlinedButton.icon(
            key: Key(cover ? 'pick-cover-photo' : 'pick-avatar-photo'),
            onPressed: disabled ? null : onPick,
            icon: const Icon(Icons.photo_library_outlined, size: 17),
            label: Text(cover ? 'Choose cover' : 'Choose profile'),
          ),
        ],
      );
}
