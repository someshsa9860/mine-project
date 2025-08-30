import 'package:flutter/material.dart';
import 'package:gmineapp/print/bluetooth_print.dart';
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

  String stateKey = DateTime.now().toIso8601String();

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (formData['vehicle_type'] == null) {
      showSnackBar("Please select vehicle type");
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
      BluetoothPrint(
        tokenModel: res,
        formatType: PrintFormatType.entry,
      ).printJob();

      _formKey.currentState?.reset();
      formData.clear();
      setState(() {
        stateKey = DateTime.now().toIso8601String();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      TextInput(
                        keyName: 'vehicle_number',
                        hint: 'Vehicle Number',
                        initData: formData,
                        context: context,
                        capitalized: true,
                        edit: true,
                        requiredField: true,
                      ),
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
                    ],
                  ),

                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _submit,
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
