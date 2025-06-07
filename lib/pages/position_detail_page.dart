import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../database_service.dart';
import '../auth_service.dart';
import '../widgets/sell_form.dart';

class PositionDetailPage extends StatefulWidget {
  final String portfolioId;
  final String buyId;
  final String asset;
  final String currency;

  const PositionDetailPage({
    super.key,
    required this.portfolioId,
    required this.buyId,
    required this.asset,
    required this.currency,
  });

  @override
  State<PositionDetailPage> createState() => _PositionDetailPageState();
}

class _PositionDetailPageState extends State<PositionDetailPage> {
  Map<String, dynamic>? _buy;
  List<Map<String, dynamic>> _sales = [];
  bool _loading = true;
  String get _userId => authService.value.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
    });
    if (_userId.isEmpty) return;
    DataSnapshot? snapshot = await DatabaseService().read(
      path:
          'users/$_userId/portfolios/${widget.portfolioId}/buy/${widget.buyId}',
    );
    if (snapshot?.value != null && snapshot!.value is Map) {
      final buy = Map<String, dynamic>.from(snapshot.value as Map);
      List<Map<String, dynamic>> sales = [];
      if (buy['sell'] is Map) {
        (buy['sell'] as Map).forEach((_, v) {
          if (v is Map) {
            sales.add(Map<String, dynamic>.from(v));
          }
        });
      }
      setState(() {
        _buy = buy;
        _sales = sales;
        _loading = false;
      });
    } else {
      setState(() {
        _buy = null;
        _sales = [];
        _loading = false;
      });
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }

  double _calculateProfit(Map<String, dynamic> sale) {
    if (_buy == null) return 0.0;
    double units = double.tryParse(sale['units'].toString()) ?? 0.0;
    double saleUnitValue = double.tryParse(sale['unitValue'].toString()) ?? 0.0;
    double saleCommission =
        double.tryParse(sale['commission'].toString()) ?? 0.0;
    double buyUnitValue = double.tryParse(_buy!['unitValue'].toString()) ?? 0.0;
    double buyCommission =
        double.tryParse(_buy!['commission'].toString()) ?? 0.0;
    double totalBuy =
        (units * buyUnitValue) +
        (buyCommission *
            (units / (double.tryParse(_buy!['units'].toString()) ?? 1)));
    double totalSale = (units * saleUnitValue) - saleCommission;
    if (totalBuy == 0) return 0.0;
    return ((totalSale - totalBuy) / totalBuy) * 100;
  }

  void _showSellForm() {
    if (_buy == null) return;
    final double maxUnits =
        ((double.tryParse(_buy!['units'].toString()) ?? 0.0) -
            (_sales.fold(
              0.0,
              (a, v) => a + (double.tryParse(v['units'].toString()) ?? 0.0),
            )));
    if (maxUnits <= 0) return;
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
            child: SellForm(
              maxUnits: maxUnits,
              currency: widget.currency,
              onSubmit: (units, unitValue, commission, date) async {
                Navigator.pop(context);
                await _addSell(units, unitValue, commission, date);
              },
            ),
          ),
    );
  }

  Future<void> _addSell(
    double units,
    double unitValue,
    double commission,
    DateTime date,
  ) async {
    if (_userId.isEmpty) return;
    final newSell = {
      'units': units,
      'unitValue': unitValue,
      'commission': commission,
      'date': date.toIso8601String(),
    };
    await DatabaseService().create(
      path:
          'users/$_userId/portfolios/${widget.portfolioId}/buy/${widget.buyId}/sell',
      data: newSell,
    );
    await _loadDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.asset} - Position detail')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _buy == null
              ? const Center(child: Text('Position not found'))
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text('Buy: ${_buy!['units']} units'),
                      subtitle: Text(
                        'Unit value: ${_buy!['unitValue']} ${widget.currency}\nCommission: ${_buy!['commission']} ${widget.currency}\nDate: ${_formatDate(_buy!['date'])}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Associated sales',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (_sales.isEmpty) const Text('No sales registered'),
                  ..._sales.map(
                    (v) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            '${_calculateProfit(v).toStringAsFixed(0)}%',
                          ),
                        ),
                        title: Text(
                          '${v['units']} units at ${v['unitValue']} ${widget.currency}',
                        ),
                        subtitle: Text(
                          'Commission: ${v['commission']} ${widget.currency}\nDate: ${_formatDate(v['date'])}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSellForm,
        child: const Icon(Icons.remove),
      ),
    );
  }
}
