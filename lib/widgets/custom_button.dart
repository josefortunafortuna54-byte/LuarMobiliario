import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

enum CustomButtonVariant { primary, secondary, outline, text }

enum CustomButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.variant = CustomButtonVariant.primary,
    this.size = CustomButtonSize.medium,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconPosition = IconPosition.start,
    this.enabled = true,
  });

  final String text;
  final CustomButtonVariant variant;
  final CustomButtonSize size;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final IconPosition iconPosition;
  final bool enabled;

  bool get _isEnabled => enabled && !isLoading;

  VoidCallback? get _onPressed => _isEnabled ? onPressed : null;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? _buildLoading()
        : _buildContent();

    final button = switch (variant) {
      CustomButtonVariant.primary => _buildPrimary(child),
      CustomButtonVariant.secondary => _buildSecondary(child),
      CustomButtonVariant.outline => _buildOutline(child),
      CustomButtonVariant.text => _buildText(child),
    };

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  Widget _buildContent() {
    final content = <Widget>[];

    if (icon != null && iconPosition == IconPosition.start) {
      content.add(Icon(icon, size: _iconSize, color: _iconColor));
      content.add(SizedBox(width: _iconSpacing));
    }

    content.add(
      Flexible(
        child: Text(
          text,
          style: _textStyle,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    if (icon != null && iconPosition == IconPosition.end) {
      content.add(SizedBox(width: _iconSpacing));
      content.add(Icon(icon, size: _iconSize, color: _iconColor));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: content,
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      width: _iconSize,
      height: _iconSize,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          variant == CustomButtonVariant.primary ||
                  variant == CustomButtonVariant.secondary
              ? AppColors.white
              : AppColors.navy,
        ),
      ),
    );
  }

  Widget _buildPrimary(Widget child) {
    return ElevatedButton(
      onPressed: _onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isEnabled ? AppColors.gold : AppColors.gray300,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.gray300,
        disabledForegroundColor: AppColors.white,
        padding: _padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        elevation: _isEnabled ? 4 : 0,
        shadowColor: AppColors.gold.withValues(alpha: 0.4),
      ),
      child: child,
    );
  }

  Widget _buildSecondary(Widget child) {
    return ElevatedButton(
      onPressed: _onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isEnabled ? AppColors.navy : AppColors.gray300,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.gray300,
        disabledForegroundColor: AppColors.white,
        padding: _padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        elevation: _isEnabled ? 4 : 0,
        shadowColor: AppColors.navy.withValues(alpha: 0.3),
      ),
      child: child,
    );
  }

  Widget _buildOutline(Widget child) {
    return OutlinedButton(
      onPressed: _onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: _isEnabled ? AppColors.navy : AppColors.gray400,
        disabledForegroundColor: AppColors.gray400,
        side: BorderSide(
          color: _isEnabled ? AppColors.navy : AppColors.gray300,
          width: 1.5,
        ),
        padding: _padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
      ),
      child: child,
    );
  }

  Widget _buildText(Widget child) {
    return TextButton(
      onPressed: _onPressed,
      style: TextButton.styleFrom(
        foregroundColor: _isEnabled ? AppColors.gold : AppColors.gray400,
        disabledForegroundColor: AppColors.gray400,
        padding: _padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
      ),
      child: child,
    );
  }

  double get _borderRadius => switch (size) {
    CustomButtonSize.small => 8,
    CustomButtonSize.medium => 10,
    CustomButtonSize.large => 12,
  };

  EdgeInsets get _padding => switch (size) {
    CustomButtonSize.small =>
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    CustomButtonSize.medium =>
      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    CustomButtonSize.large =>
      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
  };

  TextStyle get _textStyle => switch (size) {
    CustomButtonSize.small => AppTextStyles.buttonSmall.copyWith(
      color: variant == CustomButtonVariant.primary ||
              variant == CustomButtonVariant.secondary
          ? AppColors.white
          : AppColors.navy,
    ),
    CustomButtonSize.medium => AppTextStyles.buttonMedium.copyWith(
      color: variant == CustomButtonVariant.primary ||
              variant == CustomButtonVariant.secondary
          ? AppColors.white
          : AppColors.navy,
    ),
    CustomButtonSize.large => AppTextStyles.buttonLarge.copyWith(
      color: variant == CustomButtonVariant.primary ||
              variant == CustomButtonVariant.secondary
          ? AppColors.white
          : AppColors.navy,
    ),
  };

  double get _iconSize => switch (size) {
    CustomButtonSize.small => 16,
    CustomButtonSize.medium => 18,
    CustomButtonSize.large => 20,
  };

  double get _iconSpacing => switch (size) {
    CustomButtonSize.small => 6,
    CustomButtonSize.medium => 8,
    CustomButtonSize.large => 10,
  };

  Color? get _iconColor => switch (variant) {
    CustomButtonVariant.primary || CustomButtonVariant.secondary => AppColors.white,
    _ => AppColors.navy,
  };
}

enum IconPosition { start, end }
