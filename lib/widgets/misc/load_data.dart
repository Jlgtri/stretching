// import 'dart:collection';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:stretching/providers.dart';
// import 'package:stretching/providers/hive_provider.dart';

// /// The widget to authorize a user.
// class SaveData extends ConsumerWidget {
//   /// The widget to authorize a user.
//   const SaveData({final Key? key}) : super(key: key);

//   @override
//   Widget build(final BuildContext context, final WidgetRef ref) {
//     final user = ref.watch(userProvider);
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: <Widget>[
//         DataProgress(
//           studiosProvider,
//           'studios',
//           title: 'Studios',
//         ),
//         DataProgress(
//           trainersProvider,
//           'trainers',
//           title: 'Trainers',
//         ),
//         DataProgress(
//           scheduleProvider,
//           'activities',
//           title: 'Schedule',
//         ),
//         if (user != null) ...<Widget>[
//           DataProgress(
//             userAbonementsProvider,
//             'abonements',
//             title: 'Abonements',
//           ),
//           DataProgress(
//             userRecordsProvider,
//             'records',
//             title: 'Records',
//           )
//         ] else
//           const Center(
//             child: Text('Login to download Abonements and Records'),
//           ),
//       ],
//     );
//   }
// }

// /// The widget that shows a progress for a [progressProvider].
// class DataProgress<T extends Object?> extends HookConsumerWidget {
//   /// The widget that shows a progress for a [progressProvider].
//   const DataProgress(
//     final this.provider,
//     final this.saveName, {
//     required final this.title,
//     final this.downloadText = 'Download',
//     final this.deleteText = 'Remove',
//     final Key? key,
//   }) : super(key: key);

//   /// The progress provider of this widget.
//   final StateNotifierProvider<StateNotifier, T> provider;

//   /// The name of the data saved on device.
//   final String saveName;

//   /// The title of this widget.
//   final String title;

//   /// The text for the download button.
//   final String downloadText;

//   /// The text for the download button.
//   final String deleteText;

//   @override
//   Widget build(final BuildContext context, final WidgetRef ref) {
//     final deletedSaveNames = useState<Set<String>>(<String>{});
//     final isLoading = useState<bool>(false);

//     /// Load the [provider]'s future.
//     Future<T> loadProvider(final FutureProvider<T> provider) async {
//       isLoading.value = true;
//       try {
//         return await ref.read(provider.future);
//       } finally {
//         isLoading.value = false;
//       }
//     }

//     /// Delete the data associated with [saveName].
//     Future<void> deleteProviderData(final String saveName) async {
//       isLoading.value = true;
//       try {
//         deletedSaveNames.value.add(saveName);
//         return await ref.read(hiveProvider).delete(saveName);
//       } finally {
//         isLoading.value = false;
//       }
//     }

//     final isDownloaded = ref.watch(hiveProvider).containsKey(saveName);
//     final isDeleted = deletedSaveNames.value.contains(saveName);

//     return ListTile(
//       contentPadding: const EdgeInsets.all(14),
//       enabled: !isLoading.value,
//       leading: const Text('N/A'),
//       title: isDownloaded
//           ? FutureBuilder(
//               future: ref.watch(provider.future),
//               builder: (final context, final snapshot) {
//                 final data = snapshot.data as Iterable<Object?>?;
//                 return Text(
//                   data == null ? title : '$title (${data.length} items)',
//                 );
//               },
//             )
//           : Text(!isDeleted ? title : '$title (Available on restart)'),
//       trailing: !isDeleted
//           ? isDownloaded
//               ? TextButton(
//                   onPressed: !isLoading.value
//                       ? () => deleteProviderData(saveName)
//                       : null,
//                   child: Text(deleteText),
//                 )
//               : TextButton(
//                   onPressed:
//                       !isLoading.value ? () => loadProvider(provider) : null,
//                   child: Text(downloadText),
//                 )
//           : null,
//     );
//   }

//   @override
//   void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
//     super.debugFillProperties(
//       properties
//         ..add(
//           DiagnosticsProperty<StateProvider<num?>>(
//             'progressProvider',
//             progressProvider,
//           ),
//         )
//         ..add(DiagnosticsProperty<FutureProvider<T>>('provider', provider))
//         ..add(StringProperty('saveName', saveName))
//         ..add(StringProperty('title', title))
//         ..add(StringProperty('downloadText', downloadText))
//         ..add(StringProperty('deleteText', deleteText)),
//     );
//   }
// }
