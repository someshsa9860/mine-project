part of 'bluetooth_status_bloc.dart';

@immutable
sealed class BluetoothStatusState {
  final bool connected;
  const BluetoothStatusState({this.connected = false});
}

final class BluetoothStatusInitial extends BluetoothStatusState {
  const BluetoothStatusInitial({bool connected = false})
      : super(connected: connected);

  BluetoothStatusInitial copyWith({required bool connected}) {
    return BluetoothStatusInitial(connected: connected);
  }
}
