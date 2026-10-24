import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

const editPink=Color(0xFFF25CBB),editCyan=Color(0xFF4DDBF5),editBg=Color(0xFF0B091A);
enum MewvioFilter { original, mono, warm, cool, vivid }
extension MewvioFilterLabel on MewvioFilter {
  String get label => switch(this) {
    MewvioFilter.original=>'Original',MewvioFilter.mono=>'Mono',
    MewvioFilter.warm=>'Warm',MewvioFilter.cool=>'Cool',MewvioFilter.vivid=>'Vivid'};
  List<double> get values => switch(this) {
    MewvioFilter.original => [1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0],
    MewvioFilter.mono => [.2126,.7152,.0722,0,0,.2126,.7152,.0722,0,0,.2126,.7152,.0722,0,0,0,0,0,1,0],
    MewvioFilter.warm => [1.09,.03,0,0,7,.01,1.04,0,0,1,0,0,.91,0,-3,0,0,0,1,0],
    MewvioFilter.cool => [.94,0,.02,0,-2,0,1.01,0,0,0,.01,.02,1.12,0,8,0,0,0,1,0],
    MewvioFilter.vivid => [1.22,-.08,-.06,0,0,-.06,1.23,-.04,0,0,-.06,-.04,1.24,0,0,0,0,0,1,0],
  };
}
class EditLayer {
  EditLayer(this.text,{this.color=Colors.white,this.sticker=false,this.x=.18,this.y=.42});
  final String text;
  Color color;
  final bool sticker;
  double x,y;
}

