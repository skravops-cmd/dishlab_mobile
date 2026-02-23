import 'package:flutter/material.dart';
import '../models/receipt.dart';
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

class EditReceiptPage extends StatefulWidget {
  final Receipt receipt;
  final ReceiptsService service;

  const EditReceiptPage({
    super.key,
    required this.receipt,
    required this.service,
  });

  @override
  State<EditReceiptPage> createState() => _EditReceiptPageState();
}

class _EditReceiptPageState extends State<EditReceiptPage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _ingredientsCtrl;
  late TextEditingController _youtubeCtrl;
  String? _selectedCuisine;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.receipt.name);
    _ingredientsCtrl = TextEditingController(
      text: widget.receipt.ingredients.join(", "),
    );
    _youtubeCtrl = TextEditingController(text: widget.receipt.youtubeLink);
    _selectedCuisine = widget.receipt.cuisine;
  }

  Future<void> _updateReceipt() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.service.updateReceipt(
        receiptId: widget.receipt.id,
        name: _nameCtrl.text,
        cuisine: _selectedCuisine,
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
      appBar: AppBar(title: const Text("Edit Receipt")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCuisine,
              items: cuisines
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCuisine = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ingredientsCtrl,
              decoration: const InputDecoration(labelText: "Ingredients"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _youtubeCtrl,
              decoration: const InputDecoration(labelText: "YouTube link"),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading ? null : _updateReceipt,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Update Receipt"),
            ),
          ],
        ),
      ),
    );
  }
}
