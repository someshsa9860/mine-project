import 'dart:async';
import 'dart:convert';

import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:gmineapp/services/hive_service.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

import '../bloc/bluetooth_status/bluetooth_status_bloc.dart';
import '../widgets/widgets.dart';

class BluetoothProvider extends ChangeNotifier {
  Map<String, dynamic> settingValues = {};

  init() async {
    await Future.delayed(Duration.zero);
    final pref = HiveService.instance;
    final _jd = pref.get('blue_device');
    if (_jd != null) {
      selectedDevice = (jsonDecode(_jd));
      bluetoothDevice = (selectedDevice!);
    }

    var key = SettingKeys.bluetooth.toString();
    if (pref.get(key) != null) {
      var _dev = (jsonDecode(pref.get(key) ?? ''));

      settingValues[key] = _dev['address'] ?? '';
    }
    key = SettingKeys.paper.toString();
    if (pref.get(key) != null) {
      settingValues[key] = pref.get(key) ?? PaperSize.mm58.value.toString();
    }
    FlutterBluePlus.scanResults.listen((event) async {
      if (event.isNotEmpty) {
        for (var result in event) {
          if (result.device.platformName.isNotEmpty) {
            var item = {
              'name': result.device.platformName,
              'address': result.device.remoteId.str,
              'rssi': result.rssi,
              'type': 0,
              'connected': true,
            };
            if (devices.where((e) => e['address'] == item['address']).isEmpty) {
              devices.add(item);
            }
          }
        }
        devices = devices.toSet().toList();
        notifyListeners();
      }
    });

    scan();

    notifyListeners();
  }

  String get getDatabaseApiName => 'saved_bluetooth_devices';

  void save(e, context) async {
    bluetoothDevice = e;
    notifyListeners();
    selectedDevice = {
      'name': bluetoothDevice == null ? null : bluetoothDevice!['name'],
      'address': bluetoothDevice == null ? null : bluetoothDevice!['address'],
      'type': bluetoothDevice == null ? null : bluetoothDevice!['type'],
      'rssi': bluetoothDevice == null ? null : bluetoothDevice!['rssi'],
      'connected': false,
    };

    final preferences = HiveService.instance;
    preferences.put('blue_device', jsonEncode(selectedDevice));
    // BluetoothConnection.instance.setPrinter(context: context, reset: true);
  }

  void scanIt() {
    try {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 2));
    } catch (e) {
      showSnackBar('please turn on bluetooth');
    }
  }

  List<Map> devices = [];

  bool _isScanning = false;

  bool get isScanning => _isScanning;

  set isScanning(bool value) {
    _isScanning = value;
    notifyListeners();
  }

  scan() async {
    notifyListeners();
    var blu = await Permission.bluetooth.status;
    if (blu.isDenied) {
      await Permission.bluetooth.request();
    }
    var location = await Permission.location.status;
    if (location.isDenied) {
      await Permission.location.request();
    }

    try {
      final res = await Location.instance.serviceEnabled();
      if (!res) {
        Location.instance.requestService().onError((error, stackTrace) {
          return true;
        });
      }
    } catch (e) {
      print('167${e}');
    }

    final res = await Permission.bluetoothScan.status;
    if (!res.isGranted) {
      await Permission.bluetoothScan.request();
    }
    final resConnect = await Permission.bluetoothConnect.status;

    if (!resConnect.isGranted) {
      final res = await Permission.bluetoothConnect.request();
      if (res.isDenied) {
        return;
      }
    }

    var on = await FlutterBluePlus.isOn;
    try {
      if (!on) {
        await FlutterBluePlus.turnOn();
      }
    } catch (e) {
      print(e);
      return;
    }

    final scanning = FlutterBluePlus.isScanning;

    isScanning = FlutterBluePlus.isScanningNow;
    scanning.listen((event) {
      isScanning = event;
    });

    if (isScanning) {
      showSnackBar('Please wait another is scan is in progress');
      return;
    }

    notifyListeners();
    scanIt();
  }

  Map? selectedDevice;

  Map? bluetoothDevice;

  logout() {
    Get.context!.read<BluetoothStatusBloc>().add(BluetoothStatusChanged(false));
    selectedDevice = null;
    bluetoothDevice = null;
    devices.clear();
  }

  var paperSizes = [
    {'key': PaperSize.mm58.value.toString(), 'value': '58 mm Paper'},
    {'key': PaperSize.mm80.value.toString(), 'value': '80 mm Paper'},
  ];

  void addDevice(Map<String, Object> item) {
    devices.add(item);
    notifyListeners();
  }
}
