import 'package:connectivity_plus/connectivity_plus.dart';

abstract class InternetState {}

class InternetInitial extends InternetState {}

class InternetConnected extends InternetState {
  final ConnectivityResult connectionType;

  InternetConnected(this.connectionType);
}

class InternetDisconnected extends InternetState {}