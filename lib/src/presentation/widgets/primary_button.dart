import 'package:flutter/material.dart';

import '../../config/theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isBusy = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isBusy;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final child = isBusy
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(label, style: AppTextStyles.button(context)),
            ],
          );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isBusy ? null : onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: child,
        ),
      ),
    );
  }
}
