part of 'bluetooth_status_bloc.dart';

class BluetoothStatusState {
  final bool connected;
  final bool connecting;

  const BluetoothStatusState({this.connected = false, this.connecting = false});

  BluetoothStatusState clone({bool? connected, bool? connecting}) {
    return BluetoothStatusState(
      connected: connected ?? this.connected,
      connecting: connecting ?? this.connecting,
    );
  }
}
