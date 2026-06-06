class VehicleModel {
  final String vehicleNumber;
  final String? ownerName;
  final String? registeredNo;
  final bool isBlacklisted;

  VehicleModel({
    required this.vehicleNumber,
    this.ownerName,
    this.registeredNo,
    this.isBlacklisted = false,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
    vehicleNumber: json['vehicle_number']?.toString() ?? '',
    ownerName: json['owner_name'],
    registeredNo: json['registered_no'],
    isBlacklisted: json['is_blacklisted'] == true || json['is_blacklisted'] == 1,
  );
}
