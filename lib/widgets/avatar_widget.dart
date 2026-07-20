import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

enum AvatarSize { small, medium, large }

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AvatarSize.medium,
    this.showOnlineIndicator = false,
    this.borderColor,
    this.onTap,
  });

  final String? imageUrl;
  final String? name;
  final AvatarSize size;
  final bool showOnlineIndicator;
  final Color? borderColor;
  final VoidCallback? onTap;

  double get _dimension => switch (size) {
    AvatarSize.small => 36,
    AvatarSize.medium => 48,
    AvatarSize.large => 72,
  };

  double get _onlineIndicatorSize => switch (size) {
    AvatarSize.small => 10,
    AvatarSize.medium => 12,
    AvatarSize.large => 16,
  };

  double get _onlineBorderWidth => switch (size) {
    AvatarSize.small => 2,
    AvatarSize.medium => 2.5,
    AvatarSize.large => 3,
  };

  double get _fontSize => switch (size) {
    AvatarSize.small => 12,
    AvatarSize.medium => 16,
    AvatarSize.large => 24,
  };

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: _dimension,
      height: _dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.navy.withValues(alpha: 0.1),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 2)
            : null,
      ),
      child: ClipOval(child: _buildContent()),
    );

    final stack = Stack(
      clipBehavior: Clip.none,
      children: [avatar, if (showOnlineIndicator) _buildOnlineIndicator()],
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: stack);
    }
    return stack;
  }

  Widget _buildContent() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: _dimension,
        height: _dimension,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitials(),
      );
    }
    return _buildInitials();
  }

  Widget _buildInitials() {
    return Container(
      width: _dimension,
      height: _dimension,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.navyGradient,
      ),
      child: Center(
        child: Text(
          _initials,
          style: AppTextStyles.bodyMediumBold.copyWith(
            fontSize: _fontSize,
            color: AppColors.gold,
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineIndicator() {
    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        width: _onlineIndicatorSize,
        height: _onlineIndicatorSize,
        decoration: BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: _onlineBorderWidth),
        ),
      ),
    );
  }
}
