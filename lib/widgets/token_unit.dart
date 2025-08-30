import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gmineapp/print/bluetooth_print.dart';
import 'package:gmineapp/services/api_service.dart';
import 'package:gmineapp/utils/loader.dart';
import 'package:gmineapp/widgets/widgets.dart';
import 'package:intl/intl.dart';

import '../../models/token_model.dart';

class TokenListUnit extends StatelessWidget {
  final TokenModel token;

  const TokenListUnit({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final statusColor =
        {
          'pending': Colors.orange,
          'completed': Colors.green,
          'cancelled': Colors.red,
        }[token.status] ??
        Colors.grey;

    return MyCustomCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with background
            CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.2),
              child: Icon(Icons.local_shipping, color: statusColor),
            ),

            const SizedBox(width: 12),

            // Text details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    token.vehicleNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("Token #: ${token.tokenNumber}"),
                  if (token.vehicleType != null)
                    Text("Type: ${token.vehicleType}"),
                  Text(
                    "Tare: ${token.tareWeight}T, Advance: $currency${token.advanceAmount}",
                  ),
                  Text(
                    "Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.tryParse(token.tokenDate) ?? DateTime.now())}",
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                IconButton(
                  tooltip: 'Print',
                  onPressed: () {
                    BluetoothPrint(
                      tokenModel: token,
                      formatType: PrintFormatType.entry,
                    ).printJob();
                  },
                  icon: const Icon(Icons.print),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () {
                    _showDeleteConfirmDialog(context);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete token #${token.tokenNumber}?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              Loader.instance.show();
              ApiService.deleteToken(token);
            },
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
