import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool transparent;
  final bool canPop;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Widget? child;
  final double height;

  const CustomHeader({
    super.key,
    this.title,
    this.transparent = false,
    this.canPop = false,
    this.onBack,
    this.actions,
    this.child,
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final bgColor = transparent ? Colors.transparent : AppColors.navy;
    final canGoBack = canPop || Navigator.canPop(context);

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: canGoBack
          ? GestureDetector(
              onTap: onBack ?? () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.gold,
                  size: 18,
                ),
              ),
            )
          : const SizedBox.shrink(),
      title:
          child ??
          (title != null
              ? Text(
                  title!,
                  style: AppTextStyles.h6.copyWith(color: AppColors.white),
                )
              : null),
      actions: actions,
      iconTheme: const IconThemeData(color: AppColors.gold),
      actionsIconTheme: const IconThemeData(color: AppColors.gold),
    );
  }
}
