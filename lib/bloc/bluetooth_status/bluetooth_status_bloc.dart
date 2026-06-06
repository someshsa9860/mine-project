import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'bluetooth_status_event.dart';
part 'bluetooth_status_state.dart';

class BluetoothStatusBloc
    extends Bloc<BluetoothStatusEvent, BluetoothStatusState> {
  BluetoothStatusBloc() : super(const BluetoothStatusState()) {
    on<BluetoothStatusChanged>((event, emit) {
      emit(state.clone(connected: event.connected));
    });
    on<BluetoothStatusConnecting>((event, emit) {
      emit(state.clone(connecting: event.connecting));
    });
  }
}
