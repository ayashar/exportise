import 'package:flutter/material.dart';

import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isFullWidth = false,
    this.isLoading = false,
    this.leadingIcon,
    this.size = AppButtonSize.md,
    this.trailingIcon,
    this.variant = AppButtonVariant.primary,
  });

  final bool isFullWidth;
  final bool isLoading;
  final String label;
  final IconData? leadingIcon;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final IconData? trailingIcon;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    final palette = _AppButtonPalette.resolve(variant, isDisabled);
    final metrics = size.metrics;

    final button = TextButton(
      onPressed: isLoading ? null : onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(palette.background),
        foregroundColor: WidgetStatePropertyAll(palette.foreground),
        minimumSize: WidgetStatePropertyAll(Size(0, metrics.height)),
        overlayColor: WidgetStatePropertyAll(palette.overlay),
        padding: WidgetStatePropertyAll(metrics.padding),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        side: WidgetStatePropertyAll(palette.border),
        textStyle: WidgetStatePropertyAll(size.textStyle),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: _AppButtonContent(
        foregroundColor: palette.foreground,
        iconSize: metrics.iconSize,
        isLoading: isLoading,
        label: label,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
      ),
    );

    if (!isFullWidth) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }
}

class _AppButtonContent extends StatelessWidget {
  const _AppButtonContent({
    required this.foregroundColor,
    required this.iconSize,
    required this.isLoading,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
  });

  final Color foregroundColor;
  final double iconSize;
  final bool isLoading;
  final String label;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      if (isLoading)
        SizedBox.square(
          dimension: iconSize,
          child: CircularProgressIndicator(
            color: foregroundColor,
            strokeWidth: 2,
          ),
        )
      else if (leadingIcon != null)
        AppIcon(leadingIcon!, color: foregroundColor, dimension: iconSize),
      Flexible(
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      if (trailingIcon != null && !isLoading)
        AppIcon(trailingIcon!, color: foregroundColor, dimension: iconSize),
    ];

    return IconTheme.merge(
      data: IconThemeData(color: foregroundColor, size: iconSize),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: children,
      ),
    );
  }
}

enum AppButtonVariant { primary, secondary, outline, ghost, danger }

enum AppButtonSize { sm, md, lg }

extension on AppButtonSize {
  _AppButtonMetrics get metrics {
    return switch (this) {
      AppButtonSize.sm => const _AppButtonMetrics.sm(),
      AppButtonSize.md => const _AppButtonMetrics.md(),
      AppButtonSize.lg => const _AppButtonMetrics.lg(),
    };
  }

  TextStyle get textStyle {
    return switch (this) {
      AppButtonSize.sm => AppTypography.bodySm.copyWith(
        fontWeight: FontWeight.w600,
      ),
      AppButtonSize.md => AppTypography.bodySm.copyWith(
        fontWeight: FontWeight.w600,
      ),
      AppButtonSize.lg => AppTypography.bodyMd.copyWith(
        fontWeight: FontWeight.w600,
      ),
    };
  }
}

class _AppButtonMetrics {
  const _AppButtonMetrics({
    required this.height,
    required this.iconSize,
    required this.padding,
  });

  const _AppButtonMetrics.sm()
    : this(
        height: 36,
        iconSize: 16,
        padding: const EdgeInsets.symmetric(horizontal: 14),
      );

  const _AppButtonMetrics.md()
    : this(
        height: 44,
        iconSize: 20,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      );

  const _AppButtonMetrics.lg()
    : this(
        height: 52,
        iconSize: 20,
        padding: const EdgeInsets.symmetric(horizontal: 18),
      );

  final double height;
  final double iconSize;
  final EdgeInsetsGeometry padding;
}

class _AppButtonPalette {
  const _AppButtonPalette({
    required this.background,
    required this.foreground,
    required this.overlay,
    this.border = BorderSide.none,
  });

  factory _AppButtonPalette.resolve(AppButtonVariant variant, bool isDisabled) {
    if (isDisabled) {
      return const _AppButtonPalette(
        background: AppColors.system02,
        foreground: AppColors.system06,
        overlay: Colors.transparent,
      );
    }

    return switch (variant) {
      AppButtonVariant.primary => const _AppButtonPalette(
        background: AppColors.primary04,
        foreground: AppColors.primary08,
        overlay: AppColors.primary02,
      ),
      AppButtonVariant.secondary => const _AppButtonPalette(
        background: AppColors.secondary04,
        foreground: AppColors.secondary06,
        overlay: AppColors.secondary01,
      ),
      AppButtonVariant.outline => const _AppButtonPalette(
        background: Colors.transparent,
        border: BorderSide(color: AppColors.neutral06),
        foreground: AppColors.primary08,
        overlay: AppColors.neutral03,
      ),
      AppButtonVariant.ghost => const _AppButtonPalette(
        background: Colors.transparent,
        foreground: AppColors.primary08,
        overlay: AppColors.neutral03,
      ),
      AppButtonVariant.danger => const _AppButtonPalette(
        background: AppColors.error02,
        foreground: AppColors.system01,
        overlay: AppColors.error03,
      ),
    };
  }

  final Color background;
  final BorderSide border;
  final Color foreground;
  final Color overlay;
}
