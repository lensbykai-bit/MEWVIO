import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _bg = Color(0xFF090F22);
const _panel = Color(0xFF141C36);
const _line = Color(0xFF29324D);
const _white = Color(0xFFF7F9FF);
const _muted = Color(0xFFA8B2CE);
const _pink = Color(0xFFF25CBB);
const _cyan = Color(0xFF4DDBF5);
const _purple = Color(0xFF8C66F2);

/// Public social discovery preview. Nothing here is synchronized to a server;
/// sample profiles, posts, communities and interactions are not real users.
class SocialHomePage extends StatefulWidget {
  const SocialHomePage({
    super.key,
    required this.onVideos,
    required this.onMatch,
    required this.onVoice,
    required this.onChat,
    required this.onCreate,
  });

  final VoidCallback onVideos;
  final VoidCallback onMatch;
  final VoidCallback onVoice;
  final VoidCallback onChat;
  final VoidCallback onCreate;

  @override
  State<SocialHomePage> createState() => _SocialHomePageState();
}

class _Post {
  const _Post({
    required this.name,
    required this.handle,
    required this.text,
    required this.image,
    required this.avatar,
    required this.time,
  });
  final String name, handle, text, image, avatar, time;
}

class _SocialHomePageState extends State<SocialHomePage> {
  String query = '';
  bool groupsOnly = false;
  final liked = <int>{};
  final followed = <String>{};
  final hidden = <int>{};
  final joined = <String>{};
  final localPosts = <String>[];
  final comments = <int, List<String>>{};

  static const samples = <_Post>[
    _Post(
      name: 'Luna • Demo', handle: '@luna_preview', time: 'Preview post',
      text: 'A little sunset, a little music, and a lot of good energy. 🌅',
      image: 'assets/demo/hero_sunset.jpg',
      avatar: 'assets/demo/portrait_luna.jpg',
    ),
    _Post(
      name: 'Sophie • Demo', handle: '@sophie_preview', time: 'Preview post',
      text: 'Creating together is better. What should we make next? 🎬',
      image: 'assets/demo/concert.jpg',
      avatar: 'assets/demo/portrait_sophie.jpg',
    ),
    _Post(
      name: 'MEWVIO Studio', handle: '@mewvio', time: 'Preview post',
      text: 'Welcome to MEWVIO: short videos, friends and communities in one place. 💜',
      image: 'assets/demo/stars.jpg',
      avatar: 'assets/demo/cat.jpg',
    ),
  ];

