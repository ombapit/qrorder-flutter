import 'dart:convert';
import 'package:flutter_pos/config/constants.dart';
import 'package:http/http.dart' as http;
import '../models/outlet.dart';

class OutletService {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<Outlet> fetchOutlet(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/mejas/$id"));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final outlet = Outlet.fromJson(jsonBody['data']);

      return outlet;
    } else {
      throw Exception('Failed to load outlets: ${response.statusCode}');
    }
  }
}
