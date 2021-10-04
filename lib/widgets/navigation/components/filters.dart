import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stretching/models/smstretching/sm_classes_gallery_model.dart';

/// Returns the widget that provides functionality for selecting and
/// deselecting a [ClassCategory].
///
/// [onSelected] is called when category is tapped.
PreferredSizeWidget getSelectorWidget<T extends Object>({
  required final void Function(T, bool value) onSelected,
  required final Iterable<T> values,
  required final bool Function(T) selected,
  required final String Function(T) text,
  final double height = 36,
  final EdgeInsets padding = const EdgeInsets.only(top: 22, bottom: 26),
  final EdgeInsetsGeometry margin = const EdgeInsets.symmetric(horizontal: 4),
}) =>
    PreferredSize(
      preferredSize: Size.fromHeight(height + padding.vertical),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: padding.copyWith(top: 0),
          child: NotificationListener<ScrollNotification>(
            onNotification: (final notification) => true,
            child: SingleChildScrollView(
              primary: false,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: <Widget>[
                  for (final value in values)
                    FilterButton(
                      margin: margin,
                      selected: selected(value),
                      text: text(value),
                      onSelected: (final selectedValue) =>
                          onSelected(value, selectedValue),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

/// The button that checks a filter.
class FilterButton extends StatelessWidget {
  /// The button that checks a filter.
  const FilterButton({
    required final this.selected,
    final this.text = '',
    final this.avatarUrl,
    final this.borderColor,
    final this.backgroundColor = Colors.transparent,
    final this.margin = EdgeInsets.zero,
    final this.onSelected,
    final Key? key,
  })  : assert(avatarUrl != '', 'Link can not be empty'),
        super(key: key);

  /// If this button is selected at the moment.
  final bool selected;

  /// The title of this button.
  final String text;

  /// The link to the photo to put in this button.
  final String? avatarUrl;

  /// The border color of this widget.
  final Color? borderColor;

  /// The color of the background of this widget.
  final Color backgroundColor;

  /// The margin for this button.
  final EdgeInsetsGeometry margin;

  /// The callback to call when this button is selected.
  final void Function(bool value)? onSelected;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: margin,
      child: ChoiceChip(
        elevation: 0,
        pressElevation: 0,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.fromLTRB(avatarUrl == null ? 16 : 0, 2, 16, 2),
        label: Text(text),
        labelStyle: theme.textTheme.headline6?.copyWith(
          color: selected
              ? theme.colorScheme.surface
              : theme.colorScheme.onSurface,
        ),
        labelPadding: avatarUrl != null
            ? const EdgeInsets.only(left: 12)
            : EdgeInsets.zero,
        selected: selected,
        selectedColor: theme.colorScheme.onSurface,
        avatar: avatarUrl != null
            ? CachedNetworkImage(
                imageUrl: avatarUrl!,
                cacheKey: 'x32_$avatarUrl',
                height: 32,
                width: 32,
                memCacheWidth: 32,
                memCacheHeight: 32,
                fadeInDuration: Duration.zero,
                fadeOutDuration: Duration.zero,
                imageBuilder: (final context, final imageProvider) =>
                    CircleAvatar(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.transparent,
                  radius: 16,
                  foregroundImage: imageProvider,
                ),
              )
            : null,
        backgroundColor: backgroundColor,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor ?? theme.colorScheme.onSurface),
          borderRadius: const BorderRadius.all(Radius.circular(30)),
        ),
        onSelected: onSelected?.call,
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<bool>('selected', selected))
        ..add(StringProperty('text', text))
        ..add(StringProperty('avatarUrl', avatarUrl))
        ..add(ColorProperty('borderColor', borderColor))
        ..add(ColorProperty('backgroundColor', backgroundColor))
        ..add(DiagnosticsProperty<EdgeInsetsGeometry>('margin', margin))
        ..add(
          ObjectFlagProperty<void Function(bool value)>.has(
            'onSelected',
            onSelected,
          ),
        ),
    );
  }
}
