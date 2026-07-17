import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nook/controller/vault_notes_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';

class VaultNoteEditor extends StatefulWidget {
  final DecryptedNote? note;

  const VaultNoteEditor({super.key, this.note});

  @override
  State<VaultNoteEditor> createState() => _VaultNoteEditorState();
}

class _VaultNoteEditorState extends State<VaultNoteEditor> {
  final VaultNotesController _controller = Get.find<VaultNotesController>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _bodyController = TextEditingController(text: widget.note?.body ?? '');

    _titleController.addListener(_markChanges);
    _bodyController.addListener(_markChanges);
  }

  void _markChanges() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await _controller.saveNote(
      id: widget.note?.raw.id,
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
    );
    setState(() {
      _hasChanges = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_hasChanges) await _save();
        Get.back();
      },
      child: Scaffold(
        backgroundColor: AppColors.vaultBgA,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppColors.vaultBgGradient),
          child: SafeArea(
            child: Column(
              children: [
                // Top header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.v),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.vaultTextHi),
                        onPressed: () async {
                          if (_hasChanges) await _save();
                          Get.back();
                        },
                      ),
                      AppText(
                        widget.note == null ? 'New Note' : 'Edit Note',
                        size: 18,
                        weight: FontWeight.w600,
                        color: AppColors.vaultTextHi,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.check,
                          color: _hasChanges ? AppColors.vaultAccent : AppColors.vaultTextLo,
                        ),
                        onPressed: _hasChanges
                            ? () async {
                                await _save();
                                Get.back();
                              }
                            : null,
                      ),
                    ],
                  ),
                ),

                // Text Editors
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(24.h),
                    children: [
                      TextField(
                        controller: _titleController,
                        style: TextStyle(
                          color: AppColors.vaultTextHi,
                          fontSize: 22.fSize,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Note Title',
                          hintStyle: TextStyle(
                            color: AppColors.vaultTextLo.withValues(alpha: 0.5),
                            fontSize: 22.fSize,
                            fontWeight: FontWeight.w700,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      Gap.v(16),
                      TextField(
                        controller: _bodyController,
                        style: TextStyle(
                          color: AppColors.vaultTextHi,
                          fontSize: 15.fSize,
                          height: 1.6,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Write your thoughts here...',
                          hintStyle: TextStyle(
                            color: AppColors.vaultTextLo.withValues(alpha: 0.5),
                            fontSize: 15.fSize,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
