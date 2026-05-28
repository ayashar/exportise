import 'package:flutter/material.dart';

import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AppDropdownField extends StatefulWidget {
  const AppDropdownField({
    super.key,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.fillColor,
    this.height = 48,
    this.itemHeight = 48,
    this.label,
    this.labelStyle,
    this.menuMaxHeight = 240,
    this.textStyle,
    this.value,
  });

  final Color? fillColor;
  final double height;
  final String hintText;
  final double itemHeight;
  final List<String> items;
  final String? label;
  final TextStyle? labelStyle;
  final double menuMaxHeight;
  final ValueChanged<String?> onChanged;
  final TextStyle? textStyle;
  final String? value;

  @override
  State<AppDropdownField> createState() => _AppDropdownFieldState();
}

class _AppDropdownFieldState extends State<AppDropdownField> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  Size _fieldSize = Size.zero;

  bool get _isOpen => _overlayEntry != null;

  @override
  void dispose() {
    _removeOverlay(notify: false);
    super.dispose();
  }

  void _toggleOverlay() {
    if (_isOpen) {
      _removeOverlay();
      return;
    }
    _showOverlay();
  }

  void _showOverlay() {
    final renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }

    _fieldSize = renderBox.size;
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              offset: Offset(0, _fieldSize.height + 6),
              showWhenUnlinked: false,
              child: Material(
                color: Colors.transparent,
                child: _DropdownMenu(
                  itemHeight: widget.itemHeight,
                  items: widget.items,
                  maxHeight: widget.menuMaxHeight,
                  onSelected: (item) {
                    widget.onChanged(item);
                    _removeOverlay();
                  },
                  selectedValue: widget.value,
                  textStyle: widget.textStyle,
                  width: _fieldSize.width,
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {});
  }

  void _removeOverlay({bool notify = true}) {
    final overlayEntry = _overlayEntry;
    if (overlayEntry == null) {
      return;
    }

    overlayEntry.remove();
    _overlayEntry = null;
    if (notify && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.value != null && widget.value!.isNotEmpty;
    final textStyle =
        widget.textStyle ??
        AppTypography.bodySm.copyWith(color: AppColors.neutral08);
    final labelStyle =
        widget.labelStyle ??
        AppTypography.bodySm.copyWith(
          color: AppColors.neutral08,
          fontWeight: FontWeight.w700,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: labelStyle,
          ),
          const SizedBox(height: 8),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: InkWell(
            key: _fieldKey,
            borderRadius: BorderRadius.circular(8),
            onTap: _toggleOverlay,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              height: widget.height,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: widget.fillColor ?? AppColors.tertiary05,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isOpen ? AppColors.primary04 : AppColors.tertiary06,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A201B11),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hasValue ? widget.value! : widget.hintText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: hasValue
                          ? textStyle
                          : textStyle.copyWith(color: AppColors.system05),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 160),
                    child: AppIcon(
                      AppIcons.dropdown(),
                      color: AppColors.system06,
                      dimension: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownMenu extends StatelessWidget {
  const _DropdownMenu({
    required this.itemHeight,
    required this.items,
    required this.maxHeight,
    required this.onSelected,
    required this.selectedValue,
    required this.textStyle,
    required this.width,
  });

  final double itemHeight;
  final List<String> items;
  final double maxHeight;
  final ValueChanged<String> onSelected;
  final String? selectedValue;
  final TextStyle? textStyle;
  final double width;

  @override
  Widget build(BuildContext context) {
    final style =
        textStyle ?? AppTypography.bodySm.copyWith(color: AppColors.neutral08);

    return Container(
      width: width,
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: AppColors.tertiary05,
        border: Border.all(color: AppColors.neutral06),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12201B11),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in items)
              InkWell(
                onTap: () => onSelected(item),
                child: Container(
                  height: itemHeight,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: item == selectedValue
                      ? AppColors.neutral04
                      : AppColors.tertiary05,
                  child: Text(
                    item,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
