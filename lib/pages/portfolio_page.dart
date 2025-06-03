import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../database_service.dart';
import '../auth_service.dart';
import '../widgets/portfolio_form.dart';

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
            child: PortfolioForm(
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
