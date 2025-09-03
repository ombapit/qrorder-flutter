import 'dart:convert';
import 'package:flutter_pos/config/constants.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  static const String baseUrl =
      "${ApiConfig.baseUrl}/products?date_field=created_at&limit=50&order=asc&page=1";

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List<dynamic> data = jsonBody['data'];

      // final products = data
      //     .map((item) {
      //       try {
      //         return Product.fromJson(item);
      //       } catch (e, s) {
      //         print("❌ Error parsing item: $item");
      //         print(e);
      //         return null; // sementara
      //       }
      //     })
      //     .where((p) => p != null)
      //     .toList();
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }
}
