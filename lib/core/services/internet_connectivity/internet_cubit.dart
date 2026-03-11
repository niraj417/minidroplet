// File: lib/connectivity/internet_cubit.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'internet_state.dart';

class InternetCubit extends Cubit<InternetState> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _connectivitySubscription;

  InternetCubit() : super(InternetInitial()) {
    // This creates a permanent subscription that keeps listening to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      _updateConnectionStatus(connectivityResults);
    } catch (e) {
      emit(InternetDisconnected());
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // If the list is empty or only contains ConnectivityResult.none, emit Disconnected
    if (results.isEmpty || (results.length == 1 && results.first == ConnectivityResult.none)) {
      emit(InternetDisconnected());
    } else {
      // Filter out 'none' results if there are multiple connection types
      final validConnections = results.where((result) => result != ConnectivityResult.none).toList();

      if (validConnections.isEmpty) {
        emit(InternetDisconnected());
      } else {
        // Prioritize connections in this order: wifi > ethernet > mobile
        ConnectivityResult primaryConnection;

        if (validConnections.contains(ConnectivityResult.wifi)) {
          primaryConnection = ConnectivityResult.wifi;
        } else if (validConnections.contains(ConnectivityResult.ethernet)) {
          primaryConnection = ConnectivityResult.ethernet;
        } else if (validConnections.contains(ConnectivityResult.mobile)) {
          primaryConnection = ConnectivityResult.mobile;
        } else {
          // Use the first valid connection if none of the priorities match
          primaryConnection = validConnections.first;
        }

        emit(InternetConnected(primaryConnection));
      }
    }
  }

  String getConnectionType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      default:
        return 'None';
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}