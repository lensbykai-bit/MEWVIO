import 'package:flutter/material.dart';
import 'account/account_bootstrap.dart';
import 'account/account_page.dart';
import 'account/account_repository.dart';
import 'tiktok_video_page.dart';
import 'mewvio_shop_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AccountBootstrap());
}

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
  const MewvioApp({super.key, required this.accounts});
  final AccountRepository accounts;

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
        home: MainShell(accounts: accounts),
      );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.accounts});
  final AccountRepository accounts;
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selected = 0;
  int? extraPage;

  void openCreate() => showModalBottomSheet<void>(
    context: context, showDragHandle: true,
    builder: (ctx) => SafeArea(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.add_circle_outline_rounded, size: 52, color: purple),
        const SizedBox(height: 12),
        const Text('Create on MEWVIO', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Video uploading is not enabled yet. This beta only plays bundled demo videos.',
          textAlign: TextAlign.center),
        const SizedBox(height: 14),
        FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
      ]),
    )),
  );

  void chooseTab(int index) {
    if (index == 2) { openCreate(); return; }
    setState(() { selected = index; extraPage = null; });
  }

  @override
  Widget build(BuildContext context) {
    final darkScreen = selected == 0 || selected == 4;
    final pages = <Widget>[
      const TikTokVideosPage(),
      const MatchPage(),
      const SizedBox.shrink(),
      const ChatPage(),
      AccountPage(repository: widget.accounts),
    ];
    final body = extraPage == 1 ? const PartyPage()
        : extraPage == 2 ? const MewvioShopPage() : pages[selected];
    return Scaffold(
      backgroundColor: darkScreen && extraPage == null ? Colors.black : pale,
      body: extraPage == null && selected == 0 ? body : SafeArea(child: body),
      bottomNavigationBar: SafeArea(top: false, child: Container(
        color: darkScreen && extraPage == null ? Colors.black : const Color(0xFF151515),
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [
          _navItem(0, 'Home', Icons.home_outlined, Icons.home_rounded),
          _navItem(1, 'Friends', Icons.people_outline_rounded, Icons.people_rounded),
          Expanded(child: Center(child: InkWell(
            onTap: openCreate, borderRadius: BorderRadius.circular(9),
            child: Container(width: 51, height: 34,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(colors: [Color(0xFF28CEE2), Colors.white, Color(0xFFF3539B)])),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: const DecoratedBox(decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(5))),
                child: Icon(Icons.add_rounded, color: Colors.black, size: 28)),
            ),
          ))),
          _navItem(3, 'Inbox', Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded),
          _navItem(4, 'Profile', Icons.person_outline_rounded, Icons.person_rounded),
        ]),
      )),
    );
  }

  Widget _navItem(int index, String label, IconData normal, IconData activeIcon) {
    final active = selected == index && extraPage == null;
    return Expanded(child: InkWell(
      onTap: () => chooseTab(index),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(active ? activeIcon : normal, color: active ? Colors.white : Colors.white60, size: 27),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(color: active ? Colors.white : Colors.white60,
          fontSize: 11, fontWeight: active ? FontWeight.w800 : FontWeight.w500)),
      ]),
    ));
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
