import 'package:gmineapp/print/bluetooth_print.dart';
import 'package:gmineapp/print/pdf_print.dart';
import 'package:gmineapp/widgets/widgets.dart';

import '../models/token_model.dart';
import '../models/trip_model.dart';
import '../services/hive_service.dart';

class MyPrintService {
  final TokenModel? tokenModel;
  final TripModel? tripModel;
  final PrintFormatType formatType;

  MyPrintService({required this.formatType, this.tokenModel, this.tripModel});

  Future<void> printJob() async {
    final printMethod =
        HiveService.instance.get(SettingKeys.printer.toString())?.toString() ??
        'bluetooth';

    print('printMethod:$printMethod');
    if (printMethod == "PDF") {
      PdfPrint(
        formatType: formatType,
        tokenModel: tokenModel,
        tripModel: tripModel,
      ).printJob();
    } else {
      BluetoothPrint(
        formatType: formatType,
        tokenModel: tokenModel,
        tripModel: tripModel,
      ).printJob();
    }
  }
}

DateTime parseDate(date) {
  return DateTime.tryParse("$date") ?? DateTime.now();
}
