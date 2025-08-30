import 'package:flutter/material.dart';
import 'package:gmineapp/services/hive_service.dart';
import 'package:gmineapp/services/session_service.dart';
import 'package:gmineapp/widgets/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../models/dashboard_model.dart';

class DashboardCountsWidget extends StatelessWidget {
  const DashboardCountsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final box = HiveService.instance.box;

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box box, _) {
        final DashboardModel? data = box.get('dashboardUpdate');

        if (data == null) {
          return const Center(child: Text('No dashboard data.'));
        }

        return MyCustomCard(
          elevation: 3,
          child: Wrap(
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _buildStat(
                'Open Tokens',
                data.openTokens.toString(),
                Colors.orange,
              ),
              _buildStat(
                'Closed Trips',
                data.closedTrips.toString(),
                Colors.green,
              ),
              _buildStat(
                'Today\'s Trips',
                data.closedTripsToday.toString(),
                Colors.blue,
              ),
              if (SessionService.instance.currentUser?.isOwner() == true) ...[
                Divider(),

                if (data.dashboardList != null)
                  for (var item in data.dashboardList!)
                    _buildStat(
                      "${item['label']}",
                      "${item['value']}",
                      Colors.purple,
                    ),
              ],
            ],
          ),
        ).py8();
      },
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
