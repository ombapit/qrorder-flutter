import 'package:flutter_pos/config/constants.dart';
import 'package:flutter_pos/providers/appid_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/order_provider.dart';

class TransactionService {
  static const String baseUrl = ApiConfig.baseUrl;

  // Function to insert transaction to API
  static Future<int?> insertTransaction(
    AppIdProvider appid,
    OrderProvider order,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/transactions');

      // Prepare cart data
      List<Map<String, dynamic>> cartData = order.cart.values
          .map(
            (c) => {
              'product_id': int.parse(c.product.id),
              'price': c.product.price,
              'qty': c.qty,
              'subtotal': c.subtotal,
            },
          )
          .toList();

      final body = {
        'outlet_meja_id': int.parse(appid.id),
        'buyer_name': order.buyerName,
        'buyer_phone': '+62${order.buyerPhone}',
        'total': order.total_price,
        'total_tax': order.total_tax.toInt(),
        'total_service': order.total_service.toInt(),
        'grand_total': order.trx_nominal.toInt(),
        'created_at': DateTime.now().toIso8601String(),
        'transaction_detail': cartData,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['data']['id']; // kembalikan ID
      }
      return null;
    } catch (e) {
      print('Error inserting transaction: $e');
      return null;
    }
  }

  // update trx
  static Future<bool> updateTransaction(
    AppIdProvider appid,
    OrderProvider order,
    int id,
    String paymentType,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/transactions/status/$id');

      final body = {'payment_type': paymentType};

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating transaction: $e');
      return false;
    }
  }
}
