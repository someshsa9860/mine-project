import 'package:gmineapp/models/token_model.dart';
import 'package:hive/hive.dart';

part 'trip_model.g.dart';

@HiveType(typeId: 2)
class TripModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String tokenId;

  @HiveField(2)
  double grossWeight;

  @HiveField(3)
  double underloadWeight;

  @HiveField(4)
  double overloadWeight;

  @HiveField(5)
  double rweight;

  @HiveField(6)
  double rweightRate;

  @HiveField(7)
  double nweight;

  @HiveField(8)
  double nweightRate;

  @HiveField(9)
  double totalAmount;

  @HiveField(10)
  double finalBalance;

  @HiveField(11)
  String status;

  @HiveField(12)
  String remark;

  @HiveField(13)
  String exitDate;

  @HiveField(14)
  String staffId;

  @HiveField(15)
  String? tokenNumber;
  @HiveField(16)
  TokenModel? tokenModel;
  @HiveField(17)
  double? collected_amount;

  TripModel({
    required this.id,
    required this.tokenId,
    required this.grossWeight,
    required this.underloadWeight,
    required this.overloadWeight,
    required this.rweight,
    required this.rweightRate,
    required this.tokenNumber,
    required this.nweight,
    required this.nweightRate,
    required this.totalAmount,
    required this.finalBalance,
    required this.status,
    required this.remark,
    required this.collected_amount,
    required this.exitDate,
    this.tokenModel,
    required this.staffId,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) => TripModel(
    id: json['id'].toString(),
    tokenId: json['token_id']?.toString() ?? '',
    tokenNumber: json['token_number']?.toString(),
    grossWeight: (json['gross_weight'] ?? 0).toDouble(),
    underloadWeight: (json['underload_weight'] ?? 0).toDouble(),
    overloadWeight: (json['overload_weight'] ?? 0).toDouble(),
    rweight: (json['rweight'] ?? 0).toDouble(),
    rweightRate: (json['rweight_rate'] ?? 0).toDouble(),
    nweight: (json['nweight'] ?? 0).toDouble(),
    nweightRate: (json['nweight_rate'] ?? 0).toDouble(),
    totalAmount: (json['total_amount'] ?? 0).toDouble(),
    finalBalance: (json['final_balance'] ?? 0).toDouble(),
    collected_amount: (json['collected_amount'] ?? 0).toDouble(),
    status: json['status'] ?? 'pending',
    remark: json['remark'] ?? '',
    exitDate: json['exit_date'] ?? '',
    tokenModel: json['token'] == null
        ? null
        : TokenModel.fromJson(json['token']),
    staffId: json['staff_id']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'token_id': tokenId,
    'gross_weight': grossWeight,
    'underload_weight': underloadWeight,
    'overload_weight': overloadWeight,
    'rweight': rweight,
    'rweight_rate': rweightRate,
    'nweight': nweight,
    'nweight_rate': nweightRate,
    'total_amount': totalAmount,
    'final_balance': finalBalance,
    'status': status,
    'remark': remark,
    'collected_amount': collected_amount,
    'exit_date': exitDate,
    'staff_id': staffId,
  };
}
