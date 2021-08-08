import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stretching/providers.dart';

/// The widget to authorize a user.
class SaveData extends ConsumerWidget {
  /// The widget to authorize a user.
  const SaveData({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DataProgress(
          trainersProvider,
          trainersProgressProvider,
          'trainers',
          title: 'Trainers',
        ),
        DataProgress(
          scheduleProvider,
          scheduleProgressProvider,
          'activities',
          title: 'Schedule',
        ),
        DataProgress(
          studiosProvider,
          studiosProgressProvider,
          'studios',
          title: 'Studios',
        ),
      ],
    );
  }
}

/// The widget that shows a progress for a [progressProvider].
class DataProgress<T extends Object> extends ConsumerWidget {
  /// The widget that shows a progress for a [progressProvider].
  const DataProgress(
    final this.provider,
    final this.progressProvider,
    final this.saveName, {
    required final this.title,
    final this.downloadText = 'Download',
    final this.deleteText = 'Remove',
    final Key? key,
  }) : super(key: key);

  /// The progress provider of this widget.
  final FutureProvider<T> provider;

  /// The progress provider of this widget.
  final StateProvider<num?> progressProvider;

  /// The name of the data saved on device.
  final String saveName;

  /// The title of this widget.
  final String title;

  /// The text for the download button.
  final String downloadText;

  /// The text for the download button.
  final String deleteText;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return ViewModelBuilder<DataProgressViewModel<T>>.reactive(
      disposeViewModel: false,
      fireOnModelReadyOnce: true,
      initialiseSpecialViewModelsOnce: true,
      viewModelBuilder: () => DataProgressViewModel(ref),
      builder: (final context, final viewModel, final child) {
        final progress = ref.watch(progressProvider).state;
        final isDownloaded = viewModel.hasProviderData(saveName);
        final isDeleted = viewModel.isDeleted(saveName);
        return ListTile(
          contentPadding: const EdgeInsets.all(14),
          enabled: !viewModel.isBusy,
          leading: Text(
            progress == null ? 'N/A' : '${progress.toStringAsFixed(2)}%',
          ),
          title: isDownloaded
              ? FutureBuilder(
                  future: ref.watch(provider.future),
                  builder: (final context, final snapshot) {
                    return !snapshot.hasData
                        ? Text(title)
                        : Text(
                            '$title '
                            '(${(snapshot.data! as Iterable).length} items)',
                          );
                  },
                )
              : isDeleted
                  ? Text('$title (Available on restart)')
                  : Text(title),
          trailing: !isDeleted
              ? isDownloaded
                  ? TextButton(
                      onPressed: !viewModel.isBusy
                          ? () => viewModel.deleteProviderData(saveName)
                          : null,
                      child: Text(deleteText),
                    )
                  : TextButton(
                      onPressed: !viewModel.isBusy
                          ? () => viewModel.loadProvider(provider)
                          : null,
                      child: Text(downloadText),
                    )
              : null,
        );
      },
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(
          DiagnosticsProperty<StateProvider<num?>>(
            'progressProvider',
            progressProvider,
          ),
        )
        ..add(DiagnosticsProperty<FutureProvider<T>>('provider', provider))
        ..add(StringProperty('saveName', saveName))
        ..add(StringProperty('title', title))
        ..add(StringProperty('downloadText', downloadText))
        ..add(StringProperty('deleteText', deleteText)),
    );
  }
}

/// The view model for [DataProgress].
class DataProgressViewModel<T extends Object?> extends BaseViewModel {
  /// The view model for [DataProgress].
  DataProgressViewModel(final this.ref) {
    _hive = ref.watch(hiveProvider);
  }

  late final Box<String> _hive;

  final Set<String> _deletedSaveNames = <String>{};

  /// The reference to the Riverpod.
  final WidgetRef ref;

  /// Load the [provider]'s future.
  Future<T> loadProvider(final FutureProvider<T> provider) {
    return runBusyFuture(ref.read(provider.future), throwException: true);
  }

  /// Delete the data within the [saveName].
  Future<void> saveProviderData(final String saveName, final String data) {
    return runBusyFuture(
      _hive.put(saveName, data),
      throwException: true,
    );
  }

  /// Delete the data associated with [saveName].
  Future<void> deleteProviderData(final String saveName) {
    _deletedSaveNames.add(saveName);
    return runBusyFuture(_hive.delete(saveName), throwException: true);
  }

  /// Delete the data within the [saveName].
  bool hasProviderData(final String saveName) => _hive.containsKey(saveName);

  /// If the data with the [saveName] was already deleted.
  bool isDeleted(final String saveName) => _deletedSaveNames.contains(saveName);
}
