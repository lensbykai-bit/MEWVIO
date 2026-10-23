import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_trimmer/video_trimmer.dart';

const pink = Color(0xFFF25CBB);
const cyan = Color(0xFF4DDBF5);
const dark = Color(0xFF0B091A);

enum CreatorMode { s15, s60, m10, photo, text }

class MewvioCreatorPage extends StatefulWidget {
  const MewvioCreatorPage({super.key});
  @override
  State<MewvioCreatorPage> createState() => _MewvioCreatorPageState();
}

class _MewvioCreatorPageState extends State<MewvioCreatorPage>
    with WidgetsBindingObserver {
  List<CameraDescription> cameras = [];
  CameraController? camera;
  CreatorMode mode = CreatorMode.s15;
  bool loading = true;
  bool busy = false;
  bool recording = false;
  bool stopping = false;
  String? error;
  FlashMode flash = FlashMode.off;
  int timerDelay = 0;
  int elapsed = 0;
  Timer? ticker;

  bool get isVideo => mode.index <= 2;
  int get maxSeconds => switch (mode) {
    CreatorMode.s15 => 15,
    CreatorMode.s60 => 60,
    CreatorMode.m10 => 600,
    _ => 0
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ticker?.cancel();
    camera?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (recording) {
        stop();
      } else {
        camera?.dispose();
        camera = null;
      }
    } else if (state == AppLifecycleState.resumed && !recording) {
      initialize();
    }
  }

  Future<void> initialize([int? requestedIndex]) async {
    if (!mounted || recording) return;
    setState(() { loading = true; error = null; });
    final old = camera;
    camera = null;
    await old?.dispose();
    try {
      if (cameras.isEmpty) cameras = await availableCameras();
      if (cameras.isEmpty) throw StateError('No camera');
      final firstBack = cameras.indexWhere((c) =>
          c.lensDirection == CameraLensDirection.back);
      final index = requestedIndex ?? (firstBack < 0 ? 0 : firstBack);
      final controller = CameraController(
        cameras[index], ResolutionPreset.high, enableAudio: true);
      await controller.initialize();
      if (!mounted) { await controller.dispose(); return; }
      camera = controller;
      try { await controller.setFlashMode(flash); } catch (_) {}
      setState(() => loading = false);
    } catch (_) {
      if (mounted) setState(() {
        loading = false;
        error = 'Camera unavailable. Grant camera and microphone permission or import from Gallery.';
      });
    }
  }

  Future<void> flip() async {
    if (recording || busy || cameras.length < 2) return;
    final current = cameras.indexWhere((c) => c.name == camera?.description.name);
    await initialize((current + 1) % cameras.length);
  }

  Future<void> toggleFlash() async {
    if (recording || busy || camera == null) return;
    final next = flash == FlashMode.off ? FlashMode.auto :
        flash == FlashMode.auto ? FlashMode.always : FlashMode.off;
    try {
      await camera!.setFlashMode(next);
      if (mounted) setState(() => flash = next);
    } catch (_) { showNotice('Flash is unavailable on this camera.'); }
  }

  void showNotice(String message) {
    if (mounted) ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> capture() async {
    if (busy) return;
    if (mode == CreatorMode.text) {
      await pictureEditor(null);
      return;
    }
    if (recording) { await stop(); return; }
    final c = camera;
    if (c == null || !c.value.isInitialized) {
      showNotice('Please enable camera or import from Gallery.');
      return;
    }
    setState(() => busy = true);
    try {
      for (var remaining = timerDelay; remaining > 0; remaining--) {
        if (!mounted) return;
        setState(() => elapsed = -remaining);
        await Future<void>.delayed(const Duration(seconds: 1));
      }
      if (!mounted || c != camera) return;
      if (mode == CreatorMode.photo) {
        final photo = await c.takePicture();
        if (mounted) await pictureEditor(File(photo.path));
      } else {
        await c.startVideoRecording();
        if (!mounted) return;
        setState(() { elapsed = 0; recording = true; });
        ticker?.cancel();
        ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted || !recording) { timer.cancel(); return; }
          setState(() => elapsed++);
          if (elapsed >= maxSeconds) stop();
        });
      }
    } catch (e) { showNotice('Capture failed: ' + e.toString()); }
    finally { if (mounted) setState(() => busy = false); }
  }

  Future<void> stop() async {
    if (!recording || stopping) return;
    stopping = true;
    ticker?.cancel();
    setState(() => recording = false);
    try {
      final video = await camera!.stopVideoRecording();
      if (mounted) await videoEditor(File(video.path));
    } catch (e) { showNotice('Video could not finish: ' + e.toString()); }
    finally { stopping = false; elapsed = 0; }
  }

  Future<void> gallery() async {
    if (busy || recording) return;
    await showModalBottomSheet<void>(
      context: context, backgroundColor: const Color(0xFF19122A),
      builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: const Icon(Icons.photo_library, color: cyan),
          title: const Text('Import photo', style: TextStyle(color: Colors.white)),
          onTap: () async {
            Navigator.pop(ctx);
            try {
              final photo = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (photo != null && mounted) await pictureEditor(File(photo.path));
            } catch (e) { showNotice('Cannot import photo: ' + e.toString()); }
          }),
        ListTile(
          leading: const Icon(Icons.video_library, color: pink),
          title: const Text('Import video', style: TextStyle(color: Colors.white)),
          onTap: () async {
            Navigator.pop(ctx);
            try {
              final video = await ImagePicker().pickVideo(source: ImageSource.gallery);
              if (video != null && mounted) await videoEditor(File(video.path));
            } catch (e) { showNotice('Cannot import video: ' + e.toString()); }
          }),
      ])),
    );
  }

  Future<void> pictureEditor(File? photo) async {
    await Navigator.push(context, MaterialPageRoute<void>(
      builder: (_) => CreatorPhotoEditor(photo: photo)));
  }
  Future<void> videoEditor(File video) async {
    await Navigator.push(context, MaterialPageRoute<void>(
      builder: (_) => CreatorVideoEditor(video: video)));
  }

  Widget shortcut(IconData icon, String label, VoidCallback action) =>
    InkWell(onTap: action, child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 3),
      child: Column(children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ]),
    ));

  Widget cameraPreview() {
    if (mode == CreatorMode.text) return const Center(child: Text(
      'MEWVIO\nTEXT STORY', textAlign: TextAlign.center,
      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)));
    if (loading) return const Center(child: CircularProgressIndicator(color: pink));
    final c = camera;
    if (c == null || !c.value.isInitialized) return Center(child: Column(
      mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.no_photography_outlined, color: Colors.white, size: 48),
        const SizedBox(height: 16),
        Padding(padding: const EdgeInsets.all(16),
          child: Text(error ?? 'Camera unavailable',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70))),
        TextButton(onPressed: () => initialize(),
          child: const Text('Retry Camera')),
        TextButton(onPressed: gallery, child: const Text('Open Gallery')),
      ]));
    return Center(child: SizedBox.expand(child: ClipRect(
      child: FittedBox(fit: BoxFit.cover,
        child: SizedBox(
          width: c.value.previewSize!.height,
          height: c.value.previewSize!.width,
          child: CameraPreview(c),
        )),
    )));
  }

  Widget choice(CreatorMode which, String label) => InkWell(
    onTap: recording || busy ? null : () => setState(() => mode = which),
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: mode == which ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(26)),
        child: Text(label, style: TextStyle(
          color: mode == which ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold, fontSize: 13))),
    ));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(child: Column(children: [
      Expanded(child: Container(
        margin: const EdgeInsets.fromLTRB(6, 5, 6, 0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(colors: [
            Color(0xFF270F24), Color(0xFF51172C), Color(0xFF181124)])),
        clipBehavior: Clip.antiAlias,
        child: Stack(fit: StackFit.expand, children: [
          cameraPreview(),
          const IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter,
              end: Alignment.bottomCenter, stops: [0, .35, 1],
              colors: [Color(0x77000000), Colors.transparent, Color(0x65000000)])))),
          Positioned(top: 6, left: 6, right: 6, child: Row(children: [
            IconButton(tooltip: 'Close creator',
              onPressed: recording ? null : () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white, size: 27)),
            const Spacer(),
            ActionChip(backgroundColor: const Color(0xB0292132),
              avatar: const Icon(Icons.music_note, color: Colors.white, size: 17),
              label: const Text('Add sound • soon',
                style: TextStyle(color: Colors.white)),
              onPressed: () => showNotice('Audio mixing is not yet available.')),
            const Spacer(),
            IconButton(tooltip: 'Flip camera',
              onPressed: recording ? null : flip,
              icon: const Icon(Icons.flip_camera_android,
                color: Colors.white, size: 28)),
          ])),
          Positioned(right: 7, top: 78, child: Column(children: [
            shortcut(flash == FlashMode.off ? Icons.flash_off : Icons.flash_on,
              'Flash', toggleFlash),
            shortcut(Icons.timer_outlined, 'Timer', () {
              if (!recording) setState(() =>
                timerDelay = timerDelay == 0 ? 3 : timerDelay == 3 ? 5 : 0);
              showNotice('Timer: ' + timerDelay.toString() + ' sec');
            }),
          ])),
          if (recording)
            Positioned(top: 82, left: 17, child: Text(
              '● REC ' + elapsed.toString() + 's / ' + maxSeconds.toString() + 's',
              style: const TextStyle(color: pink, fontWeight: FontWeight.w900))),
          if (elapsed < 0)
            Center(child: Text((-elapsed).toString(), style: const TextStyle(
              color: Colors.white, fontSize: 70, fontWeight: FontWeight.w900))),
          Positioned(bottom: 17, left: 0, right: 0,
            child: Column(children: [
              SingleChildScrollView(scrollDirection: Axis.horizontal,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  choice(CreatorMode.m10, '10m'),
                  choice(CreatorMode.s60, '60s'),
                  choice(CreatorMode.s15, '15s'),
                  choice(CreatorMode.photo, 'PHOTO'),
                  choice(CreatorMode.text, 'TEXT'),
                ])),
              const SizedBox(height: 22),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                IconButton(tooltip: 'Import Gallery',
                  onPressed: recording ? null : gallery,
                  icon: const Icon(Icons.photo_library_outlined,
                    color: Colors.white, size: 33)),
                GestureDetector(key: const Key('creator-shutter'), onTap: capture,
                  child: Container(width: 91, height: 91,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                      color: recording ? pink : Colors.white,
                      border: Border.all(color: Colors.white, width: 4)),
                    child: Icon(recording ? Icons.stop_rounded :
                      mode == CreatorMode.text ? Icons.edit :
                      isVideo ? Icons.videocam : Icons.camera_alt,
                      color: recording ? Colors.white : Colors.black87, size: 39))),
                const SizedBox(width: 43),
              ]),
              const SizedBox(height: 5),
              Text(recording ? 'Tap to stop' :
                mode == CreatorMode.text ? 'Create text card' :
                mode == CreatorMode.photo ? 'Take photo' : 'Tap to record video',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ])),
        ])),
      ),
      const Padding(padding: EdgeInsets.symmetric(vertical: 17),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text('CAMERA', style: TextStyle(color: Colors.white,
            fontWeight: FontWeight.w900)),
          Text('CREATE', style: TextStyle(color: Colors.white70)),
          Text('LIVE • soon', style: TextStyle(color: Colors.white38)),
        ])),
    ])),
  );
}

