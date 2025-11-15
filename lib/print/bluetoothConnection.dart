import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:gmineapp/services/hive_service.dart';
import 'package:gmineapp/utils/api.dart';
import 'package:gmineapp/widgets/widgets.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../bloc/bluetooth_status/bluetooth_status_bloc.dart';

class BluetoothConnection {
  static final BluetoothConnection instance =
      BluetoothConnection._constructor();

  BluetoothConnection._constructor();

  // =======================================================
  // LOGGING SYSTEM
  // =======================================================
  final List<String> _logs = [];

  void addLog(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final formatted = "[$timestamp] $message";

    _logs.add(formatted);
    print(formatted);
  }

  List<String> getLogs() => List.from(_logs);

  void clearLogs() {
    _logs.clear();
    addLog("Logs cleared.");
  }

  Future<void> sendLogsToServer() async {
    addLog("Preparing to send logs to backend...");

    try {
      CallApi.instance.postData({'data': _logs}, '/blue-error');

      addLog("Logs successfully sent to backend.");
      clearLogs();
    } catch (e, s) {
      addLog("FAILED to send logs: $e\n$s");
    }
  }

  // =======================================================

  Map? get device => getPrinterBlu();

  Future<void> setPrinter() async {
    addLog('setPrinter() called');
    try {
      final printer = await getPrinterBlu();
      addLog('Saved printer: $printer');

      if (printer != null) {
        addLog("Auto-connecting to saved printer...");
        await connect(printer);
      } else {
        addLog("No saved printer found.");
      }
    } catch (e, s) {
      addLog('Error in setPrinter: $e\n$s');
      await sendLogsToServer();
    }
  }

  getPrinterBlu() {
    addLog('getPrinterBlu() called');
    final preferences = HiveService.instance;
    try {
      final deviceJson = preferences.get('blue_device');
      addLog('Raw stored device JSON: $deviceJson');

      if (deviceJson != null) {
        final parsed = jsonDecode(deviceJson);
        addLog('Decoded device: $parsed');
        return parsed;
      }
    } catch (e, s) {
      addLog('Error in getPrinterBlu: $e\n$s');
      sendLogsToServer();
    }
    return null;
  }

  Future<bool> checkBluetooth() async {
    addLog('checkBluetooth() called');
    addLog('Current saved device: $device');

    if (device == null) {
      addLog('No device saved → returning false');
      return false;
    }

    try {
      var connected = Get.context!.read<BluetoothStatusBloc>().state.connected;
      addLog('Bloc connected: $connected');

      if (connected) {
        addLog('Already connected → true');
        return true;
      }

      addLog("Checking Bluetooth permission...");
      final bluetoothPermission = await Permission.bluetooth.status;
      addLog("Bluetooth permission: $bluetoothPermission");

      if (bluetoothPermission.isDenied) {
        addLog("Requesting Bluetooth permission...");
        await Permission.bluetooth.request();
      }

      addLog("Checking Location permission...");
      final locationPermission = await loc.Location().hasPermission();
      addLog("Location permission: $locationPermission");

      if (locationPermission != loc.PermissionStatus.granted) {
        addLog("Requesting Location permission...");
        await loc.Location().requestPermission();
      }

      final isBluetoothOn = await FlutterBluePlus.isOn;
      addLog("Bluetooth ON: $isBluetoothOn");

      if (!isBluetoothOn) {
        showSnackBar("Please enable Bluetooth.");
        return false;
      }

      return true;
    } catch (e, s) {
      addLog('Error in checkBluetooth: $e\n$s');
      await sendLogsToServer();
      return false;
    }
  }

