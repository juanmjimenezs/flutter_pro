import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../database_service.dart';
import '../auth_service.dart';
import '../widgets/buy_form.dart';
import 'asset_positions_page.dart';

class PortfolioAssetsPage extends StatefulWidget {
  final String portfolioId;
  final String portfolioName;
  final String currency;

  const PortfolioAssetsPage({
    super.key,
    required this.portfolioId,
    required this.portfolioName,
    required this.currency,
  });

  @override
  State<PortfolioAssetsPage> createState() => _PortfolioAssetsPageState();
}

class _PortfolioAssetsPageState extends State<PortfolioAssetsPage> {
  Map<String, double> _assets = {}; // asset -> total units
  String get _userId => authService.value.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    if (_userId.isEmpty) return;
    DataSnapshot? snapshot = await DatabaseService().read(
      path: 'users/$_userId/portfolios/${widget.portfolioId}/buy',
    );
    if (snapshot?.value != null && snapshot!.value is Map) {
      final Map<String, double> assets = {};
      (snapshot.value as Map<Object?, Object?>).forEach((key, value) {
        if (value is Map && value['asset'] != null && value['units'] != null) {
          final asset = value['asset'] as String;
          final units = double.tryParse(value['units'].toString()) ?? 0.0;
          assets[asset] = (assets[asset] ?? 0) + units;
        }
      });
      setState(() {
        _assets = assets;
      });
    } else {
      setState(() {
        _assets = {};
      });
    }
  }

  void _showBuyForm() {
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
            child: BuyForm(
              assets: _assets.keys.toList(),
              currency: widget.currency,
              onSubmit: (asset, units, unitValue, commission, date) async {
                Navigator.pop(context);
                await _addBuy(asset, units, unitValue, commission, date);
              },
            ),
          ),
    );
  }

  Future<void> _addBuy(
    String asset,
    double units,
    double unitValue,
    double commission,
    DateTime date,
  ) async {
    if (_userId.isEmpty) return;
    final newBuy = {
      'asset': asset,
      'units': units,
      'unitValue': unitValue,
      'commission': commission,
      'date': date.toIso8601String(),
    };
    await DatabaseService().create(
      path: 'users/$_userId/portfolios/${widget.portfolioId}/buy',
      data: newBuy,
    );
    await _loadAssets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.portfolioName)),
      body:
          _assets.isEmpty
              ? const Center(child: Text('No assets registered'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _assets.length,
                itemBuilder: (context, index) {
                  final asset = _assets.keys.elementAt(index);
                  final units = _assets[asset]!;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        asset,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Units: $units'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => AssetPositionsPage(
                                  portfolioId: widget.portfolioId,
                                  asset: asset,
                                  currency: widget.currency,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBuyForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
