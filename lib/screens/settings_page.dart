import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gmineapp/services/auth_manager.dart';
import 'package:gmineapp/services/hive_service.dart';
import 'package:gmineapp/utils/constants.dart';
import 'package:open_file/open_file.dart';
import 'package:velocity_x/velocity_x.dart';

import '../services/api_service.dart';
import '../services/session_service.dart';
import '../widgets/widgets.dart';
import 'bluetooth_connect_screen.dart';

var paperSizes = [
  {'key': PaperSize.mm58.value.toString(), 'value': '58 mm'},
  {'key': PaperSize.mm80.value.toString(), 'value': '80 mm'},
];
var printerTypes = [
  {'key': "PDF", 'value': 'PDF Print'},
  {'key': "Bluetooth", 'value': 'Bluetooth Print'},
  {'key': "WIFI", 'value': 'WIFI Print'},
];

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  static const String routeName = '/app-settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        // backgroundColor: Theme.of(context).primaryColor,
        // foregroundColor: Colors.white,
      ),
      body: SafeArea(child: const AccountScreen()),
    );
  }
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      children: [
        /// 👤 **User Profile Section**
        _buildSectionTitle("Preferences"),

        _buildSettingItem(
          icon: Icons.bluetooth,
          label: "Bluetooth Printer Setup",
          onTap: () => Get.to(const BluetoothConnectScreen()),
        ),

        _buildSettingItem(
          icon: Icons.receipt_long,
          label: "Print Method",
          trailing: DropdownButton(
            value: HiveService.instance.get(SettingKeys.printer.toString()),
            onChanged: (v) async {
              HiveService.instance.put(SettingKeys.printer.toString(), v);
              setState(() {});
            },
            items: printerTypes.map((map) {
              return DropdownMenuItem(
                value: map['key'].toString(),
                child: Text(map['value'].toString()),
              );
            }).toList(),
          ),
          onTap: null,
        ),

        if (HiveService.instance.get(SettingKeys.printer.toString()) == "WIFI")
          ListTile(
            onTap: () {
              addPrinterManually(context);
            },
            title: Text('Wifi Address'),
            subtitle: Text(
              '${HiveService.instance.get('WIFI_ADDRESS') ?? 'Not set'}',
            ),
            trailing: Icon(Icons.edit),
          ),

        _buildSettingItem(
          icon: Icons.receipt_long,
          label: "Paper size",
          trailing: DropdownButton(
            value: HiveService.instance.get(SettingKeys.paper.toString()),
            onChanged: (v) async {
              HiveService.instance.put(SettingKeys.paper.toString(), v);

              setState(() {});
            },
            items: paperSizes.map((map) {
              return DropdownMenuItem(
                value: map['key'].toString(),
                child: Text(map['value'].toString()),
              );
            }).toList(),
          ),
          onTap: null,
        ),
        Divider(),
        if (SessionService.instance.currentUser?.isStaff() == true)
          TextButton(
            onPressed: () async {
              ApiService.downloadStaffReportPdf();
            },
            child: Text('Download Report'),
          ),

        if (SessionService.instance.currentUser?.isStaff() == true)
          ValueListenableBuilder(
            builder: (context, value, child) {
              return Visibility(
                visible: (ApiService.reportPath.value != null),
                child: ListTile(
                  title: Text('Report Downloaded'),
                  trailing: IconButton(
                    onPressed: () {
                      OpenFile.open(
                        ApiService.reportPath.value,
                        type: "application/pdf",
                      );
                    },
                    icon: Icon(Icons.share),
                  ),
                  leading: IconButton(
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: Text('Alert'),
                          content: Text(
                            "Are you sure to remove, you can't download it?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                ApiService.reportPath.value = null;
                                Get.back(closeOverlays: true);
                              },
                              child: Text("Yes"),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back(closeOverlays: true);
                              },
                              child: Text("No"),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.close),
                  ),
                ),
              );
            },
            valueListenable: ApiService.reportPath,
          ),
        Divider(),
        _buildSettingItem(
          icon: Icons.logout,
          label: "Logout $version",
          onTap: () {
            AuthManager.instance.logout();
          },
        ),
      ],
    );
  }

  /// 📌 **Section Title Widget**
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Future<void> addPrinterManually(BuildContext context) async {
    final initData = {'address': HiveService.instance.get('WIFI_ADDRESS')};
    final GlobalKey<FormState> _form = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Enter Printer IP Address (WIFI)"),
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
                  HiveService.instance.put('WIFI_ADDRESS', initData['address']);
                  Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                  setState(() {});
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// 🔧 **Setting Item**
  Widget _buildSettingItem({
    required IconData icon,
    Widget? trailing,
    Widget? subTitle,
    required String label,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.blueAccent,
      ),
      subtitle: subTitle,
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
    ).p8();
  }
}
