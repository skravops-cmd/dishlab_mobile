import 'package:flutter/material.dart';
import '../receipts_service.dart';

const cuisines = [
  "Italian",
  "Asian",
  "Mexican",
  "Indian",
  "American",
  "French",
  "Mediterranean",
];

class CreateReceiptPage extends StatefulWidget {
  final ReceiptsService service;
  const CreateReceiptPage({super.key, required this.service});

  @override
  State<CreateReceiptPage> createState() => _CreateReceiptPageState();
}

class _CreateReceiptPageState extends State<CreateReceiptPage> {
  final _nameCtrl = TextEditingController();
  final _ingredientsCtrl = TextEditingController();
  final _youtubeCtrl = TextEditingController();
  String? _selectedCuisine;
  bool _loading = false;
  String? _error;

  Future<void> _createReceipt() async {
    if (_selectedCuisine == null) {
      setState(() => _error = "Select a cuisine");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.service.addReceipt(
        name: _nameCtrl.text,
        cuisine: _selectedCuisine!,
        ingredients: _ingredientsCtrl.text,
        youtubeLink: _youtubeCtrl.text,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
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
      appBar: AppBar(title: const Text("Create Receipt")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Cuisine"),
              items: cuisines
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCuisine = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ingredientsCtrl,
              decoration: const InputDecoration(
                labelText: "Ingredients (comma separated)",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _youtubeCtrl,
              decoration: const InputDecoration(labelText: "YouTube link"),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading ? null : _createReceipt,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Create Receipt"),
            ),
          ],
        ),
      ),
    );
  }
}
