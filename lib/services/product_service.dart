import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/product.dart';
import 'auth_service.dart';

class ProductService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<List<Product>> getProducts() async {
    final url = Uri.https(AppConstants.baseUrl, AppConstants.productsEndpoint);
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data']?['products'] ?? [];
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<bool> addProduct(Product product) async {
    final url = Uri.https(AppConstants.baseUrl, AppConstants.productsEndpoint);
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode(product.toJson()),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> deleteProduct(int id) async {
    final url = Uri.https(AppConstants.baseUrl, '${AppConstants.productsEndpoint}/$id');
    final response = await http.delete(url, headers: await _getHeaders());

    return response.statusCode == 200;
  }

  Future<bool> submitAssignment(Product product, String githubUrl) async {
    final url = Uri.https(AppConstants.baseUrl, AppConstants.submitEndpoint);
    final body = product.toJson();
    body['github_url'] = githubUrl;

    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }
}
