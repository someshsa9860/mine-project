import 'dart:io';
import 'dart:typed_data';

import 'package:gmineapp/print/print.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/token_model.dart';
import '../models/trip_model.dart';
import '../services/hive_service.dart';
import '../widgets/widgets.dart';

class PdfPrint {
  final TokenModel? tokenModel;
  final TripModel? tripModel;
  final PrintFormatType formatType;

  /// External headers and footers - initialize before calling build
  List<String> headers = [];
  List<String> footers = [];

  PdfPrint({required this.formatType, this.tokenModel, this.tripModel});

  DateFormat get dateFormat => DateFormat('dd-MM-yyyy');

  DateFormat get timeFormat => DateFormat('hh:mm a');

  /// ENTRY RECEIPT
  Future<List<pw.Widget>> runEntryReceipt() async {
    final List<pw.Widget> widgets = [];

    for (var h in headers) {
      if (h.trim().isNotEmpty) {
        widgets.add(
          pw.Text(
            h,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        );
      }
    }

    widgets.add(
      pw.Text(
        "Token No: ${tokenModel?.tokenNumber ?? '--'}",
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
        textAlign: pw.TextAlign.center,
      ),
    );
    widgets.add(pw.SizedBox(height: 8));

    if (tokenModel?.vehicleNumber != null) {
      widgets.add(pw.Text("Vehicle No: ${tokenModel?.vehicleNumber ?? '--'}"));
    }

    widgets.add(pw.Text("Vehicle Type: ${tokenModel?.vehicleType ?? '--'}"));

    if (tokenModel?.vehicleType == 'Truck') {
      widgets.add(
        pw.Text(
          "Tare Weight: ${tokenModel?.tareWeight.toStringAsFixed(2) ?? '--'}",
        ),
      );
    }

    widgets.add(
      pw.Text("Date: ${dateFormat.format(parseDate(tokenModel?.tokenDate))}"),
    );

    for (var f in footers) {
      if (f.trim().isNotEmpty) {
        widgets.add(
          pw.Text(
            f.toUpperCase(),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        );
      }
    }

    return widgets;
  }

  /// EXIT RECEIPT
  Future<List<pw.Widget>> runExitReceipt() async {
    final List<pw.Widget> widgets = [];

    for (var h in headers) {
      if (h.trim().isNotEmpty) {
        widgets.add(
          pw.Text(
            h,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        );
      }
    }

    widgets.add(
      pw.Text(
        "Gate Pass",
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
      ),
    );

    widgets.add(
      pw.Text(
        "Token No: ${tokenModel?.tokenNumber ?? '--'}",
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
        textAlign: pw.TextAlign.center,
      ),
    );

    if (tokenModel?.vehicleNumber != null) {
      widgets.add(pw.Text("Vehicle No: ${tokenModel?.vehicleNumber ?? '--'}"));
    }

    widgets.add(pw.Text("Vehicle Type: ${tokenModel?.vehicleType ?? '--'}"));

    widgets.add(
      pw.Text(
        "Exit Date: ${dateFormat.format(parseDate(tripModel?.exitDate))}",
      ),
    );

    if (tripModel?.remark.isNotEmpty == true) {
      widgets.add(pw.Text("Remark: ${tripModel!.remark}"));
    }

    for (var f in footers) {
      if (f.trim().isNotEmpty) {
        widgets.add(
          pw.Text(
            f.toUpperCase(),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        );
      }
    }

    return widgets;
  }

  /// GST RECEIPT (simplified version)
  Future<List<pw.Widget>> runGSTReceipt() async {
    final List<pw.Widget> widgets = [];

    const double ratePerTon = 0.2;
    const double gstRate = 0.05;

    final double qty = (tripModel?.rweight ?? 0) / 1000;
    final double amount = ratePerTon * qty;
    final double gst = amount * gstRate;
    final double sgst = gst / 2;
    final double cgst = gst / 2;
    final double total = amount + gst;

    widgets.add(
      pw.Center(
        child: pw.Column(
          children: [
            pw.Text(
              "SHRI AMARMUMAL & SONS PRIVATE LIMITED",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text("GSTIN: 08ABJCS1562N1ZT"),
          ],
        ),
      ),
    );

    widgets.add(pw.SizedBox(height: 8));
    widgets.add(pw.Text("Bill No: ${tokenModel?.tokenNumber ?? '--'}"));
    widgets.add(pw.Text("Name: ${tokenModel?.customer_name ?? '--'}"));
    widgets.add(pw.Text("Vehicle No: ${tokenModel?.vehicleNumber ?? '--'}"));

    widgets.add(
      pw.Table(
        children: [
          pw.TableRow(
            children: [
              pw.Text("Bajri"),
              pw.Text("${gst.toStringAsFixed(2)}MT"),
              pw.Text(amount.toStringAsFixed(2)),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Text(""),
              pw.Text("SGST"),
              pw.Text(sgst.toStringAsFixed(2)),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Text(""),
              pw.Text("CGST"),
              pw.Text(cgst.toStringAsFixed(2)),
            ],
          ),
        ],
      ),
    );

    widgets.add(pw.Divider());
    widgets.add(
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          "Total: ${total.toStringAsFixed(2)}",
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ),
    );

    widgets.add(pw.SizedBox(height: 8));
    widgets.add(
      pw.Text(
        "Any weight other than billed weight is the sole responsibility of the driver. "
        "Any legal action will be borne by the vehicle driver.",
        textAlign: pw.TextAlign.left,
      ),
    );

    return widgets;
  }

  /// MASTER METHOD → build the document and return bytes
  Future<Uint8List> buildPdf() async {
    final pdf = pw.Document();

    var settings = HiveService.instance.settings;
    if (settings != null) {
      headers.add(settings.header1);
      headers.add(settings.header2);
      headers.add(settings.header3);
      footers.add(settings.footer1);
      footers.add(settings.footer2);
    }
    headers.removeWhere((e) => e.isEmpty);
    footers.removeWhere((e) => e.isEmpty);

    List<pw.Widget> widgets = [];
    switch (formatType) {
      case PrintFormatType.entry:
        widgets += await runEntryReceipt();
        break;
      case PrintFormatType.exit:
        widgets += await runExitReceipt();
        widgets.add(pw.Divider());
        widgets += await runGSTReceipt();
        break;
    }

    pdf.addPage(pw.Page(build: (context) => pw.Column(children: widgets)));

    return pdf.save();
  }

  Future<void> printJob() async {
    try {
      // Build PDF
      final pdfBytes = await buildPdf();

      // Save to temporary file
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(pdfBytes);

      // Share the file
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: "Receipt PDF"),
      );

      showSnackBar("PDF ready to share.");
    } catch (e) {
      showSnackBar("PDF print error: $e");
    }
  }
}
