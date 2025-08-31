import 'package:flutter/material.dart';
import 'package:gmineapp/widgets/widgets.dart';
import 'package:intl/intl.dart';

import '../../models/trip_model.dart';
import '../print/print.dart';

class TripListUnit extends StatelessWidget {
  final TripModel trip;

  const TripListUnit({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return MyCustomCard(
      elevation: 4,
      child: ListTile(
        title: Text("Trip ID: ${trip.id}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (trip.tokenId != null) Text("Token ID: ${trip.tokenId}"),
            if (trip.totalAmount != null)
              Text("Amount: $currency${trip.totalAmount?.toStringAsFixed(2)}"),
            if (trip.status != null) Text("Status: ${trip.status}"),
            Text(
              "Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.tryParse(trip.exitDate) ?? DateTime.now())}",
            ),
          ],
        ),
        trailing: const Icon(Icons.print),
        onTap: () {
          MyPrintService(
            tokenModel: trip.tokenModel,
            tripModel: trip,
            formatType: PrintFormatType.exit,
          ).printJob();
        },
      ),
    );
  }
}
