import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'mewvio_wallet_page.dart';

const _background = Color(0xFF0B091A);
const _surface = Color(0xFF211831);
const _pink = Color(0xFFF050BB);
const _violet = Color(0xFF8052F4);
const _cyan = Color(0xFF53D7ED);

/// The public demo profile has no account, user, financial or social backend.
/// Sample images and counts are previews, never claimed as real user activity.
class MewvioDemoProfilePage extends StatefulWidget {
  const MewvioDemoProfilePage({super.key, required this.onSignIn});
  final VoidCallback onSignIn;
  @override
  State<MewvioDemoProfilePage> createState() => _MewvioDemoProfilePageState();
}

class _MewvioDemoProfilePageState extends State<MewvioDemoProfilePage> {
  String displayName = 'MEWVIO Friend';
  String bio = 'Good people. Good vibes. More friends on MEWVIO 💜';
  int tab = 0;
  static const posts = <String>[
    'assets/demo/portrait_sophie.jpg',
    'assets/demo/stars.jpg',
    'assets/demo/cat.jpg',
    'assets/demo/concert.jpg',
    'assets/demo/portrait_luna.jpg',
    'assets/demo/hero_sunset.jpg',
  ];

  void openWallet() => Navigator.push(context,
    MaterialPageRoute<void>(builder: (_) => const MewvioWalletPage()));

