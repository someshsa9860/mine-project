import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gmineapp/print/bluetooth_print.dart';
import 'package:gmineapp/print/print.dart';
import 'package:gmineapp/utils/constants.dart';

import '../services/api_service.dart';
import '../widgets/widgets.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {'payment_method': "Cash"};

  final String _status = 'pending';
  bool _isLoading = false;

  // Auto-fill + blacklist state, keyed off the entered vehicle number.
  Timer? _lookupDebounce;
  bool _isBlacklisted = false;

  String stateKey = DateTime.now().toIso8601String();

  @override
  void dispose() {
    _lookupDebounce?.cancel();
    super.dispose();
  }

  /// Debounced lookup of a vehicle number: auto-fills owner name + registered
  /// no from history and flags blacklisted vehicles.
  void _onVehicleNumberChanged(String value) {
    final number = value.trim();
    _lookupDebounce?.cancel();

    // Reset blacklist flag while the number is being edited.
    if (_isBlacklisted) {
      setState(() => _isBlacklisted = false);
    }

    if (number.isEmpty) return;

    _lookupDebounce = Timer(const Duration(milliseconds: 600), () async {
      final vehicle = await ApiService.lookupVehicle(number);
      if (!mounted) return;
      if (vehicle == null) return;
      // Ignore stale results if the field changed again.
      if (formData['vehicle_number']?.toString().trim() != number) return;

      setState(() {
        _isBlacklisted = vehicle.isBlacklisted;
        // Auto-fill identity fields only (Owner + Registered No).
        if ((vehicle.ownerName ?? '').isNotEmpty) {
          formData['owner_name'] = vehicle.ownerName;
        }
        // For a Tractor the vehicle number IS the registered number, so a
        // separate registered_no is redundant — only fill it for Trucks.
        if (formData['vehicle_type'] == 'Truck' &&
            (vehicle.registeredNo ?? '').isNotEmpty) {
          formData['registered_no'] = vehicle.registeredNo;
        }
        // Rebuild the form so auto-filled values render.
        stateKey = DateTime.now().toIso8601String();
      });
    });
  }

  Future<void> _blacklistVehicle() async {
    final number = formData['vehicle_number']?.toString().trim() ?? '';
    if (number.isEmpty) {
      showSnackBar("Enter vehicle number first");
      return;
    }

    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Blacklist Vehicle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Blacklist "$number"? Only admin can remove it later.'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Blacklist'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = await ApiService.blacklistVehicle(number, reasonController.text);
    if (ok && mounted) {
      setState(() => _isBlacklisted = true);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (formData['vehicle_type'] == null) {
      showSnackBar("Please select vehicle type");
      return;
    }

    if (_isBlacklisted) {
      showSnackBar("Vehicle is blacklisted. Entry not allowed.");
      return;
    }

    setState(() => _isLoading = true);

    final tokenData = {
      ...formData,
      'status': _status,
      'tare_weight': double.tryParse('${formData['tare_weight']}') ?? 0,
      'advance_amount': double.tryParse('${formData['advance_amount']}') ?? 0,
    };

    if (tokenData['vehicle_type'] != "Truck") {
      if (formData['tractor_type'] == null) {
        showSnackBar("Please select tractor type");
        setState(() => _isLoading = false);
        return;
      }

      tokenData['status'] = 'completed';
      tokenData['vehicle_type'] =
          "${formData['vehicle_type']}-${formData['tractor_type']}";

      // For Tractor-Local, capture the split payment + identity fields.
      if (formData['tractor_type'] == 'Local') {
        final cash = double.tryParse('${formData['cash_amount']}') ?? 0;
        final phonepay = double.tryParse('${formData['phonepay_amount']}') ?? 0;
        tokenData['cash_amount'] = cash;
        tokenData['phonepay_amount'] = phonepay;
        // advance_amount mirrors the collected total for report sums.
        tokenData['advance_amount'] = cash + phonepay;
        tokenData['payment_method'] = _derivePaymentMethod(cash, phonepay);
      }
    } else {
      if ((formData['payment_method'] == null)) {
        showSnackBar("Please choose mode");
        setState(() => _isLoading = false);
        return;
      }

      if (formData['credit_party'] == null &&
          (formData['payment_method'] == 'Credit')) {
        showSnackBar("Please choose credit party");
        setState(() => _isLoading = false);
        return;
      }
      if ((double.tryParse("${formData['advance_amount']}") ?? 0) <= 0 &&
          (formData['payment_method'] != 'Credit')) {
        showSnackBar("Please enter advance payment");
        setState(() => _isLoading = false);
        return;
      }
    }

    final res = await ApiService.createToken(tokenData);

    if (res != null) {
      MyPrintService(
        tokenModel: res,
        formatType: PrintFormatType.entry,
      ).printJob();

      _formKey.currentState?.reset();
      formData.clear();
      formData['payment_method'] = "Cash";
      setState(() {
        _isBlacklisted = false;
        stateKey = DateTime.now().toIso8601String();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _derivePaymentMethod(double cash, double phonepay) {
    if (cash > 0 && phonepay > 0) return 'Cash+PhonePay';
    if (phonepay > 0) return 'PhonePay';
    if (cash > 0) return 'Cash';
    return 'Cash';
  }

  /// Vehicle number field shared by Truck + Tractor-Local, with auto-fill and a
  /// blacklist action. Shows a red banner when the vehicle is blacklisted.
  Widget _vehicleNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextInput(
          keyName: 'vehicle_number',
          hint: 'Vehicle Number',
          initData: formData,
          context: context,
          capitalized: true,
          edit: true,
          requiredField: true,
          onChanged: _onVehicleNumberChanged,
          suffixIcon: IconButton(
            tooltip: 'Blacklist this vehicle',
            icon: const Icon(Icons.block, color: Colors.red),
            onPressed: _blacklistVehicle,
          ),
        ),
        if (_isBlacklisted)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This vehicle is blacklisted. Entry is not allowed. '
                    'Only admin can remove it.',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final saveDisabled = _isLoading || _isBlacklisted;
    return Scaffold(
      appBar: AppBar(title: const Text('New Token Entry')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              key: Key(stateKey),
              children: [
                RadioInput(
                  list: ["Tractor", "Truck"],
                  initData: formData,
                  keyName: "vehicle_type",
                  onChanged: () {
                    setState(() {});
                  },
                  hint: "Type",
                ),

                if (formData['vehicle_type'] == 'Truck')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _vehicleNumberField(),
                      TextInput(
                        keyName: 'customer_name',
                        hint: 'Customer Name',
                        initData: formData,
                        context: context,
                        capitalized: true,
                        edit: true,
                        requiredField: true,
                      ),
                      TextInput(
                        keyName: 'owner_name',
                        hint: 'Owner Name',
                        initData: formData,
                        context: context,
                        capitalized: true,
                        edit: true,
                        requiredField: false,
                      ),

                      TextInput(
                        keyName: 'tare_weight',
                        hint: 'Tare Weight',
                        initData: formData,
                        context: context,
                        inputType: TextInputType.number,
                        edit: true,
                      ),
                      TextInput(
                        keyName: 'advance_amount',
                        hint: 'Advance Amount',
                        initData: formData,
                        requiredField: false,
                        context: context,
                        inputType: TextInputType.number,
                        edit: true,
                      ),
                      RadioInput(
                        list: ['Cash', 'Credit', 'PhonePay'],
                        initData: formData,
                        keyName: 'payment_method',

                        hint: "Mode",
                        onChanged: () {
                          setState(() {});
                        },
                      ),

                      if (formData['payment_method'] == 'Credit')
                        DropDownInputWidget(
                          list: creditParties
                              .map((e) => {'label': '$e', 'value': '$e'})
                              .toList(),
                          initData: formData,
                          fieldKey: 'credit_party',
                          setStateCallback: () {
                            setState(() {});
                          },
                          hint: "Credit",
                        ),

                      TextInput(
                        keyName: 'remark',
                        hint: 'Advance remark',
                        initData: formData,
                        context: context,
                        requiredField: false,
                        inputType: TextInputType.text,
                        edit: true,
                      ),
                    ],
                  )
                else if (formData['vehicle_type'] == 'Tractor')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RadioInput(
                        list: ["Local", "Non-Local"],
                        initData: formData,
                        keyName: "tractor_type",
                        onChanged: () {
                          setState(() {});
                        },
                        hint: "Tractor Type",
                      ),

                      // Tractor-Local captures full business data.
                      if (formData['tractor_type'] == 'Local')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _vehicleNumberField(),
                            TextInput(
                              keyName: 'owner_name',
                              hint: 'Owner Name',
                              initData: formData,
                              context: context,
                              capitalized: true,
                              edit: true,
                              requiredField: false,
                            ),
                            TextInput(
                              keyName: 'cash_amount',
                              hint: 'Cash Amount',
                              initData: formData,
                              context: context,
                              inputType: TextInputType.number,
                              edit: true,
                              requiredField: false,
                              onChanged: (_) => setState(() {}),
                            ),
                            TextInput(
                              keyName: 'phonepay_amount',
                              hint: 'PhonePay Amount',
                              initData: formData,
                              context: context,
                              inputType: TextInputType.number,
                              edit: true,
                              requiredField: false,
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                    ],
                  ),

                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: saveDisabled ? null : _submit,
                  icon: const Icon(Icons.save),
                  label: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Token'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
