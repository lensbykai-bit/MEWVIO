import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'tiktok_video_page.dart';
import 'mewvio_shop_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const MewvioApp());

const dark = Color(0xFF211452);
const purple = Color(0xFF6941E7);
const pink = Color(0xFFF15CBF);
const blue = Color(0xFF51BEFF);
const pale = Color(0xFFF7F4FF);
const gradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF304AE1), purple, pink],
);
const mascot = 'assets/images/mewvio-cat.svg';

class MewvioApp extends StatelessWidget {
  const MewvioApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'MEWVIO',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFFAF8FF),
          colorScheme: ColorScheme.fromSeed(seedColor: purple),
          textTheme: const TextTheme(
            headlineSmall: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: dark),
            titleLarge: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: dark),
            titleMedium: TextStyle(fontWeight: FontWeight.w800, color: dark),
            bodyMedium: TextStyle(color: dark),
          ),
        ),
        home: const MainShell(),
      );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selected = 1;
  final tabs = const [
    ('Home', Icons.home_rounded),
    ('Videos', Icons.play_circle_rounded),
    ('Match', Icons.favorite_rounded),
    ('Chat', Icons.chat_bubble_rounded),
    ('Party', Icons.mic_rounded),
    ('Profile', Icons.person_rounded),
    ('Shop', Icons.shopping_bag_rounded)
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(openTab: (index) => setState(() => selected = index)),
      const TikTokVideosPage(),
      const MatchPage(),
      const ChatPage(),
      const PartyPage(),
      const ProfilePage(),
      const MewvioShopPage(),
    ];
    return Scaffold(
      backgroundColor: selected == 1 ? Colors.black : pale,
      body: selected == 1 ? pages[selected] : SafeArea(child: pages[selected]),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: selected == 1 ? Colors.black : Colors.white,
            boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 15)],
          ),
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: List.generate(tabs.length, (index) {
              final active = selected == index;
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => setState(() => selected = index),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(tabs[index].$2, size: 23, color: selected == 1 ? (active ? Colors.white : Colors.white54) : (active ? purple : Colors.blueGrey.shade300)),
                    const SizedBox(height: 4),
                    Text(tabs[index].$1, style: TextStyle(
                      fontSize: 10, fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      color: selected == 1 ? (active ? Colors.white : Colors.white54) : (active ? purple : Colors.blueGrey.shade400),
                    )),
                  ]),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

Widget demoTag() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFFFFE9F5), borderRadius: BorderRadius.circular(50)),
      child: const Text('DEMO', style: TextStyle(color: Color(0xFFB82A88), fontSize: 10, fontWeight: FontWeight.w900)),
    );

Widget sectionTitle(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: dark)),
    );

Widget cardBox(Widget child, {EdgeInsets padding = const EdgeInsets.all(16)}) => Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x0B24114D), blurRadius: 18, offset: Offset(0, 5))],
      ),
      child: child,
    );

Widget headline(String text, String subtitle) => Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(text, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: dark)),
          Text(subtitle, style: const TextStyle(color: Color(0xFF807B9B), fontSize: 12)),
        ])),
        demoTag(),
      ]),
    );

