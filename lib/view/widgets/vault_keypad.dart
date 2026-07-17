import 'package:flutter/material.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';

class VaultKeypad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackspace;

  const VaultKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['1', '2', '3']),
        Gap.v(16),
        _buildRow(['4', '5', '6']),
        Gap.v(16),
        _buildRow(['7', '8', '9']),
        Gap.v(16),
        _buildLastRow(),
      ],
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildKeypadButton(d)).toList(),
    );
  }

  Widget _buildLastRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Empty space or placeholder for alignment
        SizedBox(width: 72.adaptSize, height: 72.adaptSize),
        _buildKeypadButton('0'),
        _buildBackspaceButton(),
      ],
    );
  }

  Widget _buildKeypadButton(String digit) {
    return GestureDetector(
      onTap: () => onDigitPressed(digit),
      child: Container(
        width: 72.adaptSize,
        height: 72.adaptSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.vaultGlassFill,
          border: Border.all(
            color: AppColors.vaultGlassBorder,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: AppText(
          digit,
          size: 24,
          weight: FontWeight.w600,
          color: AppColors.vaultTextHi,
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: onBackspace,
      child: Container(
        width: 72.adaptSize,
        height: 72.adaptSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.vaultGlassFill,
          border: Border.all(
            color: AppColors.vaultGlassBorder,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.backspace_outlined,
          color: AppColors.vaultTextHi,
          size: 20,
        ),
      ),
    );
  }
}
