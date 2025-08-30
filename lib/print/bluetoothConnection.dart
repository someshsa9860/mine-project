import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:gmineapp/services/hive_service.dart';
import 'package:gmineapp/widgets/widgets.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../bloc/bluetooth_status/bluetooth_status_bloc.dart';

class BluetoothConnection {
  static final BluetoothConnection instance =
      BluetoothConnection._constructor();

  BluetoothConnection._constructor();

  Map? get device => getPrinterBlu();

  Future<void> setPrinter() async {
    try {
      final printer = await getPrinterBlu();
      if (printer != null) await connect(printer);
    } catch (e) {
      print('Error in setPrinter: $e');
    }
  }

  getPrinterBlu() {
    final preferences = HiveService.instance;
    try {
      final deviceJson = preferences.get('blue_device');
      if (deviceJson != null) return jsonDecode(deviceJson);
    } catch (e) {
      print('Error in getPrinterBlu: $e');
    }
    return null;
  }

  Future<bool> checkBluetooth() async {
    print('checkBluetooth:$device');
    if (device == null) return false;
    try {
      var connected = Get.context!.read<BluetoothStatusBloc>().state.connected;
      if (connected && device != null) return true;

      final bluetoothPermission = await Permission.bluetooth.status;
      if (bluetoothPermission.isDenied) {
        await Permission.bluetooth.request();
      }

      final locationPermission = await loc.Location().hasPermission();
      if (locationPermission != loc.PermissionStatus.granted) {
        await loc.Location().requestPermission();
      }
      final isBluetoothOn = await FlutterBluePlus.isOn;
      if (!isBluetoothOn) {
        showSnackBar("Please enable Bluetooth.");
        return false;
      }

      return true;
    } catch (e) {
      print('Error in checkBluetooth: $e');
      return false;
    }
  }

  Future<bool> connect(Map? bluetoothDevice) async {
    print('connecting=$bluetoothDevice');
    try {
      if (!await checkBluetooth()) {
        showSnackBar("Please allow Bluetooth and Location permissions.");
        return false;
      }

      if (bluetoothDevice == null) {
        showSnackBar("No Bluetooth device selected.");
        return false;
      }

      var _connectedInt = await Future.any([
        PrintBluetoothThermal.connectionStatus,
        Future.delayed(Duration(seconds: 20), () {
          // showSnackBarToast(message: "Please switch on printer");
          return -1;
        }), // Timeout after 5 sec
      ]);

      print('connectionStatus=$_connectedInt');
      if (_connectedInt == -1) {
        return false;
      }
      var _connected = _connectedInt == true;
      print('_connected=$_connected');

      if (!_connected) {
        _connected = await Future.any([
          PrintBluetoothThermal.connect(
            macPrinterAddress: bluetoothDevice['address'],
          ),
          Future.delayed(Duration(seconds: 30), () {
            // showSnackBarToast(message: "Please switch on printer");
            return false;
          }),
          // Timeout after 5 sec
        ]);
        print('_connected.connect=$_connected');
      }
      Get.context!.read<BluetoothStatusBloc>().add(
        BluetoothStatusChanged(_connected),
      );

      return _connected;
    } catch (e) {
      print('Error in connect: $e');
      showSnackBar("Connection failed: ${e.toString()}");
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      var connected = Get.context!.read<BluetoothStatusBloc>().state.connected;
      if (connected) {
        print("Disconnecting from Bluetooth device...");
        await PrintBluetoothThermal.disconnect;
        connected = false;
      }
      Get.context!.read<BluetoothStatusBloc>().add(
        BluetoothStatusChanged(connected),
      );

      return connected;
    } catch (e) {
      print('Error in disconnect: $e');
      return false;
    }
  }
}
