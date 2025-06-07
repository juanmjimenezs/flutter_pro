import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BuyForm extends StatefulWidget {
  final List<String> assets;
  final String currency;
  final void Function(
    String asset,
    double units,
    double unitValue,
    double commission,
    DateTime date,
  )
  onSubmit;

  const BuyForm({
    super.key,
    required this.assets,
    required this.currency,
    required this.onSubmit,
  });

  @override
  State<BuyForm> createState() => _BuyFormState();
}

class _BuyFormState extends State<BuyForm> {
  final _formKey = GlobalKey<FormState>();
  final _assetController = TextEditingController();
  final _unitsController = TextEditingController();
  final _unitValueController = TextEditingController();
  final _commissionController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _assetController.dispose();
    _unitsController.dispose();
    _unitValueController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Wow! New asset?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return widget.assets.where((String option) {
                  return option.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                });
              },
              fieldViewBuilder: (
                context,
                textEditingController,
                focusNode,
                onEditingComplete,
              ) {
                return TextFormField(
                  controller: textEditingController,
                  enableSuggestions: false,
                  focusNode: focusNode,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (value) {
                    textEditingController.text = value.toUpperCase();
                    textEditingController
                        .selection = TextSelection.fromPosition(
                      TextPosition(offset: textEditingController.text.length),
                    );
                    _assetController.text = value.toUpperCase();
                  },
                  decoration: const InputDecoration(labelText: 'Asset'),
                  validator:
                      (v) => v == null || v.isEmpty ? 'Required field' : null,
                );
              },
              onSelected: (String selection) {
                _assetController.text = selection.toUpperCase();
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _unitsController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: '# of Units'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required field';
                final value = double.tryParse(v);
                if (value == null || value <= 0) {
                  return 'Must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _unitValueController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Unit value',
                suffixText: widget.currency,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required field';
                final value = double.tryParse(v);
                if (value == null || value <= 0) {
                  return 'Must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _commissionController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Commission',
                suffixText: widget.currency,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required field';
                final value = double.tryParse(v);
                if (value == null || value < 0) return 'Cannot be negative';
                return null;
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Buy date: ${_date.day}/${_date.month}/${_date.year}',
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Select date'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    widget.onSubmit(
                      _assetController.text.toUpperCase(),
                      double.parse(_unitsController.text),
                      double.parse(_unitValueController.text),
                      double.parse(_commissionController.text),
                      _date,
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