class HomePage extends StatelessWidget {
  final ValueChanged<int> openTab;
  const HomePage({super.key, required this.openTab});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        children: [
          Row(children: [
            const Expanded(child: Text('MEWVIO', style: TextStyle(
              fontSize: 32, fontWeight: FontWeight.w900, color: purple, letterSpacing: 1.3))),
            demoTag(),
            const SizedBox(width: 10),
            const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.notifications_none_rounded, color: dark)),
          ]),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 20, 10, 20),
            decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(25)),
            child: Row(children: [
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Meet new friends\nevery day ✨',
                    style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
                SizedBox(height: 8),
                Text('Meet. Watch. Vibe.', style: TextStyle(color: Color(0xFFF5E9FF), fontSize: 12)),
              ])),
              ClipRRect(borderRadius: BorderRadius.circular(22),
                child: SvgPicture.asset(mascot, width: 112, height: 112)),
            ]),
          ),
          const SizedBox(height: 25),
          sectionTitle('Explore MEWVIO'),
          Row(children: [
            _shortcut('Videos', Icons.play_circle, pink, () => openTab(1)),
            _shortcut('Friends', Icons.favorite, purple, () => openTab(2)),
            _shortcut('Chat', Icons.chat, blue, () => openTab(3)),
            _shortcut('Party', Icons.headset_mic, const Color(0xFFFFA14C), () => openTab(4)),
          ]),
          const SizedBox(height: 25),
          sectionTitle('Discover new vibes'),
          cardBox(Row(children: [
            SvgPicture.asset(mascot, width: 94, height: 94),
            const SizedBox(width: 15),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Be kind. Make friends.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              SizedBox(height: 7),
              Text('Explore videos, chat with demo friends and try a voice party.',
                  style: TextStyle(color: Color(0xFF77728C), fontSize: 12)),
            ]))
          ])),
          const SizedBox(height: 20),
          sectionTitle('Short video experience'),
          GestureDetector(
            onTap: () => openTab(1),
            child: Container(
              height: 155,
              decoration: BoxDecoration(
                gradient: gradient, borderRadius: BorderRadius.circular(22)),
              child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.smart_display_rounded, color: Colors.white, size: 45),
                SizedBox(height: 8),
                Text('Watch demo short videos',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Tap to explore', style: TextStyle(color: Colors.white70)),
              ])),
            ),
          ),
          const SizedBox(height: 18),
          cardBox(const Row(children: [
            Icon(Icons.shield_rounded, color: purple),
            SizedBox(width: 12),
            Expanded(child: Text('Safety first: use block and report tools in the future public version.',
                style: TextStyle(fontSize: 12, color: dark))),
          ])),
        ],
      );

  Widget _shortcut(String label, IconData icon, Color color, VoidCallback onTap) =>
      Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: InkWell(
          onTap: onTap, borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 17),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              Icon(icon, color: color, size: 27),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: dark, fontSize: 11, fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
      ));
}

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});
  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  static const clips = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4'
  ];
  int clip = 0;
  bool liked = false;
  bool loading = true;
  String? error;
  VideoPlayerController? player;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final previous = player;
    player = null;
    if (previous != null) {
      await previous.dispose();
    }
    final controller = VideoPlayerController.networkUrl(Uri.parse(clips[clip]));
    player = controller;
    if (mounted) setState(() { loading = true; error = null; });
    try {
      await controller.initialize();
      await controller.setLooping(true);
      if (!mounted || controller != player) return;
      await controller.play();
      if (mounted) setState(() => loading = false);
    } catch (_) {
      if (mounted && controller == player) {
        setState(() { loading = false; error = 'Could not load video. Check your internet connection.'; });
      }
    }
  }

  void change(int direction) {
    setState(() {
      clip = (clip + direction + clips.length) % clips.length;
      liked = false;
    });
    _load();
  }

  @override
  void dispose() {
    player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        headline('Short Videos', 'Swipe up or down to change the demo clip'),
        Expanded(child: GestureDetector(
          onVerticalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity < -200) change(1);
            if (velocity > 200) change(-1);
          },
          onTap: () {
            final controller = player;
            if (controller == null || !controller.value.isInitialized) return;
            controller.value.isPlaying ? controller.pause() : controller.play();
            setState(() {});
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: dark, borderRadius: BorderRadius.circular(23)),
            child: Stack(fit: StackFit.expand, children: [
              if (!loading && error == null && player != null && player!.value.isInitialized)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: player!.value.size.width, height: player!.value.size.height,
                    child: VideoPlayer(player!),
                  ),
                )
              else Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (loading) const CircularProgressIndicator(color: pink),
                if (error != null) const Icon(Icons.wifi_off_rounded, size: 54, color: Colors.white),
                const SizedBox(height: 16),
                Text(error ?? 'Loading demo video...', textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70)),
              ])),
              const Positioned(top: 17, left: 18,
                child: Text('For You  •  DEMO', style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w900, fontSize: 15))),
              Positioned(bottom: 22, left: 18, right: 80, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('@MEWVIO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text('Demo video ' + (clip + 1).toString() + '  •  Meet. Watch. Vibe.',
                    style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 7),
                  const Text('Video samples only — no user uploads yet',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
                ])),
              Positioned(bottom: 28, right: 14, child: Column(children: [
                IconButton(onPressed: () => setState(() => liked = !liked),
                  icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: pink, size: 34)),
                const Text('Like', style: TextStyle(color: Colors.white, fontSize: 11)),
                const SizedBox(height: 18),
                IconButton(onPressed: () => change(1),
                  icon: const Icon(Icons.keyboard_double_arrow_up, color: Colors.white, size: 33)),
                const Text('Next', style: TextStyle(color: Colors.white, fontSize: 11)),
              ])),
            ]),
          ),
        )),
      ]);
}

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});
  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  int active = 0;
  final friends = const [
    ('Luna', 'Music • Books • Art', '🎧'),
    ('Dara', 'Travel • Photography', '🌍'),
    ('SreyNita', 'Games • Music', '🎮'),
    ('Sokha', 'Films • Nature', '🌿'),
  ];

  @override
  Widget build(BuildContext context) => ListView(children: [
        headline('Find Friends', 'Explore demo friend profiles'),
        Padding(padding: const EdgeInsets.all(18), child: Column(children: [
          Container(
            width: double.infinity, padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(26)),
            child: Column(children: [
              SvgPicture.asset(mascot, width: 115, height: 115),
              const SizedBox(height: 14),
              const Text('Discover your people', style: TextStyle(fontSize: 25,
                  fontWeight: FontWeight.w900, color: Colors.white)),
              const Text('Friendship demo • no real matching',
                  style: TextStyle(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 18),
          cardBox(Column(children: [
            CircleAvatar(radius: 37, backgroundColor: const Color(0xFFF3E3FF),
                child: Text(friends[active].$3, style: const TextStyle(fontSize: 32))),
            const SizedBox(height: 10),
            Text(friends[active].$1, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 23)),
            Text(friends[active].$2, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 18),
            SizedBox(width: double.infinity, child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: purple, padding: const EdgeInsets.all(15)),
              onPressed: () => setState(() => active = (active + 1) % friends.length),
              icon: const Icon(Icons.shuffle_rounded),
              label: const Text('Discover next friend'),
            )),
          ])),
          const SizedBox(height: 18),
          cardBox(const Row(children: [
            Icon(Icons.verified_user_rounded, color: purple),
            SizedBox(width: 12),
            Expanded(child: Text('Real matching will require age-appropriate safety checks, block and report tools.')),
          ])),
        ])),
      ]);
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final input = TextEditingController();
  final messages = <(String, bool)>[
    ('Welcome to MEWVIO! 🐱💜', false),
    ('This is your private on-device chat demo.', false),
  ];

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  void send() {
    final value = input.text.trim();
    if (value.isEmpty) return;
    setState(() => messages.add((value, true)));
    input.clear();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        headline('Messages', 'Demo messages stay on this device'),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 17),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            return Align(
              alignment: msg.$2 ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                constraints: const BoxConstraints(maxWidth: 270),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  gradient: msg.$2 ? gradient : null,
                  color: msg.$2 ? null : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(msg.$1,
                  style: TextStyle(color: msg.$2 ? Colors.white : dark)),
              ),
            );
          },
        )),
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          Expanded(child: TextField(
            controller: input,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => send(),
            decoration: InputDecoration(
              hintText: 'Type a demo message...',
              filled: true, fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none),
            ),
          )),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: send,
            style: IconButton.styleFrom(backgroundColor: purple),
            icon: const Icon(Icons.send_rounded),
          ),
        ])),
      ]);
}

