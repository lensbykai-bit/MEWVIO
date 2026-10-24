import 'package:flutter/material.dart';
import 'account/account_bootstrap.dart';
import 'account/account_page.dart';
import 'account/account_repository.dart';
import 'tiktok_video_page.dart';
import 'social_home_page.dart';
import 'mewvio_creator_page.dart';
import 'social/mewvio_community_page.dart';
import 'mewvio_demo_profile_page.dart';
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

  void openCreate() {
    Navigator.push(context, MaterialPageRoute<void>(
      builder: (_) => const MewvioCreatorPage()));
  }

  void openCommunity({int tab = 0}) {
    Navigator.push(context, MaterialPageRoute<void>(
      builder: (_) => MewvioCommunityPage(initialTab: tab)));
  }

  void chooseTab(int index) {
    if (index == 2) { openCreate(); return; }
    setState(() { selected = index; extraPage = null; });
  }

  @override
  Widget build(BuildContext context) {
    final darkScreen = selected == 0 || selected == 1 || selected == 4;
    final pages = <Widget>[
      SocialHomePage(
        onVideos: () => chooseTab(1),
        onMatch: () => setState(() => extraPage = 3),
        onVoice: () => setState(() => extraPage = 1),
        onChat: () => openCommunity(tab: 2),
        onCreate: () => openCommunity(),
      ),
      const TikTokVideosPage(),
      const SizedBox.shrink(),
      const MewvioCommunityPage(initialTab: 2),
      widget.accounts.currentSession == null
          ? MewvioDemoProfilePage(onSignIn: () => Navigator.push(context,
              MaterialPageRoute<void>(builder: (_) => Scaffold(
                backgroundColor: pale,
                appBar: AppBar(title: const Text('MEWVIO Account')),
                body: AccountPage(repository: widget.accounts),
              ))))
          : AccountPage(repository: widget.accounts),
    ];
    final body = extraPage == 1 ? const PartyPage()
        : extraPage == 3 ? const MatchPage() : pages[selected];
    return Scaffold(
      backgroundColor: darkScreen && extraPage == null ? Colors.black : pale,
      body: extraPage == null && selected == 0 ? body : SafeArea(child: body),
      bottomNavigationBar: SafeArea(top: false, child: SizedBox(height: 62, child: Container(
        decoration: const BoxDecoration(color: Color(0xFF10101D), border: Border(top: BorderSide(color: Color(0xFF302447)))),
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [
          _navItem(0, 'Home', Icons.home_outlined, Icons.home_rounded),
          _navItem(1, 'Videos', Icons.play_circle_outline_rounded, Icons.play_circle_fill_rounded),
          Expanded(child: Center(child: InkWell(
            key: const Key('nav-Create'),
            onTap: openCreate, borderRadius: BorderRadius.circular(9),
            child: Container(width: 46, height: 43,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(colors: [Color(0xFF4ACFE8), Color(0xFF9A5FEA), Color(0xFFF353AB)])),
              padding: const EdgeInsets.all(3),
              child: const DecoratedBox(decoration: BoxDecoration(
                color: Color(0xFF38275D), shape: BoxShape.circle),
                child: Icon(Icons.add_rounded, color: Colors.white, size: 29)),
            ),
          ))),
          _navItem(3, 'Chat', Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded),
          _navItem(4, 'Profile', Icons.person_outline_rounded, Icons.person_rounded),
        ]),
      ))),
    );
  }

  Widget _navItem(int index, String label, IconData normal, IconData activeIcon) {
    final active = selected == index && extraPage == null;
    return Expanded(child: InkWell(
      key: Key('nav-$label'),
      onTap: () => chooseTab(index),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(active ? activeIcon : normal, color: active ? pink : Colors.white60, size: 27),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(color: active ? pink : Colors.white60,
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
  int selectedInterest = 0;
  static const interests = ['Music', 'Games', 'Travel', 'Anime', 'Art', 'Pets'];
  static const people = [
    ('Luna','🎧','Music & art'),('Dara','📷','Travel & photos'),
    ('Mina','🎨','Anime & drawing'),('Kai','🎮','Games & friends'),
  ];
  void notice(String text) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text),duration: const Duration(seconds: 2)));
  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFF090A18),
    child: ListView(padding: const EdgeInsets.fromLTRB(16,18,16,25), children: [
      Row(children: [
        const Expanded(child: Text('MEWVIO Connect',style:TextStyle(color:Colors.white,fontSize:25,fontWeight:FontWeight.w900))),
        IconButton(onPressed:()=>notice('Search is a demo preview.'),icon:const Icon(Icons.search,color:Colors.white)),
      ]),
      const SizedBox(height:8),
      Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(
        gradient:gradient,borderRadius:BorderRadius.circular(25)),
        child:Row(children:[
          const Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text('Meet new friends',style:TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.bold)),
            SizedBox(height:6),
            Text('Same vibes. More fun. 💜',style:TextStyle(color:Colors.white70)),
            SizedBox(height:10),
            Text('DEMO • sample profiles only',style:TextStyle(color:Colors.white70,fontSize:11))
          ])),
          SvgPicture.asset(mascot,width:95,height:95),
        ])),
      const SizedBox(height:18),
      const Text('Connect your way',style:TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.bold)),
      const SizedBox(height:10),
      Row(children:[
        _feature(Icons.videocam_rounded,'Video Chat',()=>notice('Video calls are not connected yet.')),
        _feature(Icons.forum_rounded,'Text Chat',()=>notice('Open Chats from the bottom bar.')),
        _feature(Icons.mic_rounded,'Voice Party',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const Scaffold(body:SafeArea(child:PartyPage()))))),
      ]),
      const SizedBox(height:24),
      const Text('People to discover',style:TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.bold)),
      const SizedBox(height:12),
      SizedBox(height:205,child:ListView(scrollDirection:Axis.horizontal,children:[
        for (var i = 0; i < people.length; i++) InkWell(
          onTap: () => notice('These are illustrative demo profiles; no live matching.'),
          child: Container(width:146,margin:const EdgeInsets.only(right:11),
            clipBehavior:Clip.antiAlias,
            decoration:BoxDecoration(
              gradient:const LinearGradient(colors:[Color(0xFF594292),Color(0xFFEA55AC)]),
              borderRadius:BorderRadius.circular(19)),
            child:Stack(fit:StackFit.expand,children:[
              Image.asset([
                'assets/demo/portrait_sophie.jpg',
                'assets/demo/portrait_kai.jpg',
                'assets/demo/portrait_luna.jpg',
                'assets/demo/portrait_kai.jpg',
              ][i],fit:BoxFit.cover,errorBuilder:(_,__,___)=>Center(
                child:Text(people[i].$2,style:const TextStyle(fontSize:48)))),
              const DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(
                begin:Alignment.topCenter,end:Alignment.bottomCenter,
                colors:[Colors.transparent,Color(0xE5000015)]))),
              Positioned(left:11,right:5,bottom:11,child:Column(
                crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Text(people[i].$1,style:const TextStyle(
                    color:Colors.white,fontSize:18,fontWeight:FontWeight.w900)),
                  const SizedBox(height:4),
                  Text(people[i].$3,style:const TextStyle(
                    color:Colors.white70,fontSize:11)),
                  const SizedBox(height:4),
                  const Text('Preview • Not online',style:TextStyle(
                    color:Color(0xFFC1E9FF),fontSize:10)),
                ])),
            ]),
          )),
      ])),
      const SizedBox(height:23),
      const Text('Find friends by interests',style:TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.bold)),
      const SizedBox(height:12),
      Wrap(spacing:8,runSpacing:8,children:[
        for(var i=0;i<interests.length;i++) ChoiceChip(
          label:Text(interests[i]),selected:selectedInterest==i,
          selectedColor:const Color(0xFFE9B1FF),onSelected:(_)=>setState(()=>selectedInterest=i)),
      ]),
      const SizedBox(height:16),
      const Text('All profiles are fictional samples. Public matching requires moderation, age-appropriate protections, and reporting tools.',style:TextStyle(color:Colors.white54,fontSize:12)),
    ]),
  );
  Widget _feature(IconData icon,String name,VoidCallback callback)=>Expanded(child:Padding(
    padding:const EdgeInsets.only(right:7),
    child:InkWell(onTap:callback,child:Container(height:102,padding:const EdgeInsets.all(8),
      decoration:BoxDecoration(color:const Color(0xFF241B41),borderRadius:BorderRadius.circular(18)),
      child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
        Icon(icon,color:const Color(0xFFF47ACB),size:31),const SizedBox(height:10),
        Text(name,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:12,fontWeight:FontWeight.bold)),
      ])))));
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
  bool muted=true;
  static const rooms=[
    ('Chill & Talk','💬','Meet new friends'),
    ('Music Vibes','🎵','Talk about your favorite songs'),
    ('Game Together','🎮','Find teammates'),
    ('Late Night Talk','🌙','Relaxing conversations'),
  ];
  @override
  Widget build(BuildContext context)=>Container(
    color:const Color(0xFF0A0918),
    child:ListView(padding:const EdgeInsets.fromLTRB(17,18,17,28),children:[
      const Text('MEWVIO Voice Party',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:25)),
      const SizedBox(height:8),
      Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(
        gradient:gradient,borderRadius:BorderRadius.circular(23)),
        child:Row(children:[
          const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text('Find your vibe',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:22)),
            SizedBox(height:7),
            Text('Chat • Sing • Play • Connect',style:TextStyle(color:Colors.white70)),
            SizedBox(height:9),
            Text('DEMO ROOMS',style:TextStyle(color:Colors.white70,fontSize:11)),
          ])),
          SvgPicture.asset(mascot,width:105,height:105),
        ])),
      const SizedBox(height:20),
      const Text('Explore rooms',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:19)),
      const SizedBox(height:12),
      GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),
        itemCount:rooms.length,
        gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:2,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:.98),
        itemBuilder:(context,i)=>InkWell(
          onTap:()=>setState((){roomIndex=i;muted=true;}),
          child:Container(clipBehavior:Clip.antiAlias,decoration:BoxDecoration(
            borderRadius:BorderRadius.circular(18),
            border:Border.all(color:roomIndex==i?pink:Colors.white24,width:1.5),
            gradient:const LinearGradient(colors:[Color(0xFF24134C),Color(0xFF592979)])),
            child:Stack(fit:StackFit.expand,children:[
              Image.asset([
                'assets/demo/chill.jpg',
                'assets/demo/music.jpg',
                'assets/demo/gaming.jpg',
                'assets/demo/stars.jpg',
              ][i],fit:BoxFit.cover,errorBuilder:(_,__,___)=>
                Center(child:Text(rooms[i].$2,style:const TextStyle(fontSize:42)))),
              const DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(
                begin:Alignment.topCenter,end:Alignment.bottomCenter,
                colors:[Color(0x220B0926),Color(0xE60B0926)]))),
              Positioned(left:10,right:6,bottom:13,child:Column(
                crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Text(rooms[i].$2,style:const TextStyle(fontSize:24)),
                  const SizedBox(height:5),
                  Text(rooms[i].$1,style:const TextStyle(
                    color:Colors.white,fontWeight:FontWeight.bold,fontSize:15)),
                  const SizedBox(height:3),
                  Text(rooms[i].$3,style:const TextStyle(
                    color:Colors.white70,fontSize:11)),
                  const SizedBox(height:4),
                  const Text('DEMO ROOM',style:TextStyle(
                    color:Color(0xFFC79EFF),fontSize:9,fontWeight:FontWeight.w800)),
                ])),
            ]))),
      ),
      const SizedBox(height:20),
      if(roomIndex!=null) Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(
        color:const Color(0xFF292046),borderRadius:BorderRadius.circular(18)),
        child:Column(children:[
          Text(rooms[roomIndex!].$1,style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.bold)),
          const SizedBox(height:8),
          const Text('Preview only • No microphone is transmitting audio',style:TextStyle(color:Colors.white70)),
          const SizedBox(height:12),
          Row(mainAxisAlignment:MainAxisAlignment.center,children:[
            TextButton.icon(onPressed:()=>setState(()=>muted=!muted),icon:Icon(muted?Icons.mic_off:Icons.mic),label:Text(muted?'Muted':'Microphone preview')),
            TextButton(onPressed:()=>setState(()=>roomIndex=null),child:const Text('Leave'))
          ]),
        ])),
      const SizedBox(height:18),
      const Text('Live voice chat is not enabled in this demo.',style:TextStyle(color:Colors.white54,fontSize:12),textAlign:TextAlign.center),
    ]),
  );
}