/// Filtered, annotated and stickered photos are really composited in the exported PNG.
class MewvioPhotoEditPage extends StatefulWidget {
  const MewvioPhotoEditPage({super.key,this.photo});
  final File? photo;
  @override State<MewvioPhotoEditPage> createState()=>_MewvioPhotoEditPageState();
}
class _MewvioPhotoEditPageState extends State<MewvioPhotoEditPage> {
  final canvasKey=GlobalKey();
  final layers=<EditLayer>[];
  MewvioFilter filter=MewvioFilter.original;
  Color textColor=Colors.white;
  int selected=-1;
  bool saving=false;
  void toast(String s){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s)));}

  Future<void> addText() async {
    final ctl=TextEditingController();
    final value=await showDialog<String>(context:context,builder:(ctx)=>AlertDialog(
      title:const Text('Add text'),content:TextField(
        key:const Key('photo-edit-text-input'),controller:ctl,
        maxLength:100,maxLines:3,decoration:const InputDecoration(hintText:'Write on your photo')),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Cancel')),
        FilledButton(onPressed:()=>Navigator.pop(ctx,ctl.text.trim()),child:const Text('Add'))]));
    ctl.dispose();
    if(value!=null && value.isNotEmpty && mounted)setState((){
      layers.add(EditLayer(value,color:textColor));selected=layers.length-1;});
  }

  void showStickers()=>showModalBottomSheet<void>(context:context,backgroundColor:const Color(0xFF221A35),
    builder:(sheet)=>SafeArea(child:Padding(padding:const EdgeInsets.all(18),child:Column(
      mainAxisSize:MainAxisSize.min,children:[
        const Text('Stickers',style:TextStyle(color:Colors.white,fontSize:18)),
        const SizedBox(height:15),
        Wrap(spacing:10,runSpacing:14,children:[
          for(final value in ['💜','✨','🔥','😂','😍','🎉','🇰🇭','🎵','🐱','🌸','🌈','❤️'])
            InkWell(onTap:(){
              setState((){layers.add(EditLayer(value,sticker:true));selected=layers.length-1;});
              Navigator.pop(sheet);
            },child:SizedBox(width:48,height:48,child:Center(child:Text(value,style:const TextStyle(fontSize:31))))),
        ]),
      ]))));

  Future<void> save() async {
    if(saving)return;
    setState((){saving=true;selected=-1;});
    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary=canvasKey.currentContext?.findRenderObject();
      if(boundary is! RenderRepaintBoundary)throw StateError('Canvas unavailable');
      final image=await boundary.toImage(pixelRatio:2.0);
      final bytes=await image.toByteData(format:ui.ImageByteFormat.png);
      image.dispose();
      if(bytes==null)throw StateError('Image rendering failed');
      final dir=await getTemporaryDirectory();
      final path='${dir.path}/mewvio-edit-${DateTime.now().millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(bytes.buffer.asUint8List());
      await Gal.putImage(path);
      toast('Edited photo saved to Gallery');
    }catch(e){toast('Save error: $e');}
    finally{if(mounted)setState(()=>saving=false);}
  }

  void chooseFilters()=>showModalBottomSheet<void>(context:context,backgroundColor:const Color(0xFF221A35),
    builder:(sheet)=>SafeArea(child:Wrap(children:[
      for(final f in MewvioFilter.values)ListTile(
        title:Text(f.label,style:const TextStyle(color:Colors.white)),
        trailing:filter==f?const Icon(Icons.check,color:editCyan):null,
        onTap:(){setState(()=>filter=f);Navigator.pop(sheet);}),
    ])));

  void chooseColor()=>showModalBottomSheet<void>(context:context,backgroundColor:const Color(0xFF221A35),
    builder:(sheet)=>SafeArea(child:Wrap(alignment:WrapAlignment.center,children:[
      for(final c in [Colors.white,editPink,editCyan,Colors.yellow,Colors.black])
        IconButton(icon:Icon(Icons.circle,color:c,size:32),onPressed:(){
          setState((){textColor=c;if(selected>=0&&!layers[selected].sticker)layers[selected].color=c;});
          Navigator.pop(sheet);
        }),
    ])));

  Widget tool(Key key,IconData icon,String title,VoidCallback action)=>InkWell(
    key:key,onTap:saving?null:action,child:Padding(padding:const EdgeInsets.symmetric(horizontal:10),
      child:Column(children:[Container(
        width:45,height:45,decoration:BoxDecoration(color:const Color(0xFF241D37),borderRadius:BorderRadius.circular(15)),
        child:Icon(icon,color:Colors.white)),const SizedBox(height:5),
        Text(title,style:const TextStyle(color:Colors.white70,fontSize:11))])));

  @override Widget build(BuildContext context)=>Scaffold(
    backgroundColor:editBg,
    appBar:AppBar(backgroundColor:editBg,foregroundColor:Colors.white,
      title:const Text('MEWVIO • Edit'),actions:[
        TextButton.icon(key:const Key('photo-edit-save'),onPressed:saving?null:save,
          icon:const Icon(Icons.save_alt,color:editCyan),
          label:const Text('Save',style:TextStyle(color:editCyan))),
      ]),
    body:SafeArea(child:Column(children:[
      Expanded(child:Center(child:Padding(padding:const EdgeInsets.all(10),
        child:AspectRatio(aspectRatio:9/16,child:RepaintBoundary(key:canvasKey,
          child:LayoutBuilder(builder:(ctx,dimensions)=>Stack(
            fit:StackFit.expand,clipBehavior:Clip.hardEdge,children:[
              ColorFiltered(colorFilter:ColorFilter.matrix(filter.values),child:widget.photo==null
                ?const DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(
                  colors:[Color(0xFF252466),Color(0xFF9D3A99),Color(0xFF17192F)])))
                :Image.file(widget.photo!,fit:BoxFit.cover)),
              for(int i=0;i<layers.length;i++)
                Positioned(left:layers[i].x*dimensions.maxWidth,top:layers[i].y*dimensions.maxHeight,
                  child:GestureDetector(
                    key:Key('photo-edit-layer-$i'),
                    onTap:()=>setState(()=>selected=i),
                    onPanUpdate:(d)=>setState((){
                      layers[i].x=(layers[i].x+d.delta.dx/dimensions.maxWidth).clamp(0.0,.84).toDouble();
                      layers[i].y=(layers[i].y+d.delta.dy/dimensions.maxHeight).clamp(0.0,.92).toDouble();
                    }),
                    child:Container(
                      constraints:BoxConstraints(maxWidth:dimensions.maxWidth*.83),
                      decoration:BoxDecoration(
                        border:selected==i&&!saving?Border.all(color:editCyan,width:1.3):null,
                        borderRadius:BorderRadius.circular(6)),
                      padding:const EdgeInsets.all(4),child:Text(layers[i].text,
                        textAlign:TextAlign.center,style:TextStyle(
                          color:layers[i].color,fontSize:layers[i].sticker?40:24,
                          fontWeight:FontWeight.w900,
                          shadows:const [Shadow(color:Colors.black,blurRadius:6)])),
                    ),
                  )),
            ]))),
        )))),
      if(selected>=0)Row(children:[
        const Padding(padding:EdgeInsets.only(left:14),child:Text('Drag to move',style:TextStyle(color:Colors.white70))),
        const Spacer(),
        TextButton.icon(onPressed:()=>setState((){layers.removeAt(selected);selected=-1;}),
          icon:const Icon(Icons.delete_outline,color:editPink),
          label:const Text('Remove',style:TextStyle(color:editPink))),
      ]),
      SizedBox(height:80,child:ListView(scrollDirection:Axis.horizontal,children:[
        tool(const Key('photo-edit-text'),Icons.text_fields,'Text',addText),
        tool(const Key('photo-edit-sticker'),Icons.emoji_emotions_outlined,'Stickers',showStickers),
        tool(const Key('photo-edit-filters'),Icons.tune,'Filters',chooseFilters),
        tool(const Key('photo-edit-colors'),Icons.palette_outlined,'Colors',chooseColor),
        tool(const Key('photo-edit-undo'),Icons.undo,'Undo',(){
          if(layers.isEmpty)return;
          setState((){layers.removeLast();selected=-1;});
        }),
      ])),
      Text('Filter: ${filter.label} · Drag text or stickers',
        style:const TextStyle(color:Colors.white60,fontSize:12)),
      if(saving)const LinearProgressIndicator(color:editCyan),
      const SizedBox(height:14),
    ])),
  );
}
