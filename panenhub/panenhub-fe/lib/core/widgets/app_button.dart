import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Reusable primary button with loading state
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isDanger;
  final bool isSmall;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDanger = false,
    this.isSmall = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final height = isSmall ? AppSpacing.buttonSmallHeight : AppSpacing.buttonHeight;
    final radius = isSmall ? AppSpacing.buttonSmallRadius : AppSpacing.buttonRadius;
    final bgColor = backgroundColor ?? (isDanger ? AppColors.error : AppColors.primary);
    final fgColor = foregroundColor ?? AppColors.textOnPrimary;

    if (isOutlined) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: bgColor,
            side: BorderSide(
              color: onPressed == null && !isLoading
                  ? bgColor.withValues(alpha: 0.3)
                  : bgColor,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
            disabledForegroundColor: bgColor.withValues(alpha: 0.4),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildChild(bgColor),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: bgColor.withValues(alpha: 0.4),
          disabledForegroundColor: fgColor.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          elevation: onPressed != null && !isLoading ? 2 : 0,
          shadowColor: bgColor.withValues(alpha: 0.35),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildChild(fgColor),
        ),
      ),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        key: const ValueKey('loading'),
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          strokeCap: StrokeCap.round,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined ? color : AppColors.textOnPrimary,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        key: const ValueKey('icon-label'),
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmall ? 16 : 18),
          const SizedBox(width: 10),
          Text(label),
        ],
      );
    }

    return Text(label, key: const ValueKey('label'));
  }
}
