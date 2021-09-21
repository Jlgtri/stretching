import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stretching/models_smstretching/sm_classes_gallery_model.dart';

/// Returns the widget that provides functionality for selecting and
/// deselecting a [ClassCategory].
///
/// [onSelected] is called when category is tapped.
PreferredSizeWidget getSelectorWidget<T extends Object>({
  required final ThemeData theme,
  required final void Function(T, bool value) onSelected,
  required final Iterable<T> values,
  required final bool Function(T) selected,
  required final String Function(T) text,
  final double height = 36,
  final EdgeInsets padding = const EdgeInsets.symmetric(vertical: 24),
}) {
  return PreferredSize(
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterButton(
                      selected: selected(value),
                      text: text(value),
                      onSelected: (final selectedValue) =>
                          onSelected(value, selectedValue),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

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
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        label: Text(
          text,
          style: theme.textTheme.headline6?.copyWith(
            color: selected
                ? theme.colorScheme.surface
                : theme.colorScheme.onSurface,
          ),
        ),
        selected: selected,
        selectedColor: theme.colorScheme.onSurface,
        elevation: 4,
        pressElevation: 0,
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
                imageBuilder: (final context, final imageProvider) {
                  return CircleAvatar(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.transparent,
                    radius: 16,
                    foregroundImage: imageProvider,
                  );
                },
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
