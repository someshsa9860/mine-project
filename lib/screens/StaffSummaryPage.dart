import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/StaffSummaryModel.dart';
import '../providers/reportServiceProvider.dart';
import '../services/api_service.dart';

class StaffSummaryPage extends ConsumerWidget {
  const StaffSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(staffSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff Summary Report"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ApiService.downloadStaffReportPdf();
            },
            icon: Icon(Icons.download),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(staffSummaryProvider);
          },
          child: summaryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (summary) => _buildContent(context, summary),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, StaffSummaryModel model) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildSummaryCard(model),
        const SizedBox(height: 16),
        _buildSection("Incomplete Tokens", model.pendingTokens, [
          "token_number",
          "vehicle_number",
          "advance_amount",
          "credit_party",
        ]),
        const SizedBox(height: 16),
        _buildSection("Tractor Tokens", model.tokensTracktor, [
          "token_number",
          "vehicle_type",
          "trip.total_amount",
        ]),
        const SizedBox(height: 16),
        _buildSection("Truck Completed Trips", model.trips, [
          "token.token_number",
          "token.vehicle_number",
          "gross_weight",
          "token.tare_weight",
          "rweight",
          "nweight",
          "total_amount",
        ]),
      ],
    );
  }

  Widget _buildSummaryCard(StaffSummaryModel model) {
    return Card(
      color: Colors.indigo.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _summaryRow("Advance Total", model.advanceTotal.toStringAsFixed(3)),
            _summaryRow("Pending Tokens", model.pendingTokensCount.toString()),
            _summaryRow(
              "Collected Amount",
              model.collectedTotal.toStringAsFixed(3),
            ),
            _summaryRow("Total Amount", model.totalAmount.toStringAsFixed(3)),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<Map<String, dynamic>> data,
    List<String> fields,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  Colors.grey.shade200,
                ),
                columns: fields
                    .map(
                      (f) => DataColumn(
                        label: Text(
                          _formatHeader(f),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                rows: data.map((row) {
                  return DataRow(
                    cells: fields.map((field) {
                      final value = _getNestedValue(row, field) ?? "-";
                      return DataCell(
                        Text("$value", style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Convert snake_case or dot.notation to a clean Capitalized Header
  String _formatHeader(String field) {
    final last = field.split('.').last;
    return last
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  /// Access nested fields like token.token_number or trip.total_amount
  dynamic _getNestedValue(Map<String, dynamic> map, String fieldPath) {
    final keys = fieldPath.split('.');
    dynamic value = map;
    for (final key in keys) {
      if (value is Map && value.containsKey(key)) {
        value = value[key];
      } else {
        return null;
      }
    }
    return value;
  }
}
