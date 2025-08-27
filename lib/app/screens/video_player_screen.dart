import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:than_pkg/than_pkg.dart';

class VideoPlayerScreen extends StatefulWidget {
  String resoure;
  String title;
  bool isAutoPlay;
  VideoPlayerScreen({
    super.key,
    required this.resoure,
    required this.title,
    this.isAutoPlay = false,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  @override
  void initState() {
    init();
    super.initState();
    if (Platform.isAndroid) {
      // ThanPkg.platform.toggleFullScreen(isFullScreen: true);
    }
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      // ThanPkg.platform.toggleFullScreen(isFullScreen: false);
    }
    super.dispose();
  }

  late final Player player = Player();
  late final _controller = VideoController(player);

  int allSeconds = 0;
  int progressSeconds = 0;
  double? playerHeight;
  double playerRatio = 16 / 9;
  double mobileVideoPlayerMinHeight = 200;

  void init() async {
    try {
      await player.open(Media(widget.resoure));

      //delay
      await Future.delayed(Duration(milliseconds: 800));

      //listen player loaded or not
      if (player.state.duration > Duration.zero) {
        //file ရှိနေတယ်
        if (!mounted) return;
        final screenWidth = MediaQuery.of(context).size.width;
        final ratio = player.state.videoParams.aspect ?? 16 / 9;
        final calculatedHeight = screenWidth / ratio;
        setState(() {
          playerRatio = ratio;
          playerHeight = calculatedHeight;
        });
      } else {
        playerHeight = null;
      }
    } catch (e) {
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await player.playOrPause();
          await player.dispose();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Video(
          controller: _controller,
          onEnterFullscreen: () async {
            final height = player.state.height ?? 0;
            final width = player.state.width ?? 0;
            if (height > width) {
              if (Platform.isAndroid) {
                await ThanPkg.android.app.showFullScreen();
                return;
              }
            }
            await defaultEnterNativeFullscreen();
          },
          onExitFullscreen: () async {
            if (Platform.isAndroid) {
              await ThanPkg.android.app.hideFullScreen();
            }
            await defaultExitNativeFullscreen();
          },
        ),
      ),
    );
  }
}