class CreatorPhotoEditor extends StatefulWidget {
  const CreatorPhotoEditor({super.key, this.photo});
  final File? photo;
  @override
  State<CreatorPhotoEditor> createState() => _CreatorPhotoEditorState();
}

class _CreatorPhotoEditorState extends State<CreatorPhotoEditor> {
  final GlobalKey boundaryKey = GlobalKey();
  final TextEditingController text = TextEditingController();
  bool saving = false;
  @override
  void dispose() { text.dispose(); super.dispose(); }

  Future<void> export() async {
    if (saving) return;
    setState(() => saving = true);
    try {
      final boundary = boundaryKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('Image rendering failed');
      final dir = await getTemporaryDirectory();
      final file = File(dir.path + '/mewvio-photo-' +
        DateTime.now().millisecondsSinceEpoch.toString() + '.png');
      await file.writeAsBytes(data.buffer.asUint8List());
      await Gal.putImage(file.path);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved image to Gallery.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot save image: ' + e.toString())));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: dark,
    appBar: AppBar(backgroundColor: dark, foregroundColor: Colors.white,
      title: Text(widget.photo == null ? 'Text Story' : 'Edit Photo')),
    body: SafeArea(child: Padding(padding: const EdgeInsets.all(15),
      child: Column(children: [
        Expanded(child: Center(child: AspectRatio(aspectRatio: 9 / 16,
          child: RepaintBoundary(key: boundaryKey, child: Stack(
            fit: StackFit.expand, children: [
              if (widget.photo != null) Image.file(widget.photo!, fit: BoxFit.cover)
              else const DecoratedBox(decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color(0xFF252466), Color(0xFF9D3A99), Color(0xFF17192F)]))),
              Center(child: Padding(padding: const EdgeInsets.all(14),
                child: Text(text.text, textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white,
                    fontSize: 26, fontWeight: FontWeight.w900,
                    shadows: [Shadow(color: Colors.black, blurRadius: 5)])))),
            ])),
          ),
        )),
        const SizedBox(height: 12),
        TextField(
          key: const Key('creator-caption'), maxLength: 100,
          controller: text, onChanged: (_) => setState(() {}),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Add text', hintStyle: const TextStyle(color: Colors.white54),
            filled: true, fillColor: const Color(0xFF2A2339),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
        SizedBox(width: double.infinity, child: FilledButton.icon(
          key: const Key('creator-export-photo'),
          onPressed: saving ? null : export,
          icon: const Icon(Icons.save_alt),
          label: Text(saving ? 'Saving…' : 'Save photo to Gallery'),
          style: FilledButton.styleFrom(backgroundColor: pink))),
      ]))),
  );
}

