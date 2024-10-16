import 'package:flutter/material.dart';
import 'package:r_place_clone/entry.dart';
import 'package:video_player/video_player.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {

  late VideoPlayerController _controller;

  @override
  void initState(){
    super.initState();
    _controller = VideoPlayerController.asset('assets/splash.mp4') ..initialize().then((_) {
      setState((){});
    })..setVolume(0.0);
    _playVideo();
  }

  void _playVideo() async{
    _controller.play();
    await Future.delayed(const Duration(seconds: 8));
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Entry()));
    }
  }
  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : Container(),
      ),
    );
  }
}