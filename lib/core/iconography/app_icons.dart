import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

export 'package:phosphor_flutter/phosphor_flutter.dart'
    show PhosphorIcons, PhosphorIconsStyle;

abstract final class AppIcons {
  static PhosphorIconData add([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.plus(style);

  static PhosphorIconData arrowRight([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.arrowRight(style);

  static PhosphorIconData check([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.check(style);

  static PhosphorIconData close([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.x(style);

  static PhosphorIconData home([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.house(style);

  static PhosphorIconData package([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.package(style);

  static PhosphorIconData search([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.magnifyingGlass(style);

  static PhosphorIconData user([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.user(style);

  static PhosphorIconData warning([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.warningCircle(style);
}

class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.color,
    this.dimension,
    this.semanticLabel,
    this.size = AppIconSize.md,
  });

  final Color? color;
  final double? dimension;
  final IconData icon;
  final String? semanticLabel;
  final AppIconSize size;

  @override
  Widget build(BuildContext context) {
    return PhosphorIcon(
      icon,
      color: color ?? IconTheme.of(context).color,
      semanticLabel: semanticLabel,
      size: dimension ?? size.value,
    );
  }
}

enum AppIconSize {
  sm(16),
  md(20),
  lg(24),
  xl(32);

  const AppIconSize(this.value);

  final double value;
}
