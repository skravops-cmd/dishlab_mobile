import 'package:flutter/material.dart';
import '../models/receipt.dart';
import '../receipts_service.dart';
import 'create_receipt_page.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text("Error: $_error"))
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
                      trailing: IconButton(
                        icon: const Icon(Icons.play_circle_fill),
                        onPressed: () async {
                          final uri = Uri.parse(r.youtubeLink);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Could not open YouTube link"),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!mounted) return;
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateReceiptPage(service: _service),
            ),
          );
          if (result == true) {
            _loadDashboard();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
