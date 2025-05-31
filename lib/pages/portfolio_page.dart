import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../database_service.dart';
import '../auth_service.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

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
    String nombre,
    String descripcion,
    String moneda,
  ) async {
    if (_userId.isEmpty) return;
    final newPortfolio = {
      'nombre': nombre,
      'descripcion': descripcion,
      'moneda': moneda,
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
              onCreate: (nombre, descripcion, moneda) async {
                Navigator.pop(context);
                await _addPortfolio(nombre, descripcion, moneda);
              },
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[700],
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
                p['nombre'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(p['descripcion'] ?? ''),
              trailing: Text(
                p['moneda'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPortfolioDialog,
        backgroundColor: Colors.yellow[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _PortfolioForm extends StatefulWidget {
  final void Function(String nombre, String descripcion, String moneda)
  onCreate;
  const _PortfolioForm({required this.onCreate});

  @override
  State<_PortfolioForm> createState() => _PortfolioFormState();
}

class _PortfolioFormState extends State<_PortfolioForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _moneda = 'COP';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Nuevo portafolio?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Agrupa tus activos según estrategias, mercados o monedas',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nombreController,
          decoration: const InputDecoration(
            labelText: 'Nombre del portafolio',
            hintText: 'ej. "ETF tecnológicos", "Inversión a largo plazo"',
          ),
          validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descripcionController,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            hintText: 'ej. Portafolio de acciones colombianas',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CurrencyButton(
              label: 'COP',
              selected: _moneda == 'COP',
              onTap: () => setState(() => _moneda = 'COP'),
            ),
            const SizedBox(width: 8),
            _CurrencyButton(
              label: 'USD',
              selected: _moneda == 'USD',
              onTap: () => setState(() => _moneda = 'USD'),
            ),
            const SizedBox(width: 8),
            _CurrencyButton(
              label: 'EUR',
              selected: _moneda == 'EUR',
              onTap: () => setState(() => _moneda = 'EUR'),
            ),
          ],
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
              if (_nombreController.text.isNotEmpty) {
                widget.onCreate(
                  _nombreController.text,
                  _descripcionController.text,
                  _moneda,
                );
              }
            },
            child: const Text('Crear', style: TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _CurrencyButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CurrencyButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? Colors.yellow[700]! : Colors.transparent,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
