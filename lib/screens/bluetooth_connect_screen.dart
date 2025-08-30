import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gmineapp/utils/loader.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../print/bluetoot_print_test.dart';
import '../../print/bluetoothConnection.dart';
import '../bloc/bluetooth_status/bluetooth_status_bloc.dart';
import '../providers/blutooth_provider.dart';
import '../widgets/widgets.dart';

///Language part is done on 14March2025

double calculateDistance(dynamic rssi, {int txPower = -59}) {
  // Convert RSSI to int if it's a string
  if (rssi == null) return -1;
  if (rssi is String) {
    rssi = int.tryParse(rssi);
    if (rssi == null) return -1;
  }

  if (rssi is! int) return -1; // Ensure it's an integer

  int n = 2; // Environmental factor (2 for free space)
  return pow(10, (txPower - rssi) / (10 * n)).toDouble();
}

class BluetoothConnectScreen extends StatefulWidget {
  static const routeName = '/bluetooth-screen';

  const BluetoothConnectScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BluetoothConnectScreenState();
  }
}

class BluetoothConnectScreenState extends State<BluetoothConnectScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        // leading: const TextBackButton(),
        title: Text("Bluetooth Printer Setting"),
      ),
      body: SafeArea(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: BlocBuilder<BluetoothStatusBloc, BluetoothStatusState>(
            builder: (context, state) {
              var connected = state.connected;
              return Consumer<BluetoothProvider>(
                builder: (context, data, _) {
                  var devices = data.devices.where(
                    (element) =>
                        (element['address'] != null) &&
                        (element['name'] != null),
                  );

                  devices = devices
                      .map((e) {
                        var distance = calculateDistance(e['rssi']);
                        var distanceText = distance == -1
                            ? '-'
                            : '${distance.toStringAsFixed(2)} m';

                        e['distance'] = distance;
                        e['distanceText'] = distanceText;
                        return e;
                      })
                      .toList()
                      .sortedBy(
                        (a, b) => ((a['distance']) as double).compareTo(
                          b['distance'],
                        ),
                      );

                  String? address = data.bluetoothDevice?['address'];
                  return Column(
                    children: [
                      Column(
                        children: [
                          Text(
                            '${"Status"}: ${connected ? "connected" : "disconnect"}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${address ?? ''}'),
                        ],
                      ).p8().p8(),
                      Expanded(
                        child: Visibility(
                          visible: (!connected || address == null),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: devices.isEmpty
                                ? Center(
                                    child: Text("Bluetooth Device Not Found"),
                                  )
                                : ListView(
                                    children: devices.map((e) {
                                      return ListTile(
                                        onTap: () {
                                          data.save(e, context);
                                        },
                                        title: Text(e['name'] ?? 'Unnamed'),
                                        subtitle: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(e['address'] ?? 'Unnamed'),
                                            Text('${e['distanceText']}'),
                                          ],
                                        ),
                                        trailing:
                                            data.bluetoothDevice != null &&
                                                (address == e['address'])
                                            ? const Icon(Icons.check_box)
                                            : const Icon(
                                                Icons
                                                    .check_box_outline_blank_outlined,
                                              ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                        ),
                      ),
                      if (!connected || address == null)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              data.scan();
                            },
                            child: Text("Scan"),
                          ),
                        ),
                      if (!connected && address != null)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              Loader.instance.show();

                              await BluetoothConnection.instance.connect(
                                data.bluetoothDevice,
                              );
                              Loader.instance.hide();

                              setState(() {});
                            },
                            child: Text("Connect Printer"),
                          ),
                        ),
                      if (connected)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  BluetoothConnection.instance
                                      .disconnect()
                                      .then((value) {
                                        setState(() {});
                                      });
                                },
                                child: Text("Disconnect"),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  printTest();
                                  // Future.delayed(Duration(seconds: 1))
                                  //     .then((v) {
                                  //   printTest();
                                  // });
                                },
                                child: Text("Test Print"),
                              ),
                            ),
                          ],
                        ).py4(),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            await addPrinterManually(context);
                          },
                          child: Text("Add Manually"),
                        ),
                      ),
                    ],
                  ).px8();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    Provider.of<BluetoothProvider>(context, listen: false).init();
    super.initState();
  }

  Future<void> addPrinterManually(BuildContext context) async {
    final initData = {};
    final GlobalKey<FormState> _form = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Enter Printer Address"),
          content: Form(
            key: _form,
            child: TextInput(
              keyName: 'address',
              initData: initData,
              hint: "Enter Address",
              context: dialogContext,
              edit: true,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
            TextButton(
              child: Text("Save"),
              onPressed: () {
                _form.currentState?.save();
                if (_form.currentState?.validate() == true) {
                  var item = {
                    'name': 'Manual',
                    'address': initData['address'].toString().trim(),
                    'type': 1,
                    'connected': true,
                  };
                  Provider.of<BluetoothProvider>(
                    context,
                    listen: false,
                  ).addDevice(item);
                  Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Provider.of<BluetoothProvider>(context,listen: false).disposeC();
    super.dispose();
  }
}
