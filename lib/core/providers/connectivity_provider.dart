import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits `true` when a network interface is available, `false` otherwise.
/// Checks the initial state immediately without waiting for the stream.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  // Emit the current state immediately rather than waiting for a change event.
  final initial = await connectivity.checkConnectivity();
  yield initial.any((r) => r != ConnectivityResult.none);
  // Emit subsequent connectivity changes.
  yield* connectivity.onConnectivityChanged.map(
    (results) => results.any((r) => r != ConnectivityResult.none),
  );
});
