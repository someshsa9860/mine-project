import 'package:hive/hive.dart';

part 'token_model.g.dart';

@HiveType(typeId: 3)
class TokenModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String tokenNumber;

  @HiveField(2)
  String vehicleNumber;

  @HiveField(3)
  String vehicleType;

  @HiveField(4)
  double tareWeight;

  @HiveField(5)
  double advanceAmount;

  @HiveField(6)
  String status;

  @HiveField(7)
  String staffId;

  @HiveField(8)
  String tokenDate;
  @HiveField(9)
  String customer_name;

  TokenModel({
    required this.id,
    required this.tokenNumber,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.tareWeight,
    required this.advanceAmount,
    required this.status,
    required this.staffId,
    required this.tokenDate,
    required this.customer_name,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) => TokenModel(
    id: json['id'].toString(),
    tokenNumber: "${json['token_number']}" ?? '',
    vehicleNumber: json['vehicle_number'] ?? '',
    vehicleType: json['vehicle_type'] ?? '',
    tareWeight: (json['tare_weight'] ?? 0).toDouble(),
    advanceAmount: (json['advance_amount'] ?? 0).toDouble(),
    status: json['status'] ?? 'pending',
    staffId: json['staff_id']?.toString() ?? '',
    tokenDate: json['token_date'] ?? '',
    customer_name: json['customer_name'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'token_number': tokenNumber,
    'vehicle_number': vehicleNumber,
    'vehicle_type': vehicleType,
    'tare_weight': tareWeight,
    'advance_amount': advanceAmount,
    'status': status,
    'staff_id': staffId,
    'token_date': tokenDate,
    'customer_name': customer_name,
  };
}
