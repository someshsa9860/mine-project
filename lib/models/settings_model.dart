import 'dart:convert';

import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 4)
class SettingsModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String data;

  double get rweight_rate =>
      double.tryParse("${jsonDecode(data)['rweight_rate']}") ?? 0.0;

  String get header1 => jsonDecode(data)['header1'] ?? "";

  String get header2 => jsonDecode(data)['header2'] ?? "";

  String get footer1 => jsonDecode(data)['footer1'] ?? "";

  String get footer2 => jsonDecode(data)['footer2'] ?? "";

  String get header3 => jsonDecode(data)['header3'] ?? "";

  double get nweight_rate =>
      double.tryParse("${jsonDecode(data)['nweight_rate']}") ?? 0.0;

  double get local_tracktor_weight_rate =>
      double.tryParse("${jsonDecode(data)['local_tracktor_weight_rate']}") ??
      0.0;

  double get non_local_tracktor_weight_rate =>
      double.tryParse(
        "${jsonDecode(data)['non_local_tracktor_weight_rate']}",
      ) ??
      0.0;

  SettingsModel({required this.id, required this.data});

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      SettingsModel(id: json['id'].toString(), data: jsonEncode(json['json']));
}
