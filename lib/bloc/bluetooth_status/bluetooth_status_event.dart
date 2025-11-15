part of 'bluetooth_status_bloc.dart';

@immutable
sealed class BluetoothStatusEvent {}

class BluetoothStatusChanged extends BluetoothStatusEvent {
  final bool connected;

  BluetoothStatusChanged(this.connected);
}

class BluetoothStatusConnecting extends BluetoothStatusEvent {
  final bool connecting;

  BluetoothStatusConnecting(this.connecting);
}
