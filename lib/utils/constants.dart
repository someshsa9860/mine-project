import 'package:gmineapp/services/hive_service.dart';

const version = '1.0.1@02Sept25';
const versionCode = 1;
const appName = "SAMS";

get creditParties =>
    HiveService.instance.get('creditParties') ??
    ["Vinod", "Digvijay", "Dilip", "Sampat", "Nanduji"];
