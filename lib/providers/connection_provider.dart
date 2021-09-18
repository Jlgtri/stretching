// import 'dart:io';

// import 'package:connectivity/connectivity.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// /// The current device's connection provider.
// final StateNotifierProvider<ConnectionNotifier, bool?> connectionProvider =
//     StateNotifierProvider((final ref) => ConnectionNotifier());

// /// The notifier for checking device connection.
// class ConnectionNotifier extends StateNotifier<bool?> {
//   /// The notifier for checking device connection.
//   ConnectionNotifier() : super(null) {
//     /// Check the current connection type. If there is no connection, skip.
//     Connectivity().onConnectivityChanged.listen((final result) async {
//       // Delay needed for properly checking device internet status.
//       await Future<void>.delayed(const Duration(milliseconds: 100));
//       return updateConnection(skip: result == ConnectivityResult.none);
//     });
//   }

//   /// The test to see if there is actually an active connection.
//   Future<void> updateConnection({final bool skip = false}) async {
//     var hasConnection = false;
//     try {
//       if (!skip) {
//         final result = await InternetAddress.lookup(
//           '8.8.8.8',
//           type: InternetAddressType.IPv4,
//         );
//         hasConnection = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
//       }
//     } on SocketException catch (_) {
//     } finally {
//       if (state != hasConnection) {
//         state = hasConnection;
//       }
//     }
//   }
// }
