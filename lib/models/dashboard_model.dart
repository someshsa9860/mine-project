import 'dart:convert';

import 'package:hive/hive.dart';

part 'dashboard_model.g.dart';

@HiveType(typeId: 5)
class DashboardModel extends HiveObject {
  @HiveField(0)
  int openTokens;

  @HiveField(1)
  int closedTrips;

  @HiveField(2)
  int closedTripsToday;

  @HiveField(3)
  double? totalCollectionToday;

  @HiveField(4)
  double? totalCollectionMonth;

  @HiveField(5)
  int? totalTrips;
  @HiveField(6)
  String? dashboardData;
  @HiveField(7)
  String? test;

  List? get dashboardList =>
      dashboardData == null ? [] : jsonDecode(dashboardData!);

  DashboardModel({
    this.openTokens = 0,
    this.closedTrips = 0,
    this.closedTripsToday = 0,
    this.totalCollectionToday = 0,
    this.totalCollectionMonth = 0,
    this.totalTrips = 0,
    this.dashboardData,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      openTokens: json['openTokens'] ?? 0,
      closedTrips: json['closedTrips'] ?? 0,
      closedTripsToday: json['closedTripsToday'] ?? 0,
      totalCollectionToday: (json['totalCollectionToday'] ?? 0).toDouble(),
      totalCollectionMonth: (json['totalCollectionMonth'] ?? 0).toDouble(),
      totalTrips: json['totalTrips'] ?? 0,
      dashboardData: json['dashboardList'] == null
          ? null
          : jsonEncode(json['dashboardList']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'openTokens': openTokens,
      'closedTrips': closedTrips,
      'closedTripsToday': closedTripsToday,
      'totalCollectionToday': totalCollectionToday,
      'totalCollectionMonth': totalCollectionMonth,
      'totalTrips': totalTrips,
    };
  }
}
