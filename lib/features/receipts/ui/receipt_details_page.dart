import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/receipt.dart';
import '../receipts_service.dart';
import 'edit_receipt_page.dart';

class ReceiptDetailsPage extends StatelessWidget {
  final Receipt receipt;
  final ReceiptsService service;

  const ReceiptDetailsPage({
    super.key,
    required this.receipt,
    required this.service,
  });

  Future<void> _openYoutube(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(receipt.name)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              receipt.cuisine.toUpperCase(),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            const Text(
              "Ingredients",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ...receipt.ingredients.map(
              (i) => Text("• $i"),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () => _openYoutube(receipt.youtubeLink),
              icon: const Icon(Icons.play_circle_fill),
              label: const Text("Watch on YouTube"),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditReceiptPage(
                      receipt: receipt,
                      service: service,
                    ),
                  ),
                );

                if (result == true && context.mounted) {
                  Navigator.pop(context, true);
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text("Edit"),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await service.deleteReceipt(receipt.id);
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              },
              icon: const Icon(Icons.delete),
              label: const Text("Delete"),
            ),
          ],
        ),
      ),
    );
  }
}
