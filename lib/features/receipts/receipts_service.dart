import 'data/receipts_api.dart';
import 'models/receipt.dart';

class ReceiptsService {
  final String token;

  ReceiptsService({required this.token});

  Future<List<Receipt>> getDashboard() async {
    return await ReceiptsApi.fetchDashboard(token);
  }

  Future<void> addReceipt({
    required String name,
    required String cuisine,
    required String ingredients,
    required String youtubeLink,
  }) async {
    await ReceiptsApi.createReceipt(
      token: token,
      name: name,
      cuisine: cuisine,
      ingredients: ingredients,
      youtubeLink: youtubeLink,
    );
  }

  Future<void> deleteReceipt(String receiptId) async {
    await ReceiptsApi.deleteReceipt(token: token, receiptId: receiptId);
  }
}
