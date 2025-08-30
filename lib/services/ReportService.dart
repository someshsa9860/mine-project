import 'dart:convert';

import 'package:gmineapp/utils/api.dart';
import 'package:gmineapp/utils/endpoints.dart';

import '../models/StaffSummaryModel.dart';

class ReportService {
  Future<StaffSummaryModel> fetchStaffSummary() async {
    final response = await CallApi.instance.getData(EndPoints.reportsViewApi);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return StaffSummaryModel.fromJson(data);
    } else {
      throw Exception('Failed to load report');
    }
  }
}
