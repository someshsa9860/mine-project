import 'package:hive/hive.dart';

part 'vehicle_type_model.g.dart';

@HiveType(typeId: 1)
class VehicleTypeModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  VehicleTypeModel({required this.id, required this.name});

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) =>
      VehicleTypeModel(id: json['id'].toString(), name: json['name']);
}
