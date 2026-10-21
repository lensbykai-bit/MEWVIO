import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

const _purple = Color(0xFF7743ED);
const _pink = Color(0xFFF05BBD);

class TikTokVideosPage extends StatefulWidget {
  const TikTokVideosPage({super.key});
  @override
  State<TikTokVideosPage> createState() => _TikTokVideosPageState();
}

class _TikTokVideosPageState extends State<TikTokVideosPage> {
  final PageController pager = PageController();
  final liked = <int>{};
  final saved = <int>{};
  bool following = false;
  int selected = 0;
  static const videos = [
    ('assets/videos/mewvio_1.mp4', '@mewvio', 'Meet. Watch. Vibe. 💜', '#mewvio #foryou', 'MEWVIO Original', '12.3K'),
    ('assets/videos/mewvio_2.mp4', '@mewvio.fun', 'Say hello to your next adventure ✨', '#friends #discover', 'Feel Good Vibes', '8.4K'),
    ('assets/videos/mewvio_3.mp4', '@mewvio.club', 'Swipe up and share a smile 🐱', '#shorts #fun', 'Cosmic Pop', '21.5K')
  ];

  @override
  void dispose() { pager.dispose(); super.dispose(); }

  void toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message), duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black,
    child: PageView.builder(
      controller: pager,
      scrollDirection: Axis.vertical,
      itemCount: videos.length,
      onPageChanged: (i) => setState(() => selected = i),
      itemBuilder: (context, index) {
        final v = videos[index];
        return Stack(fit: StackFit.expand, children: [
          _OfflineVideo(key: ValueKey(v.$1), path: v.$1, active: selected == index, index: index),
          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0x77000000), Colors.transparent, Color(0xC9000000)],
            stops: [0, .35, 1],
          ))),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 14, left: 12, right: 12,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('v0.1.4', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              Row(children: [
                _tab('Following', following, () => setState(() { following = true; toast('Following feed is coming after accounts are connected.'); })),
                const SizedBox(width: 20),
                _tab('For You', !following, () => setState(() => following = false)),
              ]),
              IconButton(onPressed: () => toast('Search will be available in Stage 2.'), icon: const Icon(Icons.search, color: Colors.white)),
            ]),
          ),
          Positioned(
            bottom: 24, left: 16, right: 100,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(v.$2, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(v.$3, style: const TextStyle(color: Colors.white, fontSize: 14)),
              const SizedBox(height: 4),
              Text(v.$4, style: const TextStyle(color: Color(0xFFE1D5FF), fontSize: 13)),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.music_note_rounded, size: 17, color: Colors.white),
                const SizedBox(width: 6),
                Flexible(child: Text(v.$5, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12)))
              ]),
              const SizedBox(height: 8),
              const Text('MEWVIO v0.1.4 • Offline demo', style: TextStyle(color: Colors.white70, fontSize: 10)),
            ]),
          ),
          Positioned(right: 13, bottom: 55, child: Column(children: [
            CircleAvatar(radius: 24, backgroundColor: _purple, child: const Icon(Icons.pets, color: Colors.white)),
            const SizedBox(height: 20),
            _action(liked.contains(index) ? Icons.favorite : Icons.favorite_border, liked.contains(index) ? _pink : Colors.white,
              liked.contains(index) ? 'Liked' : v.$6,
              () => setState(() => liked.contains(index) ? liked.remove(index) : liked.add(index))),
            const SizedBox(height: 18),
            _action(Icons.chat_bubble_outline_rounded, Colors.white, 'Comment', () => _comments(context)),
            const SizedBox(height: 18),
            _action(Icons.share_rounded, Colors.white, 'Share', () => toast('Sharing is coming soon.')),
            const SizedBox(height: 18),
            _action(saved.contains(index) ? Icons.bookmark : Icons.bookmark_border, Colors.white,
              saved.contains(index) ? 'Saved' : 'Save',
              () => setState(() => saved.contains(index) ? saved.remove(index) : saved.add(index))),
          ])),
          Positioned(bottom: 4, left: 0, right: 0, child: Container(height: 3, color: Colors.white24, alignment: Alignment.centerLeft,
            child: FractionallySizedBox(widthFactor: (index + 1) / videos.length, child: Container(color: _pink)))),
        ]);
      },
    ),
  );

  Widget _tab(String name, bool active, VoidCallback tap) => InkWell(
    onTap: tap,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(name, style: TextStyle(color: active ? Colors.white : Colors.white60, fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 4),
      Container(width: 29, height: 3, decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(3))),
    ]),
  );

  Widget _action(IconData icon, Color color, String label, VoidCallback tap) => InkWell(
    onTap: tap,
    child: Column(children: [
      Icon(icon, color: color, size: 34, shadows: const [Shadow(color: Colors.black45, blurRadius: 7)]),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    ]),
  );

  void _comments(BuildContext context) => showModalBottomSheet<void>(
    context: context, showDragHandle: true, isScrollControlled: true,
    builder: (ctx) => SafeArea(child: Padding(padding: const EdgeInsets.all(25),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Comments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        const Text('Comments will be available once the MEWVIO backend is connected.'),
        const SizedBox(height: 20),
        FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
      ]))),
  );
}

class _OfflineVideo extends StatefulWidget {
  final String path;
  final bool active;
  final int index;
  const _OfflineVideo({super.key, required this.path, required this.active, required this.index});
  @override
  State<_OfflineVideo> createState() => _OfflineVideoState();
}

class _OfflineVideoState extends State<_OfflineVideo> {
  VideoPlayerController? player;
  bool initialized = false;
  bool failed = false;

  @override
  void initState() { super.initState(); _start(); }

  Future<void> _start() async {
    final controller = VideoPlayerController.asset(widget.path);
    player = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      if (!mounted || controller != player) return;
      setState(() => initialized = true);
      if (widget.active) await controller.play();
    } catch (_) {
      if (mounted) setState(() => failed = true);
    }
  }

  @override
  void didUpdateWidget(covariant _OfflineVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active && initialized && player != null) {
      widget.active ? player!.play() : player!.pause();
    }
  }

  @override
  void dispose() { player?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    const backgrounds = [
      [Color(0xFF201257), Color(0xFF743BDE), Color(0xFFFA6BC2)],
      [Color(0xFF153B7F), Color(0xFF0B9AD2), Color(0xFF7741C7)],
      [Color(0xFF401469), Color(0xFFA02399), Color(0xFFF064AD)],
    ];
    final colors = backgrounds[widget.index % backgrounds.length];
    return GestureDetector(
      onTap: () {
        if (!initialized || player == null) return;
        player!.value.isPlaying ? player!.pause() : player!.play();
        setState(() {});
      },
      child: Stack(fit: StackFit.expand, children: [
        DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors))),
        if (initialized && player != null)
          FittedBox(fit: BoxFit.cover, child: SizedBox(
            width: player!.value.size.width, height: player!.value.size.height,
            child: VideoPlayer(player!))),
        if (!initialized)
          Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(failed ? Icons.play_circle_outline : Icons.pets_rounded, color: Colors.white70, size: 64),
            const SizedBox(height: 12),
            Text(failed ? 'Preview available • Video could not play' : 'MEWVIO',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 23)),
            if (!failed) const Padding(padding: EdgeInsets.only(top: 16), child: CircularProgressIndicator(color: Colors.white)),
          ])),
      ]),
    );
  }
}
