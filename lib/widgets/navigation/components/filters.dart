import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/models_smstretching/sm_studio_model.dart';
import 'package:stretching/models_smstretching/sm_trainer_model.dart';
import 'package:stretching/utils/enum_to_string.dart';

/// The categories of [SMTrainerModel] and [SMStudioModel].
enum ClassCategory {
  trx,
  stretching,
  barreSignature,
  pilates,
  barre20,
  hotStretching,
  hotBarre,
  hotPilates,
  danceWorkout,
  fitBoxing
}

/// The extra data provided for [ClassCategory].
extension CategoriesData on ClassCategory {
  /// The translation of this category.
  String get translation => '${TR.category}.${enumToString(this)}'.tr();
}

/// The extra data provided for [ClassCategory].
extension IterableCategoriesData on Iterable<ClassCategory> {
  /// Returns the widget that provides functionality for selecting and
  /// deselecting a [ClassCategory].
  ///
  /// [onSelected] is called when category is tapped.
  PreferredSizeWidget getSelectorWidget(
    final ThemeData theme,
    final void Function(ClassCategory category, bool value) onSelected, {
    final double height = 36,
    final EdgeInsets padding = const EdgeInsets.symmetric(vertical: 24),
  }) {
    Widget filterButton(final ClassCategory category) {
      final isActive = contains(category);
      return ChoiceChip(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        label: Text(
          category.translation,
          style: theme.textTheme.bodyText2?.copyWith(
            color: isActive
                ? theme.colorScheme.surface
                : theme.colorScheme.onSurface,
          ),
        ),
        selected: isActive,
        selectedColor: theme.colorScheme.onSurface,
        elevation: 4,
        pressElevation: 0,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          side: const BorderSide(),
          borderRadius: BorderRadius.circular(30),
        ),
        onSelected: (final value) => onSelected(category, value),
      );
    }

    return PreferredSize(
      preferredSize: Size.fromHeight(height + padding.vertical),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: padding.copyWith(top: 0),
          child: NotificationListener<ScrollNotification>(
            onNotification: (final notification) => true,
            child: SingleChildScrollView(
              controller: ScrollController(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: <Widget>[
                  for (final category in ClassCategory.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: filterButton(category),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
