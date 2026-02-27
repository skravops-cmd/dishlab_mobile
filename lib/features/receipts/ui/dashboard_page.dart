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

  // 🔍 Search state
  final TextEditingController _searchCtrl = TextEditingController();
  bool _matchAll = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _service = ReceiptsService(token: widget.token);
    _loadDashboard();
  }

  // =============================
  // LOAD DASHBOARD
  // =============================
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

  // =============================
  // SEARCH
  // =============================
  Future<void> _search() async {
    if (_searchCtrl.text.trim().isEmpty) {
      _loadDashboard();
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _isSearching = true;
    });

    try {
      final results = await _service.searchReceipts(
        ingredients: _searchCtrl.text.trim(),
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

  void _clearSearch() {
    _searchCtrl.clear();
    _matchAll = false;
    _loadDashboard();
  }

  // =============================
  // DELETE
  // =============================
  Future<void> _deleteReceipt(int index) async {
    final receipt = _receipts[index];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Receipt"),
        content: Text("Delete '${receipt.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.deleteReceipt(receipt.id);

      if (!mounted) return;

      setState(() {
        _receipts.removeAt(index);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Receipt deleted")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
    }
  }

  // =============================
  // YOUTUBE
  // =============================
  Future<void> _openYoutube(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open link")));
    }
  }

  // =============================
  // LOGOUT
  // =============================
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // =============================
  // UI
  // =============================
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
          // 🔍 SEARCH SECTION
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: "Search ingredients (cheese,tomato)",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isSearching
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (_) => _search(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _matchAll,
                      onChanged: (v) => setState(() => _matchAll = v ?? false),
                    ),
                    const Text("Match ALL"),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _loading ? null : _search,
                      child: const Text("Search"),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 📋 LIST SECTION
          Expanded(
            child: RefreshIndicator(
              onRefresh: _isSearching ? _search : _loadDashboard,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text("Error: $_error"))
                  : _receipts.isEmpty
                  ? Center(
                      child: Text(
                        _isSearching
                            ? "No matching receipts"
                            : "No receipts yet",
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _receipts.length,
                      itemBuilder: (context, index) {
                        final r = _receipts[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
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
