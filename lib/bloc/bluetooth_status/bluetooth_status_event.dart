part of 'bluetooth_status_bloc.dart';

@immutable
sealed class BluetoothStatusEvent {}

class BluetoothStatusChanged extends BluetoothStatusEvent {
  final bool connected;

  BluetoothStatusChanged(this.connected);
}
