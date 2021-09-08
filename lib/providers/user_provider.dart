import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/models_yclients/user_model.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/utils/json_converters.dart';

/// The provider of the unauthorized user.
final Provider<bool> unauthorizedProvider = Provider<bool>((final ref) {
  return ref.watch(userProvider.select((final user) => user == null));
});

/// The provider of a user.
final StateNotifierProvider<OptionalSaveToHiveNotifier<UserModel?, String>,
        UserModel?> userProvider =
    StateNotifierProvider<OptionalSaveToHiveNotifier<UserModel?, String>,
        UserModel?>((final ref) {
  return OptionalSaveToHiveNotifier<UserModel?, String>(
    hive: ref.watch(hiveProvider),
    converter: const OptionalStringConverter(userConverter),
    saveName: 'user',
  );
});
