import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/StaffSummaryModel.dart';
import '../services/ReportService.dart';

final reportServiceProvider = Provider<ReportService>((ref) => ReportService());

final staffSummaryProvider = FutureProvider<StaffSummaryModel>((ref) async {
  final service = ref.read(reportServiceProvider);
  return service.fetchStaffSummary();
});
