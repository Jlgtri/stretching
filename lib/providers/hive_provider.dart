import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meta/meta.dart';
import 'package:stretching/utils/json_converters.dart';

/// The provider of a Hive database.
final Provider<Box<String>> hiveProvider = Provider<Box<String>>((final ref) {
  throw Exception('Hive was not initialised.');
});

/// The interface to [save] the data.
abstract class SaveDataInterface<T extends Object?, S extends Object?> {
  /// The interface to [save] the data.
  const SaveDataInterface({
    required final this.saveName,
    required final this.converter,
  });

  /// The name of this iterable to save in the database.
  final String saveName;

  /// The converter to serialize the item.
  final JsonConverter<T, S> converter;

  /// Saves the data to the database.
  FutureOr<void> save();
}

/// The notifier that automatically save the [state] to the [hive] database.
class OptionalSaveToHiveNotifier<T extends Object?, S extends Object?>
    extends StateNotifier<T?> implements SaveDataInterface<T, S> {
  /// The notifier that returns a default value from the [hive] database.
  ///
  /// If value does not exist, returns a [defaultValue].
  OptionalSaveToHiveNotifier({
    required final this.hive,
    required final this.saveName,
    required final this.converter,
    final T? defaultValue,
  }) : super(
          hive.containsKey(saveName)
              // ignore: null_check_on_nullable_type_parameter
              ? converter.fromJson(hive.get(saveName)!)
              : defaultValue,
        );

  /// The reference to the Hive database.
  final Box<S> hive;

  @override
  final String saveName;

  @override
  final JsonConverter<T, S> converter;

  @override
  Future<void> save() async {
    final state = this.state;
    if (state != null) {
      await hive.put(saveName, converter.toJson(state));
    }
  }

  @override
  set state(final T? value) {
    super.state = value;
    save();
  }

  @override
  T? get state => super.state;

  /// Updates the current [state] and saves it's value to the [hive] database.
  @mustCallSuper
  Future<void> setStateAsync(final T value) async {
    super.state = value;
    await save();
  }
}

/// The notifier that automatically save the [state] to the [hive] database.
class SaveToHiveNotifier<T extends Object, S extends Object>
    extends StateNotifier<T> implements SaveDataInterface<T, S> {
  /// The notifier that returns a default value from the [hive] database.
  ///
  /// If value does not exist, returns a [defaultValue].
  SaveToHiveNotifier({
    required final this.hive,
    required final this.saveName,
    required final this.converter,
    required final T defaultValue,
  }) : super(
          hive.containsKey(saveName)
              ? converter.fromJson(hive.get(saveName)!)
              : defaultValue,
        );

  /// The reference to the Hive database.
  final Box<S> hive;

  @override
  final String saveName;

  @override
  final JsonConverter<T, S> converter;

  @override
  Future<void> save() => hive.put(saveName, converter.toJson(state));

  @override
  set state(final T value) {
    super.state = value;
    save();
  }

  @override
  T get state => super.state;

  /// Updates the current [state] and saves it's value to the [hive] database.
  @mustCallSuper
  Future<void> setStateAsync(final T value) async {
    super.state = value;
    await save();
  }
}

mixin _IterableMixin<T extends Object, S extends Object>
    on SaveToHiveNotifier<Iterable<T>, S> {
  /// Add a checked permission to this notifier.
  Future<void> add(final T item) async {
    await setStateAsync(<T>[...state, item]);
  }

  /// Remove a checked permission from this notifier.
  Future<void> remove(final T item) async {
    await setStateAsync(<T>[
      for (final _item in state)
        if (_item != item) _item
    ]);
  }
}

/// The notifier that automatically saves the iterable to the database.
class SaveToHiveIterableNotifier<T extends Object,
        S extends Object> = SaveToHiveNotifier<Iterable<T>, S>
    with _IterableMixin<T, S>;
