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

  static PhosphorIconData bag([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.bag(style);

  static PhosphorIconData bell([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.bell(style);

  static PhosphorIconData brain([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.brain(style);

  static PhosphorIconData check([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.check(style);

  static PhosphorIconData chat([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.chatCenteredText(style);

  static PhosphorIconData close([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.x(style);

  static PhosphorIconData currency([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.currencyDollar(style);

  static PhosphorIconData document([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.fileText(style);

  static PhosphorIconData edit([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.pencilSimple(style);

  static PhosphorIconData eye([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.eye(style);

  static PhosphorIconData filePdf([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.filePdf(style);

  static PhosphorIconData download([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.downloadSimple(style);

  static PhosphorIconData dropdown([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.caretDown(style);

  static PhosphorIconData gear([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.gearSix(style);

  static PhosphorIconData home([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.house(style);

  static PhosphorIconData package([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.package(style);

  static PhosphorIconData search([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.magnifyingGlass(style);

  static PhosphorIconData season([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.calendarCheck(style);

  static PhosphorIconData sparkle([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.sparkle(style);

  static PhosphorIconData truck([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.truck(style);

  static PhosphorIconData trendUp([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.chartLineUp(style);

  static PhosphorIconData up([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.caretUp(style);

  static PhosphorIconData refresh([
    PhosphorIconsStyle style = PhosphorIconsStyle.regular,
  ]) => PhosphorIcons.arrowClockwise(style);

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
