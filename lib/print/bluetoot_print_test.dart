import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:gmineapp/services/hive_service.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../utils/constants.dart';
import '../widgets/widgets.dart';
import 'bluetoothConnection.dart';

const cCutFull = '${gs}V0'; // Full cut
const gs = '\x1D';

Future<List<int>> testBluetooth() async {
  final pref = HiveService.instance;
  final v = pref.get(SettingKeys.paper.toString()) ?? '1';
  final paper = v.toString().contains('1') ? PaperSize.mm58 : PaperSize.mm80;
  final cProfile = await CapabilityProfile.load();

  final Generator ticket = Generator(paper, cProfile);
  List<int> bytes = [];
  bytes += ticket.reset();
  bytes.addAll(await test(ticket));

  bytes += ticket.feed(1);
  bytes += ticket.cut();

  return bytes;
}

Future<List<int>> test(Generator ticket) async {
  List<int> bytes = [];

  bytes += ticket.text(
    "$appName Test Print",
    styles: const PosStyles(
      fontType: PosFontType.fontA,
      bold: true,
      align: PosAlign.center,
    ),
  );

  return bytes;
}

Future<void> printTest() async {
  final blueConnector = BluetoothConnection.instance;

  // Check Bluetooth connectivity
  if (!await blueConnector.checkBluetooth()) {
    showSnackBar("Bluetooth is not enabled or available.");
    return;
  }

  try {
    // Prepare bytes for printing
    final bytes = await testBluetooth();
    if (!await blueConnector.checkBluetooth()) {
      return;
    }
    // Attempt to connect and print based on the platform
    final connectionResult = await blueConnector.connect(blueConnector.device!);

    if (!connectionResult) {
      throw Exception("Unable to connect to the printer.");
    }

    final printResult = await PrintBluetoothThermal.writeBytes(bytes);

    final message =
        printResult
            ? "Printing successful."
            : "Unable to print. Check the printer connection.";
    showSnackBar(message);
  } catch (e, stackTrace) {
    print("Error during Bluetooth printing: $e");
    print(stackTrace);

    showSnackBar("An error occurred: ${e.toString()}");
  }
}