class CreatorVideoEditor extends StatefulWidget {
  const CreatorVideoEditor({super.key, required this.video});
  final File video;
  @override
  State<CreatorVideoEditor> createState() => _CreatorVideoEditorState();
}

class _CreatorVideoEditorState extends State<CreatorVideoEditor> {
  final Trimmer trimmer = Trimmer();
  bool loading = true;
  bool saving = false;
  bool playing = false;
  double start = 0;
  double end = 0;

  @override
  void initState() { super.initState(); load(); }
  Future<void> load() async {
    try {
      await trimmer.loadVideo(videoFile: widget.video);
      if (mounted) setState(() => loading = false);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot load video: ' + e.toString())));
    }
  }

  Future<void> export({required bool trimmed}) async {
    if (saving) return;
    setState(() => saving = true);
    try {
      var path = widget.video.path;
      if (trimmed) {
        if (end <= start) throw StateError('Choose a valid trim range.');
        String? trimmedPath;
        await trimmer.saveTrimmedVideo(
          startValue: start, endValue: end,
          onSave: (outputPath) => trimmedPath = outputPath);
        if (trimmedPath == null) throw StateError('Trim produced no file');
        path = trimmedPath!;
      }
      await Gal.putVideo(path);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video MP4 saved to Gallery.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot export MP4: ' + e.toString())));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: dark,
    appBar: AppBar(backgroundColor: dark,
      foregroundColor: Colors.white, title: const Text('Edit Video • MP4')),
    body: SafeArea(child: loading ?
      const Center(child: CircularProgressIndicator(color: pink)) :
      Column(children: [
        Expanded(child: VideoViewer(trimmer: trimmer)),
        const SizedBox(height: 10),
        const Text('Drag the handles to trim and save a new MP4.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 9),
        TrimViewer(trimmer: trimmer, viewerHeight: 55,
          viewerWidth: MediaQuery.sizeOf(context).width - 20,
          maxVideoLength: const Duration(minutes: 10),
          onChangeStart: (value) => start = value,
          onChangeEnd: (value) => end = value,
          onChangePlaybackState: (value) =>
            setState(() => playing = value)),
        IconButton(onPressed: () async {
          final state = await trimmer.videoPlaybackControl(
            startValue: start, endValue: end);
          if (mounted) setState(() => playing = state);
        }, icon: Icon(playing ? Icons.pause_circle_filled :
          Icons.play_circle_fill, color: Colors.white, size: 43)),
        Wrap(alignment: WrapAlignment.center, spacing: 10, children: [
          OutlinedButton.icon(
            onPressed: saving ? null : () => export(trimmed: false),
            icon: const Icon(Icons.save_alt), label: const Text('Save original')),
          FilledButton.icon(
            key: const Key('creator-trim-export'),
            onPressed: saving ? null : () => export(trimmed: true),
            style: FilledButton.styleFrom(backgroundColor: pink),
            icon: const Icon(Icons.content_cut), label: const Text('Trim & Save')),
        ]),
        if (saving) const Padding(padding: EdgeInsets.all(10),
          child: LinearProgressIndicator(color: cyan)),
        const SizedBox(height: 16),
      ])),
  );
}
