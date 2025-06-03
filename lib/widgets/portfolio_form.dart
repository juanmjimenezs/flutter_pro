import 'package:flutter/material.dart';
import '../data/currency.dart';

class PortfolioForm extends StatefulWidget {
  final void Function(String name, String description, String currency)
  onCreate;

  const PortfolioForm({super.key, required this.onCreate});

  @override
  State<PortfolioForm> createState() => _PortfolioFormState();
}

class _PortfolioFormState extends State<PortfolioForm> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Currency _selectedCurrency = currencies.firstWhere((c) => c.code == 'COP');

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'New Portfolio?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Group your assets by strategy, market, or currency',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Portfolio Name',
            hintText: 'e.g. "Tech ETFs", "Long-term Investment"',
          ),
          validator: (v) => v == null || v.isEmpty ? 'Required field' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'e.g. Colombian stocks portfolio',
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<Currency>(
          value: _selectedCurrency,
          decoration: const InputDecoration(
            labelText: 'Currency',
            border: OutlineInputBorder(),
          ),
          items:
              currencies.map((Currency currency) {
                return DropdownMenuItem<Currency>(
                  value: currency,
                  child: Text('${currency.code} - ${currency.name}'),
                );
              }).toList(),
          onChanged: (Currency? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCurrency = newValue;
              });
            }
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                widget.onCreate(
                  _nameController.text,
                  _descriptionController.text,
                  _selectedCurrency.code,
                );
              }
            },
            child: const Text('Create', style: TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