  void editDemo() {
    final name = TextEditingController(text: displayName);
    final about = TextEditingController(text: bio);
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true, backgroundColor: _surface,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20,
          MediaQuery.viewInsetsOf(ctx).bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Edit demo profile', style: TextStyle(
            color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          TextField(controller: name, maxLength: 60,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Display name')),
          TextField(controller: about, maxLength: 140,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Bio')),
          const SizedBox(height: 10),
          FilledButton(onPressed: () {
            setState(() {
              if (name.text.trim().isNotEmpty) displayName = name.text.trim();
              bio = about.text.trim();
            });
            Navigator.pop(ctx);
          }, child: const Text('Save preview')),
          const SizedBox(height: 8),
          const Text('Only saved in this demo session.',
            style: TextStyle(color: Colors.white54, fontSize: 11)),
        ]),
      ),
    ).whenComplete(() { name.dispose(); about.dispose(); });
  }

  void openMenu() => showModalBottomSheet<void>(
    context: context, backgroundColor: const Color(0xFF171326),
    showDragHandle: true,
    builder: (sheet) => SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 5, 12, 18),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('MEWVIO Space', style: TextStyle(
          color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
        const SizedBox(height: 7),
        _menuItem(Icons.account_balance_wallet_rounded,
          'MEWVIO Wallet', () { Navigator.pop(sheet); openWallet(); }),
        _menuItem(Icons.diamond_rounded, 'Diamonds shop (demo)',
          () { Navigator.pop(sheet); openWallet(); }),
        _menuItem(Icons.movie_filter_outlined, 'Creator Studio',
          () { Navigator.pop(sheet); _notice('Creator Studio is coming soon.'); }),
        _menuItem(Icons.shield_outlined, 'Settings & Safety',
          () { Navigator.pop(sheet); _notice('Account safety controls require a signed-in account.'); }),
        _menuItem(Icons.login_rounded, 'Sign in or create account',
          () { Navigator.pop(sheet); widget.onSignIn(); }),
      ]),
    )),
  );

  Widget _menuItem(IconData icon, String label, VoidCallback tap) =>
    ListTile(onTap: tap, leading: Icon(icon, color: _pink),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38));

  void _notice(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  Widget _stat(String value, String label) => Expanded(child: Column(children: [
    Text(value, style: const TextStyle(color: Colors.white,
      fontSize: 19, fontWeight: FontWeight.w900)),
    Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
  ]));

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: _background,
    child: ListView(padding: EdgeInsets.zero, children: [
      Stack(clipBehavior: Clip.none, children: [
        SizedBox(height: 210, child: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(27)),
          child: Stack(fit: StackFit.expand, children: [
            const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
              colors: [Color(0xFF371F7E), Color(0xFFB953A8), Color(0xFFED8B9A)],
              begin: Alignment.topLeft, end: Alignment.bottomRight))),
            Image.asset(
              'assets/demo/hero_sunset.jpg',
              fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0x92000000), Colors.transparent, Color(0xA9000019)]))),
          ]),
        )),
        Positioned(top: 12, left: 16, right: 8, child: Row(children: [
          const Text('MEWVIO', style: TextStyle(color: Colors.white,
            fontSize: 21, fontWeight: FontWeight.w900)),
          const Spacer(),
          IconButton(tooltip: 'MEWVIO Wallet', onPressed: openWallet,
            icon: const Icon(Icons.diamond_outlined, color: _cyan)),
          IconButton(tooltip: 'MEWVIO menu', onPressed: openMenu,
            icon: const Icon(Icons.menu_rounded, color: Colors.white)),
        ])),
        Positioned(bottom: -34, left: 18, child: Container(
          width: 93, height: 93, padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(color: const Color(0xFF15122D),
            shape: BoxShape.circle, border: Border.all(color: _pink, width: 3),
            boxShadow: const [BoxShadow(color: Color(0xAAE843AF), blurRadius: 15)]),
          child: SvgPicture.asset('assets/images/mewvio-cat.svg'),
        )),
      ]),
      Padding(padding: const EdgeInsets.fromLTRB(16, 46, 16, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(displayName, style: const TextStyle(color: Colors.white,
                fontSize: 23, fontWeight: FontWeight.w900)),
              const Text('@mewvio_demo', style: TextStyle(color: Colors.white60)),
            ])),
            OutlinedButton(onPressed: editDemo,
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white30)),
              child: const Text('Edit profile')),
          ]),
          const SizedBox(height: 17),
          Row(children: [
            _stat('0', 'Posts'), _stat('0', 'Followers'), _stat('0', 'Following'),
          ]),
          const SizedBox(height: 17),
          Text(bio, style: const TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(height: 9),
          const Wrap(spacing: 7, runSpacing: 7, children: [
            Chip(label: Text('🎵 Music')),
            Chip(label: Text('🎮 Games')),
            Chip(label: Text('💜 Friends')),
          ]),
          const SizedBox(height: 12),
          InkWell(onTap: openWallet, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [
                Color(0xFF572073), Color(0xFF272367), Color(0xFF283A86)]),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF7651C8))),
            child: const Row(children: [
              Icon(Icons.account_balance_wallet_rounded, color: Colors.amber, size: 28),
              SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('MEWVIO Wallet', style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold)),
                Text('0 Coins · Demo', style: TextStyle(color: Colors.white70,
                  fontSize: 11)),
              ])),
              Text('Explore', style: TextStyle(color: _cyan,
                fontWeight: FontWeight.bold)),
              Icon(Icons.chevron_right_rounded, color: _cyan),
            ]),
          )),
          const SizedBox(height: 14),
          Row(children: [
            for (var i = 0; i < 3; i++)
              Expanded(child: InkWell(onTap: () => setState(() => tab = i),
                child: Padding(padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Column(children: [
                    Text(['Posts','Likes','Saved'][i],
                      style: TextStyle(color: tab == i ? _pink : Colors.white54,
                        fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(height: 3, width: 35, color: tab == i ? _pink : Colors.transparent),
                  ])))),
          ]),
        ])),
      if (tab == 0)
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length, padding: const EdgeInsets.fromLTRB(4, 4, 4, 9),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 4, crossAxisSpacing: 4,
            childAspectRatio: .8),
          itemBuilder: (ctx, index) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(colors: [
                _violet, _pink.withValues(alpha: .7), _background])),
            clipBehavior: Clip.antiAlias,
            child: Stack(fit: StackFit.expand, children: [
              Image.asset(posts[index], fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                  const Center(child: Icon(Icons.pets_rounded,
                    color: Colors.white54, size: 38))),
              const Positioned(left: 6, bottom: 6,
                child: Text('✦ Preview', style: TextStyle(
                  color: Colors.white, fontSize: 10,
                  shadows: [Shadow(color: Colors.black, blurRadius: 5)]))),
            ]),
          ),
        )
      else
        Padding(padding: const EdgeInsets.all(40),
          child: Column(children: [
            Icon(tab == 1 ? Icons.favorite_outline_rounded :
              Icons.bookmark_outline_rounded, size: 42, color: Colors.white54),
            const SizedBox(height: 8),
            Text(tab == 1 ? 'No liked videos in demo' : 'No saved videos in demo',
              style: const TextStyle(color: Colors.white70)),
          ])),
      const Padding(padding: EdgeInsets.fromLTRB(18, 10, 18, 24),
        child: Text('SAMPLE PROFILE · Photos are illustrative, not user uploads',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38, fontSize: 10))),
    ]),
  );
}
