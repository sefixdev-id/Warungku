import 'dart:convert';

import '../models/product_model.dart';
import 'api_service.dart';

class ProductService {
  ProductService(this._apiService);

  final ApiService _apiService;

  Future<List<ProductModel>> getProducts({
    String? search,
    String? categoryId,
  }) async {
    final response = await _apiService.post(
      action: search == null || search.isEmpty
          ? 'getProducts'
          : 'searchProducts',
      body: {
        if (search != null && search.isNotEmpty) 'query': search,
        if (categoryId != null && categoryId.isNotEmpty)
          'categoryId': categoryId,
      },
    );
    if (!response.success) return [];
    return (response.data as List? ?? [])
        .whereType<Map>()
        .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ProductModel?> getProductById(String id) async {
    final response = await _apiService.post(
      action: 'getProductById',
      body: {'id': id},
    );
    if (!response.success || response.data == null) return null;
    return ProductModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<String> saveProduct({
    required Map<String, dynamic> product,
    required String adminId,
    bool isEdit = false,
  }) async {
    final response = await _apiService.post(
      action: isEdit ? 'updateProduct' : 'addProduct',
      body: {'adminId': adminId, ...product},
    );
    return response.message;
  }

  Future<String?> uploadProductImage({
    required String adminId,
    required String fileName,
    required String mimeType,
    required List<int> bytes,
  }) async {
    final response = await _apiService.post(
      action: 'uploadProductImage',
      body: {
        'adminId': adminId,
        'fileName': fileName,
        'mimeType': mimeType,
        'base64Data': base64Encode(bytes),
      },
    );
    if (!response.success || response.data == null) return null;
    final data = Map<String, dynamic>.from(response.data);
    return data['imageUrl']?.toString();
  }

  Future<String> updateStock({
    required String adminId,
    required String productId,
    required num qty,
    required String type,
    String note = '',
  }) async {
    final response = await _apiService.post(
      action: 'updateStock',
      body: {
        'adminId': adminId,
        'productId': productId,
        'qty': qty,
        'type': type,
        'note': note,
      },
    );
    return response.message;
  }

  Future<List<ProductModel>> getLowStockProducts(String adminId) async {
    final response = await _apiService.post(
      action: 'getLowStockProducts',
      body: {'adminId': adminId},
    );
    if (!response.success) return [];
    return (response.data as List? ?? [])
        .whereType<Map>()
        .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
