import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_page.dart';
import 'transaction_history_page.dart';
import 'add_transaction_page.dart';

const Color _kBackgroundColor = Color(0xFFFAFAFA);

class HomePageUI extends StatefulWidget {
  final String tenantId;
  final String userRole;

  const HomePageUI({super.key, required this.tenantId, required this.userRole});

  @override
  State<HomePageUI> createState() => _HomePageUIState();
}

class _HomePageUIState extends State<HomePageUI> {
  String _currency1 = 'PHP';
  String _currency2 = 'JOD';
  double _balance1 = 0.0;
  double _balance2 = 0.0;
  bool _isLoading = true;
  String _companyName = 'Jhompay Tracker';

  final List<String> _availableCurrencies = ['PHP', 'JOD', 'USD', 'EUR', 'SAR', 'AED'];
  Map<String, double> _allBalances = {};

  List<String> _cashInOptions = [];
  List<String> _cashOutOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() => _isLoading = true);

      final companyDoc = await FirebaseFirestore.instance
          .collection('companySettings')
          .doc(widget.tenantId)
          .get();

      if (companyDoc.exists) {
        setState(() {
          _companyName = companyDoc.data()?['companyName'] ?? 'Jhompay Tracker';
        });
      }

      final currencyDoc = await FirebaseFirestore.instance
          .collection('currencyPreferences')
          .doc(widget.tenantId)
          .get();

      if (currencyDoc.exists) {
        final data = currencyDoc.data()!;
        _currency1 = data['currency1'] ?? 'PHP';
        _currency2 = data['currency2'] ?? 'JOD';
      }

      final balanceDoc = await FirebaseFirestore.instance
          .collection('accountBalances')
          .doc(widget.tenantId)
          .get();

      if (balanceDoc.exists) {
        final data = balanceDoc.data()!;
        final balancesData = data['balances'] as Map<String, dynamic>? ?? {};
        
        for (var currency in _availableCurrencies) {
          _allBalances[currency] = (balancesData[currency] ?? 0.0).toDouble();
        }
        
        _balance1 = _allBalances[_currency1] ?? 0.0;
        _balance2 = _allBalances[_currency2] ?? 0.0;
      }

      final optionsDoc = await FirebaseFirestore.instance
          .collection('transaction_options')
          .doc(widget.tenantId)
          .get();

      if (optionsDoc.exists) {
        final data = optionsDoc.data()!;
        _cashInOptions = (data['cash_in'] as List<dynamic>?)?.cast<String>() ?? [];
        _cashOutOptions = (data['cash_out'] as List<dynamic>?)?.cast<String>() ?? [];
      }

    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateCurrencyPreference(String currency, bool isFirst) async {
    try {
      final newCurrency1 = isFirst ? currency : _currency1;
      final newCurrency2 = isFirst ? _currency2 : currency;

      await FirebaseFirestore.instance
          .collection('currencyPreferences')
          .doc(widget.tenantId)
          .set({
        'currency1': newCurrency1,
        'currency2': newCurrency2,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        if (isFirst) {
          _currency1 = currency;
          _balance1 = _allBalances[currency] ?? 0.0;
        } else {
          _currency2 = currency;
          _balance2 = _allBalances[currency] ?? 0.0;
        }
      });

      await FirebaseFirestore.instance
          .collection('accountBalances')
          .doc(widget.tenantId)
          .set({
        'balance1': _balance1,
        'balance2': _balance2,
      }, SetOptions(merge: true));

    } catch (e) {
      debugPrint('Error updating currency preference: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating currency: $e')),
        );
      }
    }
  }

  void _onTransactionButtonPressed(String optionName, bool isCashIn) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddTransactionPage(
        tenantId: widget.tenantId,
        transactionType: isCashIn ? 'Cash In' : 'Cash Out',
        optionName: optionName,
      ),
    )).then((_) => _fetchData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 12),
                      _buildBalanceSection(),
                      const SizedBox(height: 16),
                      _buildTransactionOptionsCard(isCashIn: true),
                      const SizedBox(height: 16),
                      _buildTransactionOptionsCard(isCashIn: false),
                      const SizedBox(height: 16),
                      _buildSendPaymentButton(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4F5D75).withOpacity(0.7),
            const Color(0xFF6B7A94).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Settings Icon
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings_rounded, size: 24, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SettingsPage(tenantId: widget.tenantId),
                    )).then((_) => _fetchData());
                  },
                ),
              ),

              // Company Name with Icon
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: Color(0xFFD4AF37),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _companyName,
                        style: GoogleFonts.cinzel(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF4E4C1),
                          letterSpacing: 1.3,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.4),
                              offset: const Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // History Icon
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.history_rounded, size: 24, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TransactionHistoryPage(tenantId: widget.tenantId),
                    )).then((_) => _fetchData());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildBalanceCard(_currency1, _balance1, true)),
          Container(
            width: 1,
            height: 60,
            color: Colors.grey.withOpacity(0.3),
          ),
          Expanded(child: _buildBalanceCard(_currency2, _balance2, false)),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String currency, double balance, bool isFirst) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currency,
              icon: const Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey),
              isDense: true,
              isExpanded: true,
              alignment: Alignment.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              items: _availableCurrencies.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  alignment: Alignment.center,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null && newValue != currency) {
                  _updateCurrencyPreference(newValue, isFirst);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          NumberFormat.currency(symbol: '', decimalDigits: 2).format(balance),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTransactionOptionsCard({required bool isCashIn}) {
    final String title = isCashIn ? 'Cash In' : 'Cash Out';
    final List<String> options = isCashIn ? _cashInOptions : _cashOutOptions;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4F5D75).withOpacity(0.7),
                    const Color(0xFF6B7A94).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildTransactionButtons(options: options, isCashIn: isCashIn),
        ],
      ),
    );
  }

  Widget _buildTransactionButtons({required List<String> options, required bool isCashIn}) {
    final Color baseColor = isCashIn ? const Color(0xFF4CAF50) : const Color(0xFFE53935);

    if (options.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No options configured',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    List<Widget> rows = [];
    for (int i = 0; i < options.length; i += 2) {
      List<Widget> rowChildren = [];
      
      rowChildren.add(
        Expanded(
          child: _buildActionButton(
            text: options[i],
            onPressed: () => _onTransactionButtonPressed(options[i], isCashIn),
            color: baseColor,
          ),
        ),
      );

      if (i + 1 < options.length) {
        rowChildren.add(const SizedBox(width: 12));
        rowChildren.add(
          Expanded(
            child: _buildActionButton(
              text: options[i + 1],
              onPressed: () => _onTransactionButtonPressed(options[i + 1], isCashIn),
              color: baseColor,
            ),
          ),
        );
      } else {
        rowChildren.add(const SizedBox(width: 12));
        rowChildren.add(const Expanded(child: SizedBox()));
      }

      rows.add(Row(children: rowChildren));
      if (i + 2 < options.length) {
        rows.add(const SizedBox(height: 10));
      }
    }

    return Column(children: rows);
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildSendPaymentButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Send Payment',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}
