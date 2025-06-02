import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../database_service.dart';
import '../auth_service.dart';
import '../data/currency.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});
  static const String title = 'Portfolio';

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  List<Map<String, dynamic>> _portfolios = [];

  String get _userId => authService.value.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadPortfolios();
  }

  Future<void> _loadPortfolios() async {
    if (_userId.isEmpty) return;
    DataSnapshot? snapshot = await DatabaseService().read(
      path: 'users/$_userId/portfolios',
    );
    if (snapshot?.value != null) {
      setState(() {
        if (snapshot!.value is Map) {
          _portfolios =
              (snapshot.value as Map<Object?, Object?>).entries.map((entry) {
                if (entry.value is Map) {
                  final data = Map<String, dynamic>.from(entry.value as Map);
                  data['id'] = entry.key.toString();
                  return data;
                }
                return <String, dynamic>{};
              }).toList();
        } else {
          _portfolios = [];
        }
      });
    }
  }

  Future<void> _addPortfolio(
    String name,
    String description,
    String currency,
  ) async {
    if (_userId.isEmpty) return;
    final newPortfolio = {
      'name': name,
      'description': description,
      'currency': currency,
    };
    await DatabaseService().create(
      path: 'users/$_userId/portfolios',
      data: newPortfolio,
    );
    await _loadPortfolios();
  }

  void _showAddPortfolioDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 32,
            ),
            child: _PortfolioForm(
              onCreate: (name, description, currency) async {
                Navigator.pop(context);
                await _addPortfolio(name, description, currency);
              },
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _portfolios.length,
        itemBuilder: (context, index) {
          final p = _portfolios[index];
          return Card(
            color: Colors.purple[50],
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: Text(
                p['name'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(p['description'] ?? ''),
              trailing: Text(
                p['currency'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPortfolioDialog,
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }
}

class _PortfolioForm extends StatefulWidget {
  final void Function(String name, String description, String currency)
  onCreate;
  const _PortfolioForm({required this.onCreate});

  @override
  State<_PortfolioForm> createState() => _PortfolioFormState();
}

class _PortfolioFormState extends State<_PortfolioForm> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Currency _selectedCurrency = currencies.firstWhere((c) => c.code == 'COP');

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