class PartyPage extends StatefulWidget {
  const PartyPage({super.key});
  @override
  State<PartyPage> createState() => _PartyPageState();
}

class _PartyPageState extends State<PartyPage> {
  int? roomIndex;
  bool muted = true;
  final rooms = const [
    ('Chill Vibes', 'Music & good conversation', '🎵'),
    ('Game Friends', 'Games and friendship', '🎮'),
    ('Travel Talk', 'Share your travel stories', '🌎'),
    ('Creative Corner', 'Art, books and ideas', '🎨'),
  ];

  @override
  Widget build(BuildContext context) => Column(children: [
        headline('Voice Party', 'Preview of social audio rooms'),
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          Container(padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(25)),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.headset_mic_rounded, color: Colors.white, size: 40),
                SizedBox(height: 10),
                Text("Let's talk, let's make friends",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 23)),
                Text('Audio rooms are UI demos until a voice server is connected.',
                    style: TextStyle(color: Colors.white70)),
              ])),
          const SizedBox(height: 16),
          ...List.generate(rooms.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => setState(() { roomIndex = i; muted = true; }),
              borderRadius: BorderRadius.circular(22),
              child: cardBox(Row(children: [
                CircleAvatar(radius: 26, backgroundColor: const Color(0xFFECE5FF),
                    child: Text(rooms[i].$3, style: const TextStyle(fontSize: 25))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(rooms[i].$1, style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(rooms[i].$2, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ])),
                const Icon(Icons.chevron_right_rounded, color: purple),
              ])),
            ),
          )),
          if (roomIndex != null) Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: dark, borderRadius: BorderRadius.circular(24)),
            child: Column(children: [
              Text(rooms[roomIndex!].$1, style: const TextStyle(color: Colors.white,
                  fontSize: 23, fontWeight: FontWeight.w900)),
              const SizedBox(height: 7),
              const Text('DEMO ROOM — no audio is transmitted',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 18),
              SvgPicture.asset(mascot, width: 90, height: 90),
              const SizedBox(height: 18),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                OutlinedButton.icon(
                  onPressed: () => setState(() => muted = !muted),
                  icon: Icon(muted ? Icons.mic_off : Icons.mic),
                  label: Text(muted ? 'Muted' : 'Mic demo'),
                ),
                OutlinedButton.icon(
                  onPressed: () => setState(() => roomIndex = null),
                  icon: const Icon(Icons.call_end),
                  label: const Text('Leave'),
                ),
              ]),
            ]),
          ),
        ])),
      ]);
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int activeTab = 0;
  File? coverImage;
  Future<void> chooseCover() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1600);
      if (picked != null && mounted) setState(() => coverImage = File(picked.path));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open gallery. Check photo permissions.')));
    }
  }
  bool privateProfile = true;
  bool notifications = true;
  String displayName = 'MEWVIO Friend';
  String username = 'mewvio_demo';
  String bio = 'Good friends, brighter days 💜';

  void editProfile() {
    final name = TextEditingController(text: displayName);
    final about = TextEditingController(text: bio);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.viewInsetsOf(ctx).bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Edit profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          TextField(controller: name, maxLength: 40, decoration: const InputDecoration(labelText: 'Display name', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: about, maxLength: 120, maxLines: 2, decoration: const InputDecoration(labelText: 'Bio', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty) return;
              setState(() { displayName = name.text.trim(); bio = about.text.trim(); });
              Navigator.pop(ctx);
            }, child: const Text('Save changes (demo)'),
          )),
          const Text('Changes are only kept while the app stays open.', style: TextStyle(color: Colors.grey, fontSize: 11)),
        ]),
      ),
    ).whenComplete(() { name.dispose(); about.dispose(); });
  }

  void shareProfile() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Profile sharing will be available after accounts are connected.')));
  }

  void openSettings() {
    showModalBottomSheet<void>(
      context: context, showDragHandle: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, update) => SafeArea(
        child: Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Settings & privacy', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            SwitchListTile(
              secondary: const Icon(Icons.lock_outline_rounded, color: purple),
              title: const Text('Private profile'),
              subtitle: const Text('Demo only — not synced to a server'),
              value: privateProfile,
              onChanged: (v) { setState(() => privateProfile = v); update(() {}); },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined, color: purple),
              title: const Text('Notifications'),
              subtitle: const Text('Demo only'),
              value: notifications,
              onChanged: (v) { setState(() => notifications = v); update(() {}); },
            ),
            ListTile(
              leading: const Icon(Icons.shield_outlined, color: purple),
              title: const Text('Safety center'),
              subtitle: const Text('Block and report features are not live yet'),
              onTap: () => showDialog<void>(
                context: ctx, builder: (dialog) => AlertDialog(
                  title: const Text('MEWVIO Safety'),
                  content: const Text('This is an offline beta. Please avoid sharing personal information. Real user reporting and blocking must be implemented before public launch.'),
                  actions: [TextButton(onPressed: () => Navigator.pop(dialog), child: const Text('Close'))],
                )),
            ),
          ]))),
      ),
    );
  }

  Widget stat(String number, String caption) => Expanded(
    child: Column(children: [
      Text(number, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: dark)),
      const SizedBox(height: 3),
      Text(caption, style: const TextStyle(color: Colors.black54, fontSize: 12)),
    ]),
  );

  Widget emptyPosts() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
    child: Column(children: [
      Icon(activeTab == 0 ? Icons.video_library_outlined : activeTab == 1 ? Icons.lock_outline_rounded : Icons.favorite_border_rounded,
        size: 51, color: const Color(0xFFA79ABA)),
      const SizedBox(height: 12),
      Text(activeTab == 0 ? 'No posts yet' : activeTab == 1 ? 'Private posts' : 'Liked videos',
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: dark)),
      const SizedBox(height: 7),
      Text(activeTab == 0 ? 'Your video uploads will appear here.'
        : activeTab == 1 ? 'Private videos will appear here when uploads are enabled.'
        : 'Videos you like will appear here when accounts are connected.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey, fontSize: 13)),
    ]),
  );

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(0, 8, 0, 28),
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          const SizedBox(width: 46),
          Expanded(child: Text('@$username', textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: dark))),
          IconButton(tooltip: 'Settings and privacy', onPressed: openSettings,
            icon: const Icon(Icons.menu_rounded, color: dark, size: 29)),
        ]),
      ),
      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: SizedBox(
            height: 175,
            child: Stack(fit: StackFit.expand, children: [
              Container(
                decoration: const BoxDecoration(gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF4534A6), Color(0xFF9B56EB), Color(0xFFF48BCB)])),
              ),
              if (coverImage != null)
                Image.file(coverImage!, fit: BoxFit.cover, errorBuilder: (_, __, ___) =>
                  const Center(child: Icon(Icons.image_not_supported, color: Colors.white))),
              if (coverImage == null)
                const Center(child: Text('🐱  MEWVIO  💜',
                  style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900))),
              Positioned(bottom: 11, right: 12, child: FilledButton.icon(
                onPressed: chooseCover,
                style: FilledButton.styleFrom(backgroundColor: const Color(0xCC231443),
                  foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 11)),
                icon: const Icon(Icons.photo_camera_outlined, size: 17),
                label: Text(coverImage == null ? 'Add cover' : 'Change cover'),
              )),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 0),
      Transform.translate(
        offset: const Offset(0, -21),
        child: Center(child: Container(
          width: 104, height: 104,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white,
            border: Border.all(color: purple, width: 3)),
          child: SvgPicture.asset(mascot),
        )),
      ),
      const SizedBox(height: 0),
      //Text(displayName, textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: dark)),
      const SizedBox(height: 16),
      Row(children: [stat('0', 'Following'), stat('0', 'Followers'), stat('0', 'Likes')]),
      const SizedBox(height: 17),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(children: [
          Expanded(child: FilledButton(
            onPressed: editProfile,
            style: FilledButton.styleFrom(backgroundColor: purple, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Edit profile', style: TextStyle(fontWeight: FontWeight.w800)),
          )),
          const SizedBox(width: 9),
          Expanded(child: OutlinedButton(
            onPressed: shareProfile,
            style: OutlinedButton.styleFrom(foregroundColor: dark,
              padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Share profile', style: TextStyle(fontWeight: FontWeight.w800)),
          )),
        ]),
      ),
      const SizedBox(height: 15),
      Text(bio, textAlign: TextAlign.center, style: const TextStyle(color: dark, fontSize: 14)),
      const SizedBox(height: 5),
      const Text('Meet · Watch · Vibe', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
      const SizedBox(height: 22),
      const Divider(height: 1, color: Color(0xFFE2DDEA)),
      Row(children: [
        for (final tab in <(IconData, String)>[
          (Icons.grid_on_rounded, 'Posts'),
          (Icons.lock_outline_rounded, 'Private'),
          (Icons.favorite_border_rounded, 'Likes'),
        ])
          Expanded(child: InkWell(
            onTap: () => setState(() => activeTab = [Icons.grid_on_rounded, Icons.lock_outline_rounded, Icons.favorite_border_rounded].indexOf(tab.$1)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(
                color: activeTab == [Icons.grid_on_rounded, Icons.lock_outline_rounded, Icons.favorite_border_rounded].indexOf(tab.$1)
                  ? purple : Colors.transparent, width: 3))),
              child: Icon(tab.$1, color: activeTab == [Icons.grid_on_rounded, Icons.lock_outline_rounded, Icons.favorite_border_rounded].indexOf(tab.$1)
                ? purple : Colors.grey),
            ),
          )),
      ]),
      emptyPosts(),
      const Center(child: Text('MEWVIO v0.1.8 • Beta profile', style: TextStyle(color: Colors.grey, fontSize: 11))),
    ],
  );
}
