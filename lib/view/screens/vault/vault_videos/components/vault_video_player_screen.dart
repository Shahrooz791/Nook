import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:nook/controller/vault_videos_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/model/vault_models.dart';
import 'package:nook/view/widgets/app_text.dart';
import 'package:nook/view/screens/vault/components/vault_delete_confirm_dialog.dart';

class VaultVideoPlayerScreen extends StatefulWidget {
  final List<VaultVideo> videos;
  final int initialIndex;

  const VaultVideoPlayerScreen({
    super.key,
    required this.videos,
    required this.initialIndex,
  });

  @override
  State<VaultVideoPlayerScreen> createState() => _VaultVideoPlayerScreenState();
}

class _VaultVideoPlayerScreenState extends State<VaultVideoPlayerScreen> {
  final VaultVideosController _controller = Get.find<VaultVideosController>();
  late PageController _pageController;
  late List<VaultVideo> _videosList;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _videosList = widget.videos.toList();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _prefetchAdjacentThumbs(_currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _prefetchAdjacentThumbs(int index) {
    if (index > 0 && index - 1 < _videosList.length) {
      _controller.decryptVideoThumb(_videosList[index - 1]);
    }
    if (index + 1 < _videosList.length) {
      _controller.decryptVideoThumb(_videosList[index + 1]);
    }
  }

  Future<void> _restoreCurrentVideo() async {
    if (_videosList.isEmpty) return;
    final video = _videosList[_currentIndex];
    final ok = await _controller.restoreVideo(video);
    if (ok) {
      setState(() {
        _videosList.removeAt(_currentIndex);
        if (_videosList.isEmpty) {
          Get.back();
        } else {
          if (_currentIndex >= _videosList.length) {
            _currentIndex = _videosList.length - 1;
          }
          _prefetchAdjacentThumbs(_currentIndex);
        }
      });
    }
  }

  Future<void> _deleteCurrentVideo() async {
    if (_videosList.isEmpty) return;
    final video = _videosList[_currentIndex];

    await showVaultDeleteDialog(
      title: 'Delete Video',
      message: 'Are you sure you want to delete this video permanently?',
      onConfirm: () async {
        _controller.selectedIds.clear();
        if (video.id != null) {
          _controller.selectedIds.add(video.id!);
          await _controller.deleteSelected();
        }
        setState(() {
          _videosList.removeAt(_currentIndex);
          if (_videosList.isEmpty) {
            Get.back();
          } else {
            if (_currentIndex >= _videosList.length) {
              _currentIndex = _videosList.length - 1;
            }
            _prefetchAdjacentThumbs(_currentIndex);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_videosList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppText(
          '${_currentIndex + 1} of ${_videosList.length}',
          color: AppColors.vaultTextHi,
          size: 16,
          weight: FontWeight.w600,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.vaultTextHi),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore, color: AppColors.vaultAccent),
            tooltip: 'Restore to Downloads',
            onPressed: _restoreCurrentVideo,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.vaultDanger),
            tooltip: 'Delete Video',
            onPressed: _deleteCurrentVideo,
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        itemCount: _videosList.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          _prefetchAdjacentThumbs(index);
        },
        itemBuilder: (context, index) {
          final video = _videosList[index];
          return _SingleVideoPlayer(
            key: ValueKey(video.id ?? video.encryptedPath),
            video: video,
            controller: _controller,
          );
        },
      ),
    );
  }
}

class _SingleVideoPlayer extends StatefulWidget {
  final VaultVideo video;
  final VaultVideosController controller;

  const _SingleVideoPlayer({
    super.key,
    required this.video,
    required this.controller,
  });

  @override
  State<_SingleVideoPlayer> createState() => _SingleVideoPlayerState();
}

class _SingleVideoPlayerState extends State<_SingleVideoPlayer> {
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
      final file = await widget.controller.decryptVideoToTemp(widget.video);
      if (!mounted) {
        widget.controller.cleanupTempFile(file);
        return;
      }
      _tempFile = file;
      _vpc = VideoPlayerController.file(file);
      await _vpc!.initialize();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _vpc!.play();
      _vpc!.setLooping(true);
    } catch (e) {
      if (!mounted) return;
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
      widget.controller.cleanupTempFile(_tempFile!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.vaultAccent),
      );
    }

    if (_hasError || _vpc == null) {
      return const Center(
        child: AppText(
          'Failed to decrypt and load video',
          color: AppColors.vaultDanger,
        ),
      );
    }

    return SizedBox.expand(
      child: Center(
        child: AspectRatio(
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
