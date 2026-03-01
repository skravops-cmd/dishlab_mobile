import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/receipt.dart';
import '../../receipts_service.dart';
import '../edit_receipt_page.dart';

class ReceiptCard extends StatefulWidget {
  final Receipt receipt;
  final ReceiptsService service;
  final VoidCallback onRefresh;

  const ReceiptCard({
    super.key,
    required this.receipt,
    required this.service,
    required this.onRefresh,
  });

  @override
  State<ReceiptCard> createState() => _ReceiptCardState();
}

class _ReceiptCardState extends State<ReceiptCard> {
  Future<void> _openYoutube(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.all(16),
        title: Text(
          widget.receipt.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              widget.receipt.cuisine.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.receipt.ingredients.join(", "),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),

        // 👇 EXPANDED CONTENT
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Ingredients",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),

          ...widget.receipt.ingredients
              .map(
                (i) =>
                    Align(alignment: Alignment.centerLeft, child: Text("• $i")),
              )
              .toList(),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _openYoutube(widget.receipt.youtubeLink),
                icon: const Icon(Icons.play_circle_fill),
                label: const Text("Watch"),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditReceiptPage(
                        receipt: widget.receipt,
                        service: widget.service,
                      ),
                    ),
                  );

                  if (result == true) widget.onRefresh();
                },
                icon: const Icon(Icons.edit),
                label: const Text("Edit"),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await widget.service.deleteReceipt(widget.receipt.id);
                  widget.onRefresh();
                },
                icon: const Icon(Icons.delete),
                label: const Text("Delete"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
