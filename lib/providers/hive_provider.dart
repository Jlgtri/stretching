import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stretching/utils/json_converters.dart';

/// The provider of a [Hive] database.
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
  final JsonConverter<T?, S?> converter;

  /// Saves the data to the database.
  FutureOr<void> save();
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
    final T? Function(T)? onValueCreated,
  }) : super(
          () {
            var value = defaultValue;
            if (hive.containsKey(saveName)) {
              value = converter.fromJson(hive.get(saveName)!);
            }
            return onValueCreated?.call(value) ?? value;
          }(),
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
  set state(final T state) {
    try {
      super.state = state;
    } finally {
      save();
    }
  }

  @override
  T get state => super.state;

  /// Updates the current [state] and saves it's value to the [hive] database.
  Future<void> setStateAsync(final T state) async {
    try {
      super.state = state;
    } finally {
      await save();
    }
  }
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
    final T? Function(T?)? onValueCreated,
  }) : super(
          () {
            final value =
                converter.fromJson(hive.get(saveName)) ?? defaultValue;
            return onValueCreated?.call(value) ?? value;
          }(),
        );

  /// The reference to the Hive database.
  final Box<S> hive;

  @override
  final String saveName;

  @override
  final JsonConverter<T?, S?> converter;

  @override
  Future<void> save() async {
    final savedData = converter.toJson(state);
    savedData != null
        ? await hive.put(saveName, savedData)
        : await hive.delete(saveName);
  }

  @override
  set state(final T? state) {
    try {
      super.state = state;
    } finally {
      save();
    }
  }

  @override
  T? get state => super.state;

  /// Updates the current [state] and saves it's value to the [hive] database.
  Future<void> setStateAsync(final T state) async {
    try {
      super.state = state;
    } finally {
      await save();
    }
  }
}

/// The notifier that automatically save the [state] to the [hive] database.
class SaveToHiveIterableNotifier<T extends Object, S extends Object>
    extends StateNotifier<Iterable<T>>
    implements SaveDataInterface<Iterable<T>, S> {
  /// The notifier that returns a default value from the [hive] database.
  ///
  /// If value does not exist, returns a [defaultValue].
  SaveToHiveIterableNotifier({
    required final this.hive,
    required final this.saveName,
    required final this.converter,
    required final Iterable<T> defaultValue,
    final Iterable<T>? Function(Iterable<T>)? onValueCreated,
  }) : super(
          () {
            var value = defaultValue;
            if (hive.containsKey(saveName)) {
              value = converter.fromJson(hive.get(saveName)!).cast<T>();
            }
            return onValueCreated?.call(value) ?? value;
          }(),
        );

  /// The reference to the [Hive] database.
  final Box<S> hive;

  @override
  final String saveName;

  @override
  final JsonConverter<Iterable<T>, S> converter;

  @override
  Future<void> save() => hive.put(saveName, converter.toJson(state));

  @override
  set state(final Iterable<T> state) {
    try {
      super.state = state;
    } finally {
      save();
    }
  }

  @override
  Iterable<T> get state => super.state;

  /// Updates the current [state] and saves it's value to the [hive] database.
  Future<void> setStateAsync(final Iterable<T> state) async {
    try {
      super.state = state;
    } finally {
      await save();
    }
  }

  /// Add an [item] to this notifier.
  Future<void> add(final T item) async {
    await setStateAsync(<T>[...state, item]);
  }

  /// Add [items] to this notifier.
  Future<void> addAll(final Iterable<T> items) async {
    await setStateAsync(<T>[...state, ...items]);
  }

  /// Remove an [item] from this notifier.
  Future<void> remove(final T item) async {
    await setStateAsync(<T>[
      for (final _item in state)
        if (_item != item) _item
    ]);
  }

  /// Remove everything from this notifier.
  Future<void> clear() => setStateAsync(Iterable<T>.empty());
}
