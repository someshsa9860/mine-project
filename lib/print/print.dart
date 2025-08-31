import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:gmineapp/print/bluetooth_print.dart';
import 'package:gmineapp/print/pdf_print.dart';
import 'package:gmineapp/widgets/widgets.dart';
import 'package:intl/intl.dart';

import '../models/token_model.dart';
import '../models/trip_model.dart';
import '../services/hive_service.dart';

enum PrintFormatType { entry, exit }

class MyPrintService {
  final TokenModel? tokenModel;
  final TripModel? tripModel;
  final PrintFormatType formatType;

  /// External headers and footers - initialize them before calling print
  List<String> headers = [];
  List<String> footers = [];

  MyPrintService({required this.formatType, this.tokenModel, this.tripModel});

  PosStyles posStyles = PosStyles(
    width: PosTextSize.size1,
    height: PosTextSize.size1,
    bold: true,
    fontType: PosFontType.fontA,
  );

  DateFormat get dateFormat => DateFormat('dd-MM-yyyy');

  DateFormat get timeFormat => DateFormat('hh:mm a');

  List<int> runEntryReceipt(Generator ticket) {
    List<int> bytes = [];
    final style = posStyles;

    for (var h in headers) {
      if (h.trim().isNotEmpty) {
        bytes += ticket!.text(h, styles: style);
      }
    }

    bytes += ticket!.text(
      "Token No: ${tokenModel?.tokenNumber ?? '--'}",
      styles: style.copyWith(
        width: PosTextSize.size2,
        height: PosTextSize.size2,
        align: PosAlign.center,
        bold: true,
      ),
    );
    bytes += ticket!.emptyLines(1);

    if (tokenModel?.vehicleNumber != null) {
      bytes += ticket!.text(
        "Vehicle No: ${tokenModel?.vehicleNumber ?? '--'}",
        styles: style,
      );
    }

    bytes += ticket!.text(
      "Vehicle Type: ${tokenModel?.vehicleType ?? '--'}",
      styles: style,
    );
    if (tokenModel?.vehicleType == 'Truck') {
      bytes += ticket!.text(
        "Tare Weight: ${tokenModel?.tareWeight.toStringAsFixed(2)}",
        styles: style,
      );
    }

    bytes += ticket!.text(
      "Date: ${dateTimeFormat.format(parseDate(tokenModel?.tokenDate))}",
      styles: style,
    );

    for (var f in footers) {
      if (f.trim().isNotEmpty) {
        bytes += ticket!.text(f.toUpperCase(), styles: style);
      }
    }

    return bytes;
  }

  List<int> runExitReceipt(Generator ticket) {
    List<int> bytes = [];
    final style = posStyles;

    for (var h in headers) {
      if (h.trim().isNotEmpty) {
        bytes += ticket!.text(h, styles: style);
      }
    }
    bytes += ticket!.text("Gate Pass", styles: style);

    bytes += ticket!.text(
      "Token No: ${tokenModel?.tokenNumber ?? '--'}",
      styles: style.copyWith(
        width: PosTextSize.size2,
        height: PosTextSize.size2,
        bold: true,
      ),
    );
    bytes += ticket!.emptyLines(1);

    if (tokenModel?.vehicleNumber != null) {
      bytes += ticket!.text(
        "Vehicle No: ${tokenModel?.vehicleNumber ?? '--'}",
        styles: style,
      );
    }
    bytes += ticket!.text(
      "Vehicle Type: ${tokenModel?.vehicleType ?? '--'}",
      styles: style,
    );

    bytes += ticket!.text(
      "Exit Date: ${dateTimeFormat.format(parseDate(tripModel?.exitDate)) ?? '--'}",
      styles: style,
    );

    if (tripModel?.remark.isNotEmpty == true) {
      bytes += ticket!.text("Remark: ${tripModel!.remark}", styles: style);
    }

    for (var f in footers) {
      if (f.trim().isNotEmpty) {
        bytes += ticket!.text(f.toUpperCase(), styles: style);
      }
    }

    return bytes;
  }

