import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nook/controller/vault_photos_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/model/vault_models.dart';
import 'package:nook/view/widgets/app_text.dart';
import 'package:nook/view/screens/vault/components/vault_delete_confirm_dialog.dart';

class VaultPhotoViewer extends StatefulWidget {
  final List<VaultPhoto> photos;
  final int initialIndex;

  const VaultPhotoViewer({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<VaultPhotoViewer> createState() => _VaultPhotoViewerState();
}

class _VaultPhotoViewerState extends State<VaultPhotoViewer> {
  final VaultPhotosController _controller = Get.find<VaultPhotosController>();
  late PageController _pageController;
  late List<VaultPhoto> _photosList;
  late int _currentIndex;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _photosList = widget.photos.toList();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _prefetchAdjacent(_currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _prefetchAdjacent(int index) {
    if (index > 0 && index - 1 < _photosList.length) {
      _controller.decryptPhotoBytes(_photosList[index - 1]);
    }
    if (index + 1 < _photosList.length) {
      _controller.decryptPhotoBytes(_photosList[index + 1]);
    }
  }

  Future<void> _restoreCurrentPhoto() async {
    if (_photosList.isEmpty) return;
    final photo = _photosList[_currentIndex];
    final ok = await _controller.restorePhoto(photo);
    if (ok) {
      setState(() {
        _photosList.removeAt(_currentIndex);
        if (_photosList.isEmpty) {
          Get.back();
        } else {
          if (_currentIndex >= _photosList.length) {
            _currentIndex = _photosList.length - 1;
          }
          _prefetchAdjacent(_currentIndex);
        }
      });
    }
  }

  Future<void> _deleteCurrentPhoto() async {
    if (_photosList.isEmpty) return;
    final photo = _photosList[_currentIndex];

    await showVaultDeleteDialog(
      title: 'Delete Photo',
      message: 'Are you sure you want to delete this photo permanently?',
      onConfirm: () async {
        _controller.selectedIds.clear();
        if (photo.id != null) {
          _controller.selectedIds.add(photo.id!);
          await _controller.deleteSelected();
        }
        setState(() {
          _photosList.removeAt(_currentIndex);
          if (_photosList.isEmpty) {
            Get.back();
          } else {
            if (_currentIndex >= _photosList.length) {
              _currentIndex = _photosList.length - 1;
            }
            _prefetchAdjacent(_currentIndex);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_photosList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppText(
          '${_currentIndex + 1} of ${_photosList.length}',
          color: AppColors.vaultTextHi,
          size: 16,
          weight: FontWeight.w600,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.vaultTextHi),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore, color: AppColors.vaultAccent),
            tooltip: 'Restore to Downloads',
            onPressed: _restoreCurrentPhoto,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.vaultDanger),
            tooltip: 'Delete Photo',
            onPressed: _deleteCurrentPhoto,
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: _isZoomed
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        itemCount: _photosList.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _isZoomed = false;
          });
          _prefetchAdjacent(index);
        },
        itemBuilder: (context, index) {
          final photo = _photosList[index];
          return _SinglePhotoView(
            key: ValueKey(photo.id ?? photo.encryptedPath),
            photo: photo,
            controller: _controller,
            onZoomChanged: (zoomed) {
              if (_isZoomed != zoomed) {
                setState(() {
                  _isZoomed = zoomed;
                });
              }
            },
          );
        },
      ),
    );
  }
}

class _SinglePhotoView extends StatefulWidget {
  final VaultPhoto photo;
  final VaultPhotosController controller;
  final ValueChanged<bool> onZoomChanged;

  const _SinglePhotoView({
    super.key,
    required this.photo,
    required this.controller,
    required this.onZoomChanged,
  });

  @override
  State<_SinglePhotoView> createState() => _SinglePhotoViewState();
}

class _SinglePhotoViewState extends State<_SinglePhotoView> {
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    widget.onZoomChanged(scale > 1.05);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: widget.controller.decryptPhotoBytes(widget.photo),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.vaultAccent),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: AppText(
              'Failed to load image',
              color: AppColors.vaultDanger,
            ),
          );
        }
        return SizedBox.expand(
          child: InteractiveViewer(
            transformationController: _transformationController,
            clipBehavior: Clip.none,
            minScale: 1.0,
            maxScale: 4.0,
            child: Center(
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        );
      },
    );
  }
}
