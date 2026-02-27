import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/receipt.dart';
import '../receipts_service.dart';
import '../../auth/ui/login_page.dart';
import 'create_receipt_page.dart';
import 'edit_receipt_page.dart';

class DashboardPage extends StatefulWidget {
  final String token;
  const DashboardPage({super.key, required this.token});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late ReceiptsService _service;

  List<Receipt> _receipts = [];
  bool _loading = true;
  String? _error;

  // 🔍 Filters
  final TextEditingController _ingredientCtrl = TextEditingController();
  String? _selectedCuisine;
  bool _matchAll = false;
  bool _isSearching = false;

  final List<String> _cuisineOptions = [
    "italian",
    "mexican",
    "indian",
    "chinese",
    "american",
  ];

  @override
  void initState() {
    super.initState();
    _service = ReceiptsService(token: widget.token);
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
      _isSearching = false;
    });

    try {
      final data = await _service.getDashboard();
      if (!mounted) return;
      setState(() => _receipts = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
      _isSearching = true;
    });

    try {
      final results = await _service.searchReceipts(
        ingredients: _ingredientCtrl.text.trim().isEmpty
            ? null
            : _ingredientCtrl.text.trim(),
        cuisine: _selectedCuisine,
        matchAll: _matchAll,
      );

      if (!mounted) return;
      setState(() => _receipts = results);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _clearFilters() {
    _ingredientCtrl.clear();
    _selectedCuisine = null;
    _matchAll = false;
    _loadDashboard();
  }

  Future<void> _deleteReceipt(int index) async {
    final receipt = _receipts[index];
    await _service.deleteReceipt(receipt.id);
    if (!mounted) return;
    setState(() => _receipts.removeAt(index));
  }

  Future<void> _openYoutube(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _logout() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          // 🔎 FILTER SECTION
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _ingredientCtrl,
                  decoration: const InputDecoration(
                    labelText: "Ingredients (cheese,tomato)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: _selectedCuisine,
                  decoration: const InputDecoration(
                    labelText: "Cuisine",
                    border: OutlineInputBorder(),
                  ),
                  items: _cuisineOptions
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCuisine = value),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Checkbox(
                      value: _matchAll,
                      onChanged: (v) => setState(() => _matchAll = v ?? false),
                    ),
                    const Text("Match ALL ingredients"),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _search,
                      child: const Text("Search"),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text("Clear"),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 📋 LIST
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text("Error: $_error"))
                : _receipts.isEmpty
                ? const Center(child: Text("No results"))
                : RefreshIndicator(
                    onRefresh: _isSearching ? _search : _loadDashboard,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _receipts.length,
                      itemBuilder: (context, index) {
                        final r = _receipts[index];
                        return Card(
                          child: ListTile(
                            title: Text(r.name),
                            subtitle: Text(
                              "${r.cuisine} • ${r.ingredients.join(", ")}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.play_circle_fill),
                                  onPressed: () => _openYoutube(r.youtubeLink),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditReceiptPage(
                                          receipt: r,
                                          service: _service,
                                        ),
                                      ),
                                    );

                                    if (result == true) {
                                      _isSearching
                                          ? _search()
                                          : _loadDashboard();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteReceipt(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateReceiptPage(service: _service),
            ),
          );

          if (result == true) {
            _isSearching ? _search() : _loadDashboard();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