  List<int> runGSTReceipt(Generator ticket) {
    List<int> bytes = [];

    // Constants
    const double ratePerTon = 0.2; // Rs per unit
    const double gstRate = 0.05; // 5%

    final leftAlign = posStyles.copyWith(align: PosAlign.left);
    final centerAlign = posStyles.copyWith(align: PosAlign.center);

    // Helper to safely print a line
    void printLine(String label, String? value) {
      bytes += ticket.text(
        "$label: ${value?.isNotEmpty == true ? value : '--'}",
        styles: leftAlign,
      );
    }

    // Header
    bytes += ticket.text(
      "SHRI AMARMUMAL & SONS PRIVATE LIMITED",
      styles: centerAlign,
    );
    bytes += ticket.text("GSTIN: 08ABJCS1562N1ZT", styles: centerAlign);

    // Customer info
    printLine("Bill No: ", tokenModel?.tokenNumber);
    printLine("Name", tokenModel?.customer_name);
    printLine("Vehicle No", tokenModel?.vehicleNumber);

    // Calculation
    final double qty = (tripModel?.rweight ?? 0) / 1000;
    final double amount = ratePerTon * qty;
    final double gst = amount * gstRate;
    final double sgst = gst / 2;
    final double cgst = gst / 2;
    final double total = amount + gst;

    bytes += ticket.row([
      PosColumn(text: 'Bajri', width: 3, styles: leftAlign),
      PosColumn(
        text: "${gst.toStringAsFixed(2)}MT",
        width: 4,
        styles: leftAlign,
      ),
      PosColumn(text: amount.toStringAsFixed(2), width: 5, styles: leftAlign),
    ]);

    bytes += ticket.row([
      PosColumn(text: '    ', width: 3),
      PosColumn(text: 'SGST', width: 4, styles: leftAlign),
      PosColumn(text: sgst.toStringAsFixed(2), width: 5, styles: leftAlign),
    ]);

    bytes += ticket.row([
      PosColumn(text: '    ', width: 3),
      PosColumn(text: 'CGST', width: 4, styles: leftAlign),
      PosColumn(text: cgst.toStringAsFixed(2), width: 5, styles: leftAlign),
    ]);

    // Disclaimer
    bytes += ticket.text(
      '------------------',
      styles: leftAlign.copyWith(align: PosAlign.right),
    );
    bytes += ticket.text(
      "Total: ${total.toStringAsFixed(2)}",
      styles: leftAlign.copyWith(align: PosAlign.right),
    );

    bytes += ticket.text(
      "Any weight other than billed weight is the sole responsibility of the driver. "
      "Any legal action will be borne by the vehicle driver.",
      styles: posStyles.copyWith(align: PosAlign.left, bold: false),
    );

    return bytes;
  }

  Generator? ticket;

  Future<List<int>> printBluetooth() async {
    final paperSetting =
        HiveService.instance.get('paper_size')?.toString() ?? '80';

    final paper = paperSetting.contains('58') ? PaperSize.mm58 : PaperSize.mm80;

    var settings = HiveService.instance.settings;
    if (settings != null) {
      headers.add(settings!.header1);
      headers.add(settings!.header2);
      headers.add(settings!.header3);
      footers.add(settings!.footer1);
      footers.add(settings!.footer2);
    }
    headers.removeWhere((e) => e.isEmpty);
    footers.removeWhere((e) => e.isEmpty);

    final profile = await CapabilityProfile.load();
    ticket = Generator(paper, profile);

    List<int> bytes = [];
    bytes += ticket!.reset();
    bytes += ticket!.setStyles(posStyles);

    switch (formatType) {
      case PrintFormatType.entry:
        bytes += runEntryReceipt(ticket!);
        break;
      case PrintFormatType.exit:
        bytes += runExitReceipt(ticket!);
        bytes += ticket!.feed(2);
        if (!kDebugMode) {
          bytes += ticket!.cut();
        }
        bytes += runGSTReceipt(ticket!);
        break;
    }

    bytes += ticket!.feed(2);
    if (!kDebugMode) {
      bytes += ticket!.cut();
    }

    return bytes;
  }

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
