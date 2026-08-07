import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nook/controller/vault_passwords_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';
import 'package:nook/view/widgets/glass_container.dart';
import 'package:nook/view/widgets/primary_button.dart';

class VaultPasswordForm extends StatefulWidget {
  final DecryptedPassword? passwordEntry;

  const VaultPasswordForm({super.key, this.passwordEntry});

  @override
  State<VaultPasswordForm> createState() => _VaultPasswordFormState();
}

class _VaultPasswordFormState extends State<VaultPasswordForm> {
  final VaultPasswordsController _controller = Get.find<VaultPasswordsController>();
  late final TextEditingController _titleController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _notesController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.passwordEntry?.raw.title ?? '');
    _usernameController = TextEditingController(text: widget.passwordEntry?.username ?? '');
    _passwordController = TextEditingController(text: widget.passwordEntry?.password ?? '');
    _notesController = TextEditingController(text: widget.passwordEntry?.notes ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _generatePassword() {
    final generated = _controller.generatePassword();
    setState(() {
      _passwordController.text = generated;
      _obscurePassword = false;
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final notes = _notesController.text.trim();

    if (title.isEmpty || username.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Required Fields',
        'Title, Username, and Password cannot be empty.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.vaultGlassFillStrong,
        colorText: AppColors.vaultTextHi,
      );
      return;
    }

    await _controller.savePassword(
      id: widget.passwordEntry?.raw.id,
      title: title,
      username: username,
      password: password,
      notes: notes,
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      isVault: true,
      radius: 24,
      padding: EdgeInsets.all(24.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  widget.passwordEntry == null ? 'Add Password' : 'Edit Password',
                  size: 18,
                  weight: FontWeight.w600,
                  color: AppColors.vaultTextHi,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.vaultTextLo),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            Gap.v(16),

            // Title Field
            _buildField('Title / App Name', _titleController, 'e.g. Spotify'),
            Gap.v(12),

            // Username Field
            _buildField('Username / Email', _usernameController, 'e.g. user@email.com'),
            Gap.v(12),

            // Password Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText('Password', size: 12, color: AppColors.vaultTextLo),
                Gap.v(6),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: AppColors.vaultTextHi),
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    hintStyle: TextStyle(color: AppColors.vaultTextLo.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: AppColors.vaultGlassFill,
                    border: OutlineInputBorder(
                      borderRadius: 12.r,
                      borderSide: BorderSide(color: AppColors.vaultGlassBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: 12.r,
                      borderSide: BorderSide(color: AppColors.vaultGlassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: 12.r,
                      borderSide: const BorderSide(color: AppColors.vaultAccent),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 14.v),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.vaultTextLo,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        IconButton(
                          icon: const Icon(Icons.vpn_key_outlined, color: AppColors.vaultAccent),
                          onPressed: _generatePassword,
                          tooltip: 'Generate Password',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Gap.v(12),

            // Notes Field
            _buildField('Notes (Optional)', _notesController, 'Add details...', maxLines: 3),
            Gap.v(24),

            PrimaryButton(
              label: 'Save Password',
              isVault: true,
              onTap: _save,
            ),
            Gap.v(8),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController textController, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, size: 12, color: AppColors.vaultTextLo),
        Gap.v(6),
        TextField(
          controller: textController,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.vaultTextHi),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.vaultTextLo.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppColors.vaultGlassFill,
            border: OutlineInputBorder(
              borderRadius: 12.r,
              borderSide: BorderSide(color: AppColors.vaultGlassBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: 12.r,
              borderSide: BorderSide(color: AppColors.vaultGlassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: 12.r,
              borderSide: const BorderSide(color: AppColors.vaultAccent),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 14.v),
          ),
        ),
      ],
    );
  }
}
