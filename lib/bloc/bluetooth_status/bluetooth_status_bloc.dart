import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'bluetooth_status_event.dart';
part 'bluetooth_status_state.dart';

class BluetoothStatusBloc
    extends Bloc<BluetoothStatusEvent, BluetoothStatusState> {
  BluetoothStatusBloc() : super(const BluetoothStatusInitial()) {
    on<BluetoothStatusChanged>((event, emit) {
      emit(BluetoothStatusInitial(connected: event.connected));
    });
  }
}
