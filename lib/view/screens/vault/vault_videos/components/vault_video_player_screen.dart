import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:nook/controller/vault_videos_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/model/vault_models.dart';
import 'package:nook/view/widgets/app_text.dart';

class VaultVideoPlayerScreen extends StatefulWidget {
  final VaultVideo video;

  const VaultVideoPlayerScreen({super.key, required this.video});

  @override
  State<VaultVideoPlayerScreen> createState() => _VaultVideoPlayerScreenState();
}

class _VaultVideoPlayerScreenState extends State<VaultVideoPlayerScreen> {
  final VaultVideosController _controller = Get.find<VaultVideosController>();
  VideoPlayerController? _vpc;
  File? _tempFile;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final file = await _controller.decryptVideoToTemp(widget.video);
      _tempFile = file;
      _vpc = VideoPlayerController.file(file);
      await _vpc!.initialize();
      setState(() {
        _isLoading = false;
      });
      _vpc!.play();
      _vpc!.setLooping(true);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _vpc?.dispose();
    if (_tempFile != null) {
      _controller.cleanupTempFile(_tempFile!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.vaultTextHi),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: AppColors.vaultAccent)
            : _hasError
                ? const AppText('Failed to decrypt and load video', color: AppColors.vaultDanger)
                : AspectRatio(
                    aspectRatio: _vpc!.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        VideoPlayer(_vpc!),
                        _VideoControls(vpc: _vpc!),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _VideoControls extends StatefulWidget {
  final VideoPlayerController vpc;

  const _VideoControls({required this.vpc});

  @override
  State<_VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<_VideoControls> {
  bool _showControls = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: Container(
        color: Colors.transparent,
        child: AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                color: Colors.black.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        widget.vpc.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          if (widget.vpc.value.isPlaying) {
                            widget.vpc.pause();
                          } else {
                            widget.vpc.play();
                          }
                        });
                      },
                    ),
                    Expanded(
                      child: VideoProgressIndicator(
                        widget.vpc,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: AppColors.vaultAccent,
                          bufferedColor: Colors.white24,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ValueListenableBuilder(
                      valueListenable: widget.vpc,
                      builder: (context, VideoPlayerValue value, child) {
                        final pos = value.position;
                        final min = pos.inMinutes.toString().padLeft(2, '0');
                        final sec = (pos.inSeconds % 60).toString().padLeft(2, '0');
                        return AppText(
                          '$min:$sec',
                          color: AppColors.vaultTextHi,
                          size: 12,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
