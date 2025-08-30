import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gmineapp/screens/settings_page.dart';
import 'package:gmineapp/screens/token_list_screen.dart';
import 'package:gmineapp/screens/trip_list_screen.dart';
import 'package:gmineapp/services/api_service.dart';
import 'package:open_file/open_file.dart';

import '../services/session_service.dart';
import '../utils/constants.dart';
import '../widgets/DashboardCountsWidget.dart';
import 'StaffSummaryPage.dart';
import 'entry_screen.dart';
import 'exit_screen.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$appName: ${SessionService.instance.currentUser?.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _navigate(context, const AppSettingsScreen());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            DashboardCountsWidget(),
            if (SessionService.instance.currentUser?.isStaff() == true)
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _buildCard(
                      context,
                      title: 'Entry',
                      icon: Icons.add_circle_outline,
                      color: Colors.blue,
                      screen: const EntryScreen(),
                    ),
                    _buildCard(
                      context,
                      title: 'Exit',
                      icon: Icons.exit_to_app,
                      color: Colors.orange,
                      screen: const ExitScreen(),
                    ),
                    _buildCard(
                      context,
                      title: 'Token List',
                      icon: Icons.list_alt,
                      color: Colors.green,
                      screen: const TokenListScreen(),
                    ),
                    _buildCard(
                      context,
                      title: 'Trip List',
                      icon: Icons.local_shipping,
                      color: Colors.purple,
                      screen: const TripListScreen(),
                    ),
                  ],
                ),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
                    Get.to(() => StaffSummaryPage());
                  },
                  child: Text('View Report'),
                ),
                if (SessionService.instance.currentUser?.isStaff() == true)
                  TextButton(
                    onPressed: () async {
                      ApiService.downloadStaffReportPdf();
                    },
                    child: Text('Download Report'),
                  ),
              ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () => _navigate(context, screen),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