  Future<bool> connect(Map? bluetoothDevice) async {
    addLog('connect() called with: $bluetoothDevice');

    if (bluetoothDevice == null) {
      addLog('ERROR: bluetoothDevice is null');
      showSnackBar("No Bluetooth device selected.");
      return false;
    }

    // Mark: connecting started
    Get.context!.read<BluetoothStatusBloc>().add(
      BluetoothStatusConnecting(true),
    );

    var blocConnected = Get.context!
        .read<BluetoothStatusBloc>()
        .state
        .connected;
    addLog('Bloc says connected = $blocConnected');

    if (blocConnected) {
      addLog("Already connected → trying thermal reconnect...");
      await PrintBluetoothThermal.connect(
        macPrinterAddress: "${bluetoothDevice['address']}".trim(),
      );

      // mark connecting finished
      Get.context!.read<BluetoothStatusBloc>().add(
        BluetoothStatusConnecting(false),
      );
      return true;
    }

    var device = BluetoothDevice.fromId(bluetoothDevice['address']);

    try {
      addLog("Setting up connection listener...");

      if (!Platform.isWindows) {
        var subscription = device.connectionState.listen((state) {
          addLog('connectionState: $state');

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

        addLog('device.isConnected = ${device.isConnected}');

        if (!device.isConnected) {
          try {
            addLog('device.connect() START');
            await device.connect();
            addLog('device.connect() COMPLETE');
          } catch (e, s) {
            addLog('Error during device.connect: $e\n$s');
            showSnackBar('Connection Issue: $e');
          }
        }
      }

      addLog("Running checkBluetooth()...");
      if (!await checkBluetooth()) {
        addLog("Bluetooth check FAILED");
        showSnackBar("Please allow Bluetooth and Location permissions.");

        // mark failed
        Get.context!.read<BluetoothStatusBloc>().add(
          BluetoothStatusChanged(false),
        );
        Get.context!.read<BluetoothStatusBloc>().add(
          BluetoothStatusConnecting(false),
        );

        await sendLogsToServer();
        return false;
      }

      addLog("Checking PrintBluetoothThermal.connectionStatus...");
      var thermalConnected = await PrintBluetoothThermal.connectionStatus;
      addLog("Thermal connection status: $thermalConnected");

      if (!thermalConnected) {
        addLog("Trying thermal.connect()...");
        thermalConnected = await PrintBluetoothThermal.connect(
          macPrinterAddress: "${bluetoothDevice['address']}".trim(),
        );
        addLog("thermal.connect result: $thermalConnected");
      }

      // if (!thermalConnected) {
      //   thermalConnected = bluetoothDevice['connected'].toString() == 'true';
      // }

      if (!thermalConnected) {
        addLog("Printer still NOT connected.");
        showSnackBar("Please switch on printer");
      }

      // final status
      Get.context!.read<BluetoothStatusBloc>().add(
        BluetoothStatusChanged(thermalConnected),
      );

      addLog("FINAL CONNECTED = $thermalConnected");

      // connecting finished (success or failure)
      Get.context!.read<BluetoothStatusBloc>().add(
        BluetoothStatusConnecting(false),
      );
      if (!thermalConnected) {
        sendLogsToServer();
      }

      return thermalConnected;
    } catch (e, s) {
      addLog('ERROR in connect: $e\n$s');
      showSnackBar("Connection failed: ${e.toString()}");

      // mark both fail + stop connecting
      Get.context!.read<BluetoothStatusBloc>().add(
        BluetoothStatusChanged(false),
      );
      Get.context!.read<BluetoothStatusBloc>().add(
        BluetoothStatusConnecting(false),
      );

      await sendLogsToServer();
      return false;
    }
  }

  Future<bool> disconnect() async {
    addLog('disconnect() called');
    try {
      var connected = Get.context!.read<BluetoothStatusBloc>().state.connected;
      addLog("Currently connected: $connected");

      if (connected) {
        addLog("Disconnecting thermal printer...");
        await PrintBluetoothThermal.disconnect;
        connected = false;
      }

      Get.context!.read<BluetoothStatusBloc>().add(
        BluetoothStatusChanged(connected),
      );

      addLog("Disconnect complete.");
      return connected;
    } catch (e, s) {
      addLog('Error in disconnect: $e\n$s');

      Get.context!.read<BluetoothStatusBloc>().add(
        BluetoothStatusChanged(false),
      );

      await sendLogsToServer();
      return false;
    }
  }
}
