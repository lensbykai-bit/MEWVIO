import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mewvio_social_service.dart';

const bg = Color(0xFF090F22);
const panel = Color(0xFF141C36);
const accent = Color(0xFFF25CBB);

class MewvioCommunityPage extends StatefulWidget {
  const MewvioCommunityPage({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  State<MewvioCommunityPage> createState() => _MewvioCommunityPageState();
}

class _MewvioCommunityPageState extends State<MewvioCommunityPage> {
  late final MewvioSocialService service = MewvioSocialService(Supabase.instance.client);
  late int tab = widget.initialTab;
  List<Map<String, dynamic>> posts = [], members = [], requests = [];
  final chatText = TextEditingController();
  bool loading = false;
  bool saving = false;
  String? error;
  String? handle;
  int? openRequest;
  String? chattingWith;
  List<Map<String, dynamic>> messages = [];
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    load();
    refreshTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (mounted && tab == 2 && openRequest != null) loadMessages(quiet: true);
    });
  }
  @override
  void dispose() { refreshTimer?.cancel(); chatText.dispose(); super.dispose(); }

  void notify(String text) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(text)));

  Future<void> action(Future<void> Function() fn) async {
    if (saving) return;
    setState(() { saving = true; error = null; });
    try {
      await fn();
      if (mounted) await load();
    } catch (e) {
      if (mounted) notify('Could not complete request: $e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> load() async {
    if (Supabase.instance.client.auth.currentUser == null) return;
    if (loading) return;
    setState(() => loading = true);
    try {
      final member = await service.myMember();
      if (!mounted) return;
      if (member == null) { setState(() => handle = null); return; }
      final all = await Future.wait([
        service.posts(), service.members(), service.requests(),
      ]);
      if (mounted) setState(() {
        handle = member['handle'] as String?;
        posts = all[0]; members = all[1]; requests = all[2];
        error = null;
      });
    } catch (e) {
      if (mounted) setState(() => error = 'Connection problem: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> join() async {
    final username = TextEditingController();
    final display = TextEditingController(text: 'MEWVIO Friend');
    await showDialog<void>(context: context, builder: (dialog) => AlertDialog(
      title: const Text('Join MEWVIO Social beta'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Your public handle will be discoverable. Do not use your full name, school, address or phone number. Chat is available only after both people accept a friend request.'),
        TextField(controller: username, decoration: const InputDecoration(labelText: 'Public handle (3–24 characters)')),
        TextField(controller: display, decoration: const InputDecoration(labelText: 'Display name')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialog), child: const Text('Cancel')),
        FilledButton(onPressed: () async {
          try {
            await service.join(username.text, display.text);
            if (dialog.mounted) Navigator.pop(dialog);
            if (mounted) await load();
          } catch (e) { if (dialog.mounted) ScaffoldMessenger.of(dialog).showSnackBar(SnackBar(content: Text('$e'))); }
        }, child: const Text('Join')),
      ],
    ));
    username.dispose(); display.dispose();
  }

  Future<void> compose() async {
    final caption = TextEditingController();
    XFile? picked;
    await showModalBottomSheet<void>(context: context, isScrollControlled: true,
      builder: (sheet) => StatefulBuilder(builder: (sheet, change) => SafeArea(
        child: Padding(padding: EdgeInsets.fromLTRB(18,18,18,
          MediaQuery.viewInsetsOf(sheet).bottom+20),
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Create post', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
            TextField(key: const Key('live-post-caption'), controller: caption,
              maxLines: 3, maxLength: 500,
              decoration: const InputDecoration(hintText: 'Share something kind…')),
            ListTile(leading: const Icon(Icons.image_outlined), title: Text(picked?.name ?? 'Choose a photo'),
              onTap: () async {
                try { final file=await service.choosePhoto(); if(file!=null && sheet.mounted) change(()=>picked=file); }
                catch(e){ if(sheet.mounted) ScaffoldMessenger.of(sheet).showSnackBar(SnackBar(content:Text('$e'))); }
              }),
            FilledButton.icon(key: const Key('live-post-send'),
              onPressed: saving ? null : () async {
                if(caption.text.trim().isEmpty && picked==null)return;
                await action(() => service.publish(caption.text,picked));
                if(sheet.mounted) Navigator.pop(sheet);
              }, icon: const Icon(Icons.send), label: const Text('Publish post')),
            const Text('Visible to signed-in MEWVIO beta members. Avoid sharing private information.', textAlign: TextAlign.center),
          ])),
        ),
      )));
    caption.dispose();
  }

  Future<void> loadMessages({bool quiet = false}) async {
    if (openRequest == null) return;
    try {
      final list = await service.messages(openRequest!);
      if (mounted) setState(() => messages = list);
    } catch(e) { if(!quiet && mounted) notify('$e'); }
  }

  Future<void> openChat(int id, String peer) async {
    setState(() { tab=2; openRequest=id; chattingWith=peer; messages=[]; });
    await loadMessages();
  }

  Widget heading(String title, {VoidCallback? onTap}) => ListTile(
    title: Text(title, style: const TextStyle(fontSize:20,fontWeight:FontWeight.w800,color:Colors.white)),
    trailing: IconButton(onPressed: onTap ?? load, icon: const Icon(Icons.refresh,color:Colors.white)),
  );

  Widget postsTab() => ListView(children: [
    heading('MEWVIO Feed'),
    Padding(padding: const EdgeInsets.symmetric(horizontal:16), child: FilledButton.icon(
      key: const Key('live-create-post'), onPressed: compose,
      icon: const Icon(Icons.add_a_photo_outlined), label: const Text('Post text or photo'))),
    if(posts.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('No community posts yet. Create the first one.', style: TextStyle(color:Colors.white70))),
    for(final post in posts) Card(color:panel,margin:const EdgeInsets.all(10),child:Padding(padding:const EdgeInsets.all(13),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('Member • ${(post['author_id'] as String).substring(0,8)}',style:const TextStyle(color:Colors.white70)),
      const SizedBox(height:8),
      Text(post['body'] as String? ?? '',style:const TextStyle(color:Colors.white,fontSize:15)),
      if(post['signed_url'] is String) Padding(padding:const EdgeInsets.only(top:9),child:ClipRRect(
        borderRadius:BorderRadius.circular(12),
        child:Image.network(post['signed_url'] as String,height:250,width:double.infinity,fit:BoxFit.cover,
          errorBuilder: (_,__,___)=>const Text('Photo unavailable',style:TextStyle(color:Colors.white70))))),
      Row(mainAxisAlignment:MainAxisAlignment.end,children:[
        TextButton(onPressed:()=>action(()=>service.report(post:post['id'] as int,reason:'inappropriate')),child:const Text('Report')),
        if(post['author_id']==service.me) IconButton(onPressed:()=>action(()=>service.deletePost(post['id'] as int)),
          icon:const Icon(Icons.delete_outline,color:Colors.white70)),
      ]),
    ]))),
  ]);

  Widget peopleTab() {
    final myId=service.me;
    final blockedOrConnected={for(final r in requests) (r['sender_id']==myId ? r['receiver_id']:r['sender_id']) as String};
    return ListView(children:[
      heading('Find friends'),
      const Padding(padding:EdgeInsets.fromLTRB(16,0,16,14),child:Text('Send a friend request. Messaging opens only after the other person accepts.',style:TextStyle(color:Colors.white70))),
      for(final m in members) if(m['user_id']!=myId)
        Card(color:panel,child:ListTile(
          title:Text('@${m['handle']}',style:const TextStyle(color:Colors.white)),
          subtitle:Text(m['display_name'] as String,style:const TextStyle(color:Colors.white70)),
          trailing:blockedOrConnected.contains(m['user_id'])
            ? const Icon(Icons.check,color:Colors.white54)
            : IconButton(tooltip:'Friend request',icon:const Icon(Icons.person_add,color:Colors.pinkAccent),
              onPressed:()=>action(()=>service.requestFriend(m['user_id'] as String))),
        )),
      heading('Requests'),
      for(final r in requests) if(r['status']=='pending') Card(color:panel,child:ListTile(
        title:Text(r['receiver_id']==myId?'Friend request received':'Request sent',style:const TextStyle(color:Colors.white)),
        subtitle:Text((r['receiver_id']==myId?r['sender_id']:r['receiver_id']) as String,style:const TextStyle(color:Colors.white70)),
        trailing:r['receiver_id']==myId?Wrap(children:[
          IconButton(tooltip:'Accept',onPressed:()=>action(()=>service.respond(r['id'] as int,accept:true)),
            icon:const Icon(Icons.check_circle,color:Colors.greenAccent)),
          IconButton(tooltip:'Decline',onPressed:()=>action(()=>service.respond(r['id'] as int,accept:false)),
            icon:const Icon(Icons.cancel_outlined,color:Colors.white54)),
        ]):TextButton(onPressed:()=>action(()=>service.cancelRequest(r['id'] as int)),child:const Text('Cancel')),
      )),
    ]);
  }

  Widget chatTab() {
    final myId=service.me;
    if(openRequest!=null) return Column(children:[
      Row(children:[IconButton(onPressed:()=>setState(()=>openRequest=null),icon:const Icon(Icons.arrow_back,color:Colors.white)),
        Expanded(child:Text('Private chat',style:const TextStyle(color:Colors.white,fontSize:19))),
        PopupMenuButton<String>(onSelected:(v)=>action(() async {
            if(v=='block'){await service.block(chattingWith!);setState(()=>openRequest=null);}
            else{await service.report(member:chattingWith,reason:'harassment');}
          }),itemBuilder:(_)=>[
            const PopupMenuItem(value:'report',child:Text('Report user')),
            const PopupMenuItem(value:'block',child:Text('Block user')),
          ],icon:const Icon(Icons.more_vert,color:Colors.white)),
      ]),
      Expanded(child:ListView(children:[
        for(final m in messages) Align(alignment:m['sender_id']==myId?Alignment.centerRight:Alignment.centerLeft,
          child:Container(margin:const EdgeInsets.all(8),padding:const EdgeInsets.all(12),
            decoration:BoxDecoration(color:m['sender_id']==myId?const Color(0xFF6542B4):panel,
              borderRadius:BorderRadius.circular(14)),child:Text(m['body'] as String,style:const TextStyle(color:Colors.white)))),
      ])),
      SafeArea(child:Row(children:[
        Expanded(child:TextField(key:const Key('live-chat-message'),controller:chatText,maxLength:700,maxLines:1,
          style:const TextStyle(color:Colors.white),decoration:const InputDecoration(hintText:'Message',hintStyle:TextStyle(color:Colors.white54)))),
        IconButton(onPressed:()=>action(() async {
          if(chattingWith==null||openRequest==null)return;
          await service.sendMessage(openRequest!,chattingWith!,chatText.text);
          chatText.clear();await loadMessages();
        }),icon:const Icon(Icons.send,color:accent)),
      ])),
    ]);
    return ListView(children:[
      heading('Private chats'),
      const Padding(padding:EdgeInsets.all(12),child:Text('Chat is available only with accepted friends. Pull refresh to check new connections.',style:TextStyle(color:Colors.white70))),
      for(final r in requests) if(r['status']=='accepted') ListTile(
        leading:const CircleAvatar(child:Icon(Icons.person)),
        title:const Text('Accepted friend',style:TextStyle(color:Colors.white)),
        subtitle:Text((r['sender_id']==myId?r['receiver_id']:r['sender_id']) as String,style:const TextStyle(color:Colors.white70)),
        trailing:const Icon(Icons.chat,color:accent),
        onTap:()=>openChat(r['id'] as int,(r['sender_id']==myId?r['receiver_id']:r['sender_id']) as String)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final logged=Supabase.instance.client.auth.currentUser!=null;
    return Scaffold(backgroundColor:bg,appBar:AppBar(backgroundColor:bg,foregroundColor:Colors.white,title:const Text('MEWVIO Social • Beta')),
      body:!logged?const Center(child:Text('Sign in from Profile to use real posts and chat.',style:TextStyle(color:Colors.white70)))
        :handle==null?Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
          const Text('Join the opt-in community',style:TextStyle(color:Colors.white,fontSize:19)),
          FilledButton(onPressed:join,child:const Text('Set up social handle')),
          if(error!=null)Text(error!,style:const TextStyle(color:Colors.redAccent)),
        ])):Column(children:[
          if(error!=null)Text(error!,style:const TextStyle(color:Colors.redAccent)),
          Expanded(child:tab==0?postsTab():tab==1?peopleTab():chatTab()),
          NavigationBar(selectedIndex:tab,onDestinationSelected:(i){setState(()=>tab=i);load();},
            destinations:const [
              NavigationDestination(icon:Icon(Icons.dynamic_feed),label:'Feed'),
              NavigationDestination(icon:Icon(Icons.people),label:'Friends'),
              NavigationDestination(icon:Icon(Icons.chat_bubble),label:'Chat'),
            ]),
        ]));
  }
}
