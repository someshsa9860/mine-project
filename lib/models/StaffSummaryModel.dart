class StaffSummaryModel {
  final double advanceTotal;
  final int pendingTokensCount;
  final double collectedTotal;
  final double totalAmount;
  final List<Map<String, dynamic>> pendingTokens;
  final List<Map<String, dynamic>> tokensTracktor;
  final List<Map<String, dynamic>> trips;

  StaffSummaryModel({
    required this.advanceTotal,
    required this.pendingTokensCount,
    required this.collectedTotal,
    required this.totalAmount,
    required this.pendingTokens,
    required this.tokensTracktor,
    required this.trips,
  });

  factory StaffSummaryModel.fromJson(Map<String, dynamic> json) {
    return StaffSummaryModel(
      advanceTotal: (json['advanceTotal'] ?? 0).toDouble(),
      pendingTokensCount: json['pendingTokensCount'] ?? 0,
      collectedTotal: (json['collectedTotal'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      pendingTokens: List<Map<String, dynamic>>.from(
        json['pendingTokens'] ?? [],
      ),
      tokensTracktor: List<Map<String, dynamic>>.from(
        json['tokensTracktor'] ?? [],
      ),
      trips: List<Map<String, dynamic>>.from(json['trips'] ?? []),
    );
  }
}