  void info(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void createTextPost() {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: _panel,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20, 8, 20, MediaQuery.viewInsetsOf(sheet).bottom + 24,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Create a preview post', style: TextStyle(
              color: _white, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            const Text('This post will be visible only on this device during this app session.',
              style: TextStyle(color: _muted, fontSize: 12)),
            const SizedBox(height: 14),
            TextField(
              key: const Key('social-compose-input'),
              controller: controller,
              maxLines: 4,
              maxLength: 350,
              style: const TextStyle(color: _white),
              decoration: InputDecoration(
                hintText: 'Share something positive…',
                hintStyle: const TextStyle(color: _muted),
                filled: true, fillColor: _bg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: FilledButton.icon(
              key: const Key('social-publish'),
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) return;
                setState(() => localPosts.insert(0, value));
                Navigator.pop(sheet);
                info('Preview post added locally. It is not uploaded.');
              },
              icon: const Icon(Icons.send_rounded),
              label: const Text('Add preview post'),
              style: FilledButton.styleFrom(
                backgroundColor: _pink, foregroundColor: Colors.white),
            )),
          ]),
        ),
      ),
    ).whenComplete(controller.dispose);
  }

  void openComments(int index) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: _panel,
      builder: (sheet) => StatefulBuilder(
        builder: (sheet, update) => SafeArea(child: Padding(
          padding: EdgeInsets.fromLTRB(
            18, 10, 18, MediaQuery.viewInsetsOf(sheet).bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Comments • local preview', style: TextStyle(
              color: _white, fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 10),
            if ((comments[index] ?? []).isEmpty)
              const Padding(padding: EdgeInsets.all(16), child: Text(
                'No comments yet. These notes are not sent online.',
                style: TextStyle(color: _muted))),
            for (final message in comments[index] ?? <String>[])
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: const Text('You • preview',
                  style: TextStyle(color: _white, fontSize: 12)),
                subtitle: Text(message, style: const TextStyle(color: _muted))),
            TextField(
              key: const Key('social-comment-input'),
              controller: controller, maxLength: 250,
              style: const TextStyle(color: _white),
              decoration: const InputDecoration(
                hintText: 'Write a preview comment',
                hintStyle: TextStyle(color: _muted)),
            ),
            Align(alignment: Alignment.centerRight, child: TextButton.icon(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                setState(() => comments.putIfAbsent(index, () => []).add(text));
                controller.clear();
                update(() {});
              },
              icon: const Icon(Icons.send_rounded),
              label: const Text('Comment'),
            )),
          ]),
        )),
      ),
    ).whenComplete(controller.dispose);
  }

  void openSafetyMenu(int index) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: _panel,
      builder: (sheet) => SafeArea(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility_off_outlined, color: _white),
            title: const Text('Hide this sample post', style: TextStyle(color: _white)),
            onTap: () {
              setState(() => hidden.add(index));
              Navigator.pop(sheet);
            },
          ),
          ListTile(
            leading: const Icon(Icons.flag_outlined, color: _pink),
            title: const Text('Report (preview)', style: TextStyle(color: _white)),
            subtitle: const Text('Reports are not submitted in this beta',
              style: TextStyle(color: _muted)),
            onTap: () {
              Navigator.pop(sheet);
              info('Reporting is not connected yet. Do not use this beta for public posts.');
            },
          ),
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = query.trim().toLowerCase();
    final matching = <int>[
      for (var i = 0; i < samples.length; i++)
        if (!hidden.contains(i) &&
            (q.isEmpty ||
             samples[i].name.toLowerCase().contains(q) ||
             samples[i].text.toLowerCase().contains(q))) i,
    ];
    return ColoredBox(
      color: _bg,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 690),
            child: ListView(
              key: const Key('social-home-feed'),
              padding: const EdgeInsets.fromLTRB(15, 8, 15, 28),
              children: [
                _header(),
                const SizedBox(height: 15),
                _search(),
                const SizedBox(height: 18),
                _hero(),
                const SizedBox(height: 22),
                _section('Explore MEWVIO', 'Four experiences. One community.'),
                const SizedBox(height: 11),
                _shortcuts(),
                const SizedBox(height: 21),
                _stories(),
                const SizedBox(height: 19),
                _composer(),
                const SizedBox(height: 14),
                _switcher(),
                const SizedBox(height: 13),
                if (groupsOnly) ...[
                  _groupCard('Creators Cambodia', 'Video ideas • tutorials • collaborations', Icons.movie_creation_outlined, _purple),
                  _groupCard('Friends & Music', 'Voice parties • games • kind conversations', Icons.graphic_eq_rounded, _pink),
                  _groupCard('MEWVIO Community', 'Updates • tips • feature previews', Icons.pets_rounded, _cyan),
                ] else ...[
                  for (final local in localPosts)
                    _localPost(local),
                  for (final i in matching)
                    _postCard(i, samples[i]),
                  if (matching.isEmpty && localPosts.isEmpty)
                    const Padding(padding: EdgeInsets.all(26), child:
                      Center(child: Text('No matching demo posts.',
                        style: TextStyle(color: _muted)))),
                ],
                const SizedBox(height: 16),
                const Center(child: Text(
                  'MEWVIO SOCIAL • DEMO CONTENT • NOT A PUBLIC NETWORK',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 10))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() => Row(children: [
    Container(width: 41, height: 41,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cyan, width: 1.2)),
      child: SvgPicture.asset('assets/images/mewvio-cat.svg', fit: BoxFit.cover)),
    const SizedBox(width: 10),
    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('MEWVIO', style: TextStyle(color: _white,
        fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: .9)),
      Text('Meet  •  Watch  •  Vibe',
        style: TextStyle(color: _muted, fontSize: 11)),
    ])),
    _roundIcon(Icons.chat_bubble_outline_rounded, widget.onChat),
    const SizedBox(width: 7),
    _roundIcon(Icons.notifications_none_rounded,
      () => info('Notification service is not connected in this beta.')),
  ]);

  Widget _roundIcon(IconData icon, VoidCallback action) => Material(
    color: _panel, shape: const CircleBorder(),
    child: InkWell(customBorder: const CircleBorder(), onTap: action,
      child: SizedBox(width: 42, height: 42,
        child: Icon(icon, color: _white, size: 23))));

  Widget _search() => TextField(
    key: const Key('social-search'), onChanged: (v) => setState(() => query = v),
    style: const TextStyle(color: _white),
    decoration: InputDecoration(
      hintText: 'Search sample posts and creators',
      hintStyle: const TextStyle(color: _muted, fontSize: 13),
      prefixIcon: const Icon(Icons.search_rounded, color: _cyan),
      filled: true, fillColor: _panel, isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
  );

  Widget _hero() => Container(
    height: 164,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      gradient: const LinearGradient(
        colors: [Color(0xFF132B59), Color(0xFF5834B2), Color(0xFFB03796)])),
    child: Stack(children: [
      Positioned(top: -56, right: -30, child: Container(width: 200, height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle, color: Colors.white.withValues(alpha: .09)))),
      Positioned(top: 20, right: 13, child: const Icon(Icons.auto_awesome_rounded,
        color: _cyan, size: 73)),
      Padding(padding: const EdgeInsets.fromLTRB(20, 17, 95, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(color: const Color(0x4427BDE7),
              borderRadius: BorderRadius.circular(20)),
            child: const Text('🇰🇭  Cambodia • Beta',
              style: TextStyle(color: _white, fontSize: 10, fontWeight: FontWeight.bold))),
          const SizedBox(height: 9),
          const Text('Your world. Your vibe.',
            maxLines: 2, style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
          const Spacer(),
          GestureDetector(
            onTap: widget.onVideos,
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.play_circle_fill_rounded, color: _cyan, size: 23),
              SizedBox(width: 6),
              Text('Explore videos', style: TextStyle(
                color: _white, fontWeight: FontWeight.bold, fontSize: 12)),
              Icon(Icons.arrow_forward_ios_rounded, color: _white, size: 12),
            ]),
          ),
        ]),
      ),
    ]),
  );

  Widget _section(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(
        color: _white, fontWeight: FontWeight.w900, fontSize: 19)),
      Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12)),
    ],
  );

  Widget _shortcuts() => Row(children: [
    _shortcut('Videos', Icons.smart_display_rounded, _pink, widget.onVideos,
      const Key('social-videos')),
    _shortcut('Match', Icons.favorite_rounded, _purple, widget.onMatch,
      const Key('social-match')),
    _shortcut('Voice', Icons.mic_rounded, _cyan, widget.onVoice,
      const Key('social-voice')),
    _shortcut('LIVE', Icons.live_tv_rounded, const Color(0xFFFFAF5D),
      () => info('Live streaming is a future feature. This is a UI preview.'),
      const Key('social-live')),
  ]);

  Widget _shortcut(String title, IconData icon, Color color,
      VoidCallback onTap, Key key) => Expanded(child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3),
    child: Material(color: _panel, borderRadius: BorderRadius.circular(17),
      child: InkWell(key: key, onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 1),
          child: Column(children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(
              color: _white, fontWeight: FontWeight.bold, fontSize: 11)),
          ]),
        ),
      ),
    ),
  ));

  Widget _stories() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Discover people', style: TextStyle(
      color: _white, fontWeight: FontWeight.bold, fontSize: 16)),
    const SizedBox(height: 12),
    SizedBox(height: 92, child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _story('You', 'assets/demo/cat.jpg', widget.onCreate),
        _story('Luna • demo', 'assets/demo/portrait_luna.jpg', () => info('Demo profile only')),
        _story('Sophie • demo', 'assets/demo/portrait_sophie.jpg', () => info('Demo profile only')),
        _story('Mina • demo', 'assets/demo/portrait_mina.jpg', () => info('Demo profile only')),
      ],
    )),
  ]);

  Widget _story(String name, String image, VoidCallback action) => InkWell(
    onTap: action, child: SizedBox(width: 86, child: Column(children: [
      Container(width: 62, height: 62,
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [_cyan, _purple, _pink])),
        child: ClipOval(child: Image.asset(image, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.pets, color: _white)))),
      const SizedBox(height: 6),
      Text(name, textAlign: TextAlign.center,
        maxLines: 1, overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: _muted, fontSize: 10)),
    ])),
  );

  Widget _composer() => Material(
    color: _panel, borderRadius: BorderRadius.circular(18),
    child: Padding(padding: const EdgeInsets.all(13),
      child: Column(children: [
        Row(children: [
          const CircleAvatar(backgroundColor: _purple,
            child: Icon(Icons.pets_rounded, color: _white)),
          const SizedBox(width: 10),
          Expanded(child: InkWell(
            key: const Key('social-compose'),
            onTap: createTextPost,
            borderRadius: BorderRadius.circular(13),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
              decoration: BoxDecoration(
                color: _bg, borderRadius: BorderRadius.circular(13)),
              child: const Text('What are you thinking?',
                style: TextStyle(color: _muted, fontSize: 12))))),
        ]),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          TextButton.icon(onPressed: createTextPost,
            icon: const Icon(Icons.edit_note_rounded, color: _cyan),
            label: const Text('Post', style: TextStyle(color: _white))),
          TextButton.icon(onPressed: widget.onVideos,
            icon: const Icon(Icons.movie_creation_outlined, color: _pink),
            label: const Text('Videos', style: TextStyle(color: _white))),
          TextButton.icon(onPressed: widget.onVoice,
            icon: const Icon(Icons.mic_none_rounded, color: _purple),
            label: const Text('Rooms', style: TextStyle(color: _white))),
        ]),
      ]),
    ),
  );

  Widget _switcher() => Row(children: [
    Expanded(child: _filterChip('Feed', !groupsOnly,
      () => setState(() => groupsOnly = false))),
    const SizedBox(width: 10),
    Expanded(child: _filterChip('Communities', groupsOnly,
      () => setState(() => groupsOnly = true))),
  ]);

  Widget _filterChip(String label, bool active, VoidCallback tap) => InkWell(
    onTap: tap, borderRadius: BorderRadius.circular(13),
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF3F326C) : _panel,
        border: Border.all(color: active ? _purple : _line),
        borderRadius: BorderRadius.circular(13)),
      child: Text(label, style: TextStyle(
        color: active ? _white : _muted, fontWeight: FontWeight.w800)),
    ),
  );

  Widget _localPost(String text) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: _panel, borderRadius: BorderRadius.circular(19)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        CircleAvatar(backgroundColor: _purple,
          child: Icon(Icons.person_rounded, color: _white)),
        SizedBox(width: 10),
        Expanded(child: Text('You • local preview', style: TextStyle(
          color: _white, fontWeight: FontWeight.w800))),
        Icon(Icons.lock_outline, color: _muted, size: 18),
      ]),
      const SizedBox(height: 12),
      Text(text, style: const TextStyle(color: _white, fontSize: 14)),
      const SizedBox(height: 9),
      const Text('Only visible in this app session',
        style: TextStyle(color: _muted, fontSize: 10)),
    ]),
  );

  Widget _postCard(int index, _Post post) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      color: _panel, borderRadius: BorderRadius.circular(19),
      border: Border.all(color: _line)),
    clipBehavior: Clip.antiAlias,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(13, 14, 7, 11),
        child: Row(children: [
          CircleAvatar(radius: 21, backgroundImage: AssetImage(post.avatar)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(post.name, style: const TextStyle(color: _white,
              fontWeight: FontWeight.w800, fontSize: 14)),
            Text(post.handle + '  •  ' + post.time,
              style: const TextStyle(color: _muted, fontSize: 11)),
          ])),
          TextButton(
            onPressed: () => setState(() =>
              followed.contains(post.handle)
                ? followed.remove(post.handle) : followed.add(post.handle)),
            child: Text(followed.contains(post.handle) ? 'Following' : 'Follow',
              style: const TextStyle(color: _cyan, fontSize: 12))),
          IconButton(onPressed: () => openSafetyMenu(index),
            icon: const Icon(Icons.more_horiz, color: _muted)),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 12),
        child: Text(post.text, style: const TextStyle(
          color: _white, fontSize: 13, height: 1.4)),
      ),
      Image.asset(post.image,
        fit: BoxFit.cover, height: 204, width: double.infinity,
        errorBuilder: (_, __, ___) => const SizedBox(height: 140,
          child: Center(child: Icon(Icons.image_outlined,
            color: _muted, size: 38)))),
      Padding(padding: const EdgeInsets.fromLTRB(10, 8, 10, 7),
        child: Row(children: [
          _postAction(
            liked.contains(index) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            liked.contains(index) ? _pink : _muted,
            liked.contains(index) ? 'Liked' : 'Like',
            () => setState(() =>
              liked.contains(index) ? liked.remove(index) : liked.add(index))),
          _postAction(Icons.mode_comment_outlined, _muted,
            'Comment', () => openComments(index)),
          _postAction(Icons.share_outlined, _muted,
            'Share', () => info('Sharing will be connected in a future version.')),
        ]),
      ),
    ]),
  );

  Widget _postAction(IconData icon, Color color, String text,
      VoidCallback tap) => Expanded(child: InkWell(
    onTap: tap, borderRadius: BorderRadius.circular(9),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: _muted, fontSize: 11)),
      ]),
    ),
  ));

  Widget _groupCard(String name, String description, IconData icon,
      Color color) => Container(
    margin: const EdgeInsets.only(bottom: 13),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _panel, borderRadius: BorderRadius.circular(17),
      border: Border.all(color: _line)),
    child: Row(children: [
      Container(width: 58, height: 58,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .18),
          borderRadius: BorderRadius.circular(17)),
        child: Icon(icon, color: color, size: 29)),
      const SizedBox(width: 13),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(
            color: _white, fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(
            color: _muted, fontSize: 11)),
          const SizedBox(height: 4),
          const Text('Sample community • no real members',
            style: TextStyle(color: Colors.white38, fontSize: 10)),
        ]),
      ),
      TextButton(
        onPressed: () => setState(() =>
          joined.contains(name) ? joined.remove(name) : joined.add(name)),
        child: Text(joined.contains(name) ? 'Joined' : 'Join',
          style: const TextStyle(color: _cyan, fontSize: 12))),
    ]),
  );
}
