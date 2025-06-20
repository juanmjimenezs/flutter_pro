import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../database_service.dart';
import '../auth_service.dart';
import 'dart:math';
import 'position_detail_page.dart';
import '../widgets/buy_form.dart';
import '../utils/date_formatter.dart';

class AssetPositionsPage extends StatefulWidget {
  final String portfolioId;
  final String asset;
  final String currency;

  const AssetPositionsPage({
    super.key,
    required this.portfolioId,
    required this.asset,
    required this.currency,
  });

  @override
  State<AssetPositionsPage> createState() => _AssetPositionsPageState();
}

class _AssetPositionsPageState extends State<AssetPositionsPage> {
  List<Map<String, dynamic>> _openPositions = [];
  List<Map<String, dynamic>> _closedPositions = [];
  String get _userId => authService.value.currentUser?.uid ?? '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  Future<void> _loadPositions() async {
    setState(() {
      _loading = true;
    });
    if (_userId.isEmpty) return;
    DataSnapshot? snapshot = await DatabaseService().read(
      path: 'users/$_userId/portfolios/${widget.portfolioId}/buy',
    );
    List<Map<String, dynamic>> open = [];
    List<Map<String, dynamic>> closed = [];
    if (snapshot?.value != null && snapshot!.value is Map) {
      (snapshot.value as Map<Object?, Object?>).forEach((key, value) {
        if (value is Map && value['asset'] == widget.asset) {
          final buy = Map<String, dynamic>.from(value);
          buy['id'] = key.toString();
          double unitsBought = double.tryParse(buy['units'].toString()) ?? 0.0;
          double unitsSold = 0.0;
          List<Map<String, dynamic>> sales = [];
          if (buy['sell'] is Map) {
            (buy['sell'] as Map).forEach((_, v) {
              if (v is Map && v['units'] != null) {
                final sale = Map<String, dynamic>.from(v);
                sales.add(sale);
                unitsSold += double.tryParse(sale['units'].toString()) ?? 0.0;
              }
            });
          }
          buy['sales'] = sales;
          buy['unitsSold'] = unitsSold;
          buy['unitsRemaining'] = max(0, unitsBought - unitsSold);
          if (unitsSold >= unitsBought && unitsBought > 0) {
            closed.add(buy);
          } else {
            open.add(buy);
          }
        }
      });
    }
    setState(() {
      _openPositions = open;
      _closedPositions = closed;
      _loading = false;
    });
  }

  double _calculateProfit(Map<String, dynamic> buy) {
    // Total profit of the position (if closed)
    double totalBuy =
        (double.tryParse(buy['units'].toString()) ?? 0.0) *
            (double.tryParse(buy['unitValue'].toString()) ?? 0.0) +
        (double.tryParse(buy['commission'].toString()) ?? 0.0);
    double totalSale = 0.0;
    if (buy['sales'] is List) {
      for (final sale in buy['sales']) {
        totalSale +=
            (double.tryParse(sale['units'].toString()) ?? 0.0) *
                (double.tryParse(sale['unitValue'].toString()) ?? 0.0) -
            (double.tryParse(sale['commission'].toString()) ?? 0.0);
      }
    }
    if (totalBuy == 0) return 0.0;
    return ((totalSale - totalBuy) / totalBuy) * 100;
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
              assets: [widget.asset],
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
    await _loadPositions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.asset)),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_openPositions.isNotEmpty) ...[
                    const Text(
                      'Open positions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._openPositions.map(
                      (p) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            '${p['units']} shares at ${double.parse(p['unitValue'].toString()).toStringAsFixed(2)} ${widget.currency}',
                          ),
                          subtitle: Text(formatDate(p['date'])),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => PositionDetailPage(
                                      portfolioId: widget.portfolioId,
                                      buyId: p['id'],
                                      asset: widget.asset,
                                      currency: widget.currency,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_closedPositions.isNotEmpty) ...[
                    const Text(
                      'Closed positions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._closedPositions.map(
                      (p) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            '${p['units']} → Profit ${_calculateProfit(p).toStringAsFixed(1)}%',
                          ),
                          subtitle: Text(formatDate(p['date'])),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => PositionDetailPage(
                                      portfolioId: widget.portfolioId,
                                      buyId: p['id'],
                                      asset: widget.asset,
                                      currency: widget.currency,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  if (_openPositions.isEmpty && _closedPositions.isEmpty)
                    const Center(child: Text('No positions registered')),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBuyForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
