import 'dart:convert';
import 'dart:io';

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
    // return true;
    var directBluePrint = HiveService.instance.get('directBluePrint');
    try {
      print('connecting=$bluetoothDevice');

      if (!Platform.isWindows) {
        var device = BluetoothDevice.fromId(bluetoothDevice?['address']);
        var subscription = device.connectionState.listen((
          BluetoothConnectionState state,
        ) async {
          print('connectionState:${state}');
          if (state == BluetoothConnectionState.disconnected) {
            Get.context!.read<BluetoothStatusBloc>().add(
              BluetoothStatusChanged(false),
            );
          }
          if (state == BluetoothConnectionState.connected) {
            Get.context!.read<BluetoothStatusBloc>().add(
              BluetoothStatusChanged(true),
            );
          }
        });

        device.cancelWhenDisconnected(subscription, delayed: true, next: true);
        print('device.isConnected:${device.isConnected}');

        if (!device.isConnected) {
          await device.connect();
        }
      }

      if (!await checkBluetooth()) {
        showSnackBar("Please allow Bluetooth and Location permissions.");
        return false;
      }

      if (bluetoothDevice == null) {
        showSnackBar("No Bluetooth device selected.");
        return false;
      }

      var connected = await PrintBluetoothThermal.connectionStatus;

      if (!connected) {
        connected = await PrintBluetoothThermal.connect(
          macPrinterAddress: "${bluetoothDevice['address']}".trim(),
        );
      }
      if (!connected) {
        connected = bluetoothDevice['connected'].toString() == 'true';
      }
      if (!connected) {
        showSnackBar("Please switch on printer");
      }

      Get.context!.read<BluetoothStatusBloc>().add(
        BluetoothStatusChanged(connected || directBluePrint),
      );

      return connected;
    } catch (e) {
      print('Error in connect: $e');
      showSnackBar("Connection failed: ${e.toString()}");
      Get.context!.read<BluetoothStatusBloc>().add(
        BluetoothStatusChanged(directBluePrint),
      );
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
