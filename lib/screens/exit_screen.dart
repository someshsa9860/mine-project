import 'package:flutter/material.dart';
import 'package:gmineapp/models/settings_model.dart';
import 'package:gmineapp/models/token_model.dart';
import 'package:gmineapp/services/hive_service.dart';

import '../print/print.dart';
import '../services/api_service.dart'; // hypothetical API file
import '../widgets/widgets.dart'; // assumes your TextInput is here

class ExitScreen extends StatefulWidget {
  const ExitScreen({super.key});

  @override
  State<ExitScreen> createState() => _ExitScreenState();
}

class _ExitScreenState extends State<ExitScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {};

  SettingsModel? settingsModel;

  String tokenNumber = '';
  List<TokenModel> allTokens = [];
  TokenModel? selectedToken;
  bool _isSubmitting = false;
  bool _loadingTokens = true;

  @override
  void initState() {
    super.initState();
    _fetchRecentTokens();
  }

  Future<void> _fetchRecentTokens() async {
    settingsModel = HiveService.instance.settings;
    formData['rweight_rate'] = settingsModel?.rweight_rate;
    formData['nweight_rate'] = settingsModel?.nweight_rate;
    formData['local_tracktor_weight_rate'] =
        settingsModel?.local_tracktor_weight_rate;
    formData['non_local_tracktor_weight_rate'] =
        settingsModel?.non_local_tracktor_weight_rate;
    try {
      // Replace with your actual API call
      final tokens =
          await ApiService.getRecentActiveTokens(); // e.g., last 2 days
      setState(() {
        allTokens = tokens;
        _loadingTokens = false;
      });
    } catch (e) {
      setState(() => _loadingTokens = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch tokens: $e')));
    }
  }

  List<TokenModel> get filteredTokens {
    final input = tokenNumber.toLowerCase();
    return allTokens.where((token) {
      final tokenNumber = token.tokenNumber?.toString().toLowerCase() ?? '';
      return tokenNumber.contains(input);
    }).toList();
  }

  double _parse(String key) => double.tryParse('${formData[key] ?? ""}') ?? 0.0;

  double get totalAmount {
    return (_parse('rweight') * _parse('rweight_rate')) +
        (_parse('nweight') * _parse('nweight_rate'));
  }

  double get finalBalance => totalAmount - (selectedToken?.advanceAmount ?? 0);

  void _submit() async {
    if (!_formKey.currentState!.validate() || selectedToken == null) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);

    final tripData = {
      'token_id': selectedToken!.id,
      'gross_weight': _parse('gross_weight'),
      'collected_amount': _parse('collected_amount'),
      'nweight': _parse('nweight'),
      'rweight': _parse('rweight'),
      'payment_method': formData['payment_method'],
      'nweight_rate': _parse('nweight_rate'),
      'rweight_rate': _parse('rweight_rate'),
      'total_amount': totalAmount,
      'final_balance': finalBalance,
      'remark': formData['remark'] ?? '',
    };

    var res = await ApiService.completeTrip(tripData);

    if (res != null) {
      MyPrintService(
        tripModel: res,
        tokenModel: selectedToken,
        formatType: PrintFormatType.exit,
      ).printJob();
      _formKey.currentState?.reset();
      formData.clear();
      selectedToken = null;
      tokenNumber = '';
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exit Trip')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Enter Token To Fetch',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  suffixIcon: TextButton(
                    onPressed: () async {
                      if (tokenNumber.isNotEmpty) {
                        final res = await ApiService.getToken(tokenNumber);
                        if (res != null) {
                          if (res.isEmpty) {
                            setState(() {
                              selectedToken = null;
                            });
                          } else if (res.length == 1) {
                            tokenNumber = '';
                            setState(() {
                              selectedToken = res.first;
                            });
                          } else {
                            tokenNumber = '';
                            setState(() {
                              allTokens = res;
                            });
                          }
                        }
                      }
                    },
                    child: Text('Fetch'),
                  ),
                ),

                onChanged: (v) {
                  setState(() {
                    tokenNumber = v;
                  });
                },
              ),
              const SizedBox(height: 8),
              if (selectedToken == null || tokenNumber.isNotEmpty)
                Expanded(
                  child: Builder(
                    builder: (context) {
                      return _loadingTokens
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.separated(
                              itemBuilder: (BuildContext context, int index) {
                                var token = filteredTokens.elementAt(index);
                                return ListTile(
                                  subtitle: Text("Token:${token.tokenNumber}"),
                                  title: Text(
                                    '${token.vehicleNumber} • ${token.vehicleType}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Adv: $currency${token.advanceAmount}',
                                      ),
                                      Icon(Icons.navigate_next_sharp, size: 16),
                                    ],
                                  ),
                                  onTap: () {
                                    tokenNumber = '';
                                    allTokens.clear();
                                    setState(() => selectedToken = token);
                                  },
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                    return Divider();
                                  },
                              itemCount: filteredTokens.length,
                            );
                    },
                  ),
                ),
              if (selectedToken != null && tokenNumber.isEmpty)
                Expanded(child: SingleChildScrollView(child: buildExitForm())),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildExitForm() {
    return Form(
      onChanged: () {
        _formKey?.currentState?.save();
        formData['nweight'] =
            (_parse('gross_weight') -
                    _parse('rweight') -
                    (selectedToken?.tareWeight ?? 0))
                .toString();
        setState(() {});
      },
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(thickness: 1.2),
            Text(
              '🆔 Token: ${selectedToken!.tokenNumber}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text('🚚 Vehicle: ${selectedToken!.vehicleNumber}'),
            Text('⚖️ Tare Weight: ${selectedToken!.tareWeight} T'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('RWeight Rate: $currency${formData['rweight_rate']}'),
                Text('NWeight Rate: $currency${formData['nweight_rate']}'),
              ],
            ),

            const SizedBox(height: 16),
            ...['gross_weight', 'rweight', 'collected_amount'].map(
              (key) => TextInput(
                keyName: key,

                hint: key.replaceAll('_', ' ').toUpperCase(),
                initData: formData,
                inputType: key == 'collected_amount'
                    ? TextInputType.numberWithOptions(signed: true)
                    : TextInputType.number,
                context: context,
                requiredField: true,
                edit: true,
                onChanged: (_) => setState(() {}),
              ),
            ),
            RadioInput(
              list: ['Cash', 'PhonePay'],
              initData: formData,
              keyName: 'payment_method',

              hint: "Mode",
              onChanged: () {
                setState(() {});
              },
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '💰 Amount Summary',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '(Wt.${(_parse('gross_weight') - selectedToken!.tareWeight).toStringAsFixed(1)})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '$currency${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Advance Paid:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '- $currency${selectedToken?.advanceAmount ?? 0}',
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Final Balance:',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        '$currency${finalBalance.toStringAsFixed(3)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: finalBalance >= 0 ? Colors.teal : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: const Icon(Icons.save),
                    label: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Record Trip',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
