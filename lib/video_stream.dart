import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LiveStreamVideo extends StatefulWidget {
  const LiveStreamVideo({
    Key? key,
    this.title,
    this.activeUsers,
    this.controller,
    this.url,
    this.keepAlive = false,
    this.videoFormat = VideoFormat.hls,
  }) : super(key: key);

  final bool keepAlive;

  /// Displays Title if available
  final String? title;

  /// If you are not going to display the Active Users info
  /// Please ignore this parameter.
  final int? activeUsers;

  /// url is required when there is no controller
  /// The given url will be played automatically
  final String? url;

  /// Default the [VideoFormat.hls], When you give the url parameter
  /// its active so that you can change whatever format you would like to use
  final VideoFormat videoFormat;

  /// If you need to control video outside of the widget,
  /// I recommend to use this parameter so you have overall control with video player
  final VideoPlayerController? controller;

  @override
  State<LiveStreamVideo> createState() => _LiveStreamVideoState();
}

class _LiveStreamVideoState extends State<LiveStreamVideo>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late VideoPlayerController _controller;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      lowerBound: 0,
      upperBound: 1,
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else if (widget.url != null) {
      _controller = VideoPlayerController.network(
        widget.url!,
        formatHint: widget.videoFormat,
      );
    }
    _controller.addListener(() {
      setState(() {});
    });
    _animationController.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) {
      setState(() {});
    });
    _animationController.forward();
    // _controller.play();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    // if we have external controller we don't want to control its state
    if (widget.controller == null) {
      _controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = 16 / 9;
    return Material(
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          children: [
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: VideoPlayer(
                  _controller,
                ),
              ),
            ),
            _buildVideoControls(),
            GestureDetector(
              onTap: () {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              },
            ),
            if (widget.title != null)
              Positioned(
                left: 16,
                bottom: 10,
                child: Tooltip(
                  message: widget.title!,
                  child: Text(
                    widget.title!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  AnimatedSwitcher _buildVideoControls() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 50),
      reverseDuration: const Duration(milliseconds: 200),
      child: _controller.value.isPlaying
          ? const SizedBox.shrink()
          : Container(
              color: Colors.black26,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }


  void videoOnTap() {
    if (!_controller.value.isPlaying) {
      _animationController.reverse();
      _controller.play();
    } else if (_animationController.status == AnimationStatus.dismissed) {
      _animationController.forward();
      hidePlayButton();
    } else if (_animationController.status == AnimationStatus.completed) {
      _animationController.reverse();
    }
  }

  void hidePlayButton() {
    Future.delayed(Duration(seconds: 2)).then(
      (value) {
        if (_animationController.status != AnimationStatus.dismissed &&
            _controller.value.isPlaying == true) {
          return _animationController.reverse();
        }
      },
    );
  }

  void playOnTap() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _animationController.forward();
    } else {
      _controller.play();
      _animationController.reverse();
    }
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}

class LiveStreamVideoNoControls extends StatelessWidget {
  const LiveStreamVideoNoControls({
    Key? key,
    required this.title,
    required this.activeUsers,
    this.aspectRatio = 16 / 9,
    required this.controller,
  }) : super(key: key);

  /// Displays Title if available
  final String? title;

  /// If you are not going to display the Active Users info
  /// Please ignore this parameter.
  final int? activeUsers;
  final double aspectRatio;

  /// If you need to control video outside of the widget,
  /// I recommend to use this parameter so you have overall control with video player
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          children: [
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: VideoPlayer(
                  controller,
                ),
              ),
            ),
            _buildVideoControls(),
            GestureDetector(
              onTap: () {
                // TODO(onat): get new hide keyboard thing.
                // if (AnimationHelper.instance.isAnimationAvailable) {
                // } else {
                controller.value.isPlaying
                    ? controller.pause()
                    : controller.play();
                // }
              },
            ),
            if (title != null)
              Positioned(
                left: 16,
                bottom: 10,
                child: AnimatedOpacity(
                  duration: Duration(
                    seconds: controller.value.isPlaying ? 3 : 0,
                  ),
                  opacity: controller.value.isPlaying ? 0 : 1,
                  child: Tooltip(
                    message: title!,
                    child: Text(
                      title!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            if (activeUsers != null) _buildActiveUsers(context),
          ],
        ),
      ),
    );
  }

  AnimatedSwitcher _buildVideoControls() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 50),
      reverseDuration: const Duration(milliseconds: 200),
      child: controller.value.isPlaying
          ? const SizedBox.shrink()
          : Container(
              color: Colors.black26,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Positioned _buildActiveUsers(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: Visibility(
        visible: activeUsers! > 0,
        child: GestureDetector(
          onTap: () {
            Scaffold.of(context).openEndDrawer();
          },
          child: Container(
            width: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 12,
                ),
                SizedBox(
                  width: 4,
                ),
                Text(
                  activeUsers.toString(),
                  style:
                      TextStyle( fontSize: 14),
                ),
                SizedBox(
                  width: 12,
                ),
              ],
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
