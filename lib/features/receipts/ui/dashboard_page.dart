import 'package:flutter/material.dart';
import '../../auth/ui/login_page.dart';
import '../models/receipt.dart';
import '../receipts_service.dart';
import 'create_receipt_page.dart';
import 'edit_receipt_page.dart';
import 'widgets/receipt_card.dart';

class DashboardPage extends StatefulWidget {
  final String token;

  const DashboardPage({super.key, required this.token});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final ReceiptsService _service;

  List<Receipt> _receipts = [];
  bool _loading = true;
  String? _error;

  // 🔎 Filters
  final TextEditingController _ingredientCtrl = TextEditingController();
  String? _selectedCuisine;
  bool _matchAll = false;
  bool _isSearching = false;

  final List<String> _cuisineOptions = [
    "italian",
    "asian",
    "mexican",
    "indian",
    "american",
    "french",
    "mediterranean",
  ];

  @override
  void initState() {
    super.initState();
    _service = ReceiptsService(token: widget.token);
    _fetchData();
  }

  Future<void> _fetchData({bool isSearch = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = isSearch
          ? await _service.searchReceipts(
              ingredients: _ingredientCtrl.text.trim().isEmpty
                  ? null
                  : _ingredientCtrl.text.trim(),
              cuisine: _selectedCuisine,
              matchAll: _matchAll,
            )
          : await _service.getDashboard();

      if (!mounted) return;

      setState(() {
        _receipts = data;
        _isSearching = isSearch;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Failed to load recipes. Please try again.";
      });
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _clearFilters() {
    _ingredientCtrl.clear();
    setState(() {
      _selectedCuisine = null;
      _matchAll = false;
    });
    _fetchData();
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _navigateToForm({Receipt? receipt}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => receipt == null
            ? CreateReceiptPage(service: _service)
            : EditReceiptPage(receipt: receipt, service: _service),
      ),
    );

    if (result == true) {
      _fetchData(isSearch: _isSearching);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Kitchen Lab"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildErrorWidget()
                : _receipts.isEmpty
                ? _buildEmptyWidget()
                : _buildReceiptList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        label: const Text("Add Recipe"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // ================================
  // FILTER SECTION
  // ================================

  Widget _buildFilterSection() {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(_isSearching ? "Filters Active" : "Search & Filter"),
        leading: Icon(
          Icons.filter_list,
          color: _isSearching ? Colors.orange : null,
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: [
          TextField(
            controller: _ingredientCtrl,
            decoration: const InputDecoration(
              labelText: "Ingredients",
              hintText: "e.g. cheese, tomato",
              prefixIcon: Icon(Icons.restaurant_menu),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedCuisine,
            decoration: const InputDecoration(labelText: "Cuisine Type"),
            items: _cuisineOptions
                .map(
                  (c) =>
                      DropdownMenuItem(value: c, child: Text(c.toUpperCase())),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedCuisine = v),
          ),
          Row(
            children: [
              Checkbox(
                value: _matchAll,
                onChanged: (v) => setState(() => _matchAll = v ?? false),
              ),
              const Text("Match all ingredients"),
              const Spacer(),
              TextButton(onPressed: _clearFilters, child: const Text("Reset")),
              ElevatedButton(
                onPressed: () => _fetchData(isSearch: true),
                child: const Text("Apply"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================
  // RECEIPT LIST
  // ================================

  Widget _buildReceiptList() {
    return RefreshIndicator(
      onRefresh: () => _fetchData(isSearch: _isSearching),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _receipts.length,
        itemBuilder: (context, index) {
          final receipt = _receipts[index];

          return ReceiptCard(
            receipt: receipt,
            service: _service,
            onRefresh: () => _fetchData(isSearch: _isSearching),
          );
        },
      ),
    );
  }

  // ================================
  // EMPTY STATE
  // ================================

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "No recipes found.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          if (_isSearching)
            TextButton(
              onPressed: _clearFilters,
              child: const Text("Clear Filters"),
            ),
        ],
      ),
    );
  }

  // ================================
  // ERROR STATE
  // ================================

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
          ElevatedButton(
            onPressed: () => _fetchData(),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
