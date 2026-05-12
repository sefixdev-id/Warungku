import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
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

  Future<String> uploadProductImage({
    required String adminId,
    required String fileName,
    required String mimeType,
    required List<int> bytes,
  }) async {
    debugPrint(
      'Warungku uploadProductImage URL: ${AppConstants.googleAppsScriptUrl}',
    );
    final response = await _apiService.post(
      action: 'uploadProductImage',
      forceJsonPost: true,
      body: {
        'adminId': adminId,
        'fileName': fileName,
        'mimeType': mimeType,
        'base64Data': base64Encode(bytes),
      },
    );
    if (!response.success) {
      throw Exception(
        response.message.isEmpty
            ? 'Upload gambar gagal tanpa detail dari server'
            : response.message,
      );
    }
    if (response.data == null) {
      throw Exception(
        'Upload gambar berhasil tetapi URL gambar tidak dikirim server',
      );
    }
    final data = Map<String, dynamic>.from(response.data);
    final imageUrl = data['imageUrl']?.toString() ?? '';
    if (imageUrl.isEmpty) {
      throw Exception('Upload gambar berhasil tetapi imageUrl kosong');
    }
    return imageUrl;
  }

  Future<String> testDriveAccess(String adminId) async {
    final response = await _apiService.post(
      action: 'testDriveAccess',
      body: {'adminId': adminId},
      forceJsonPost: true,
    );
    return response.message;
  }

  Future<String> testUploadSmallImage(String adminId) async {
    final response = await _apiService.post(
      action: 'testUploadSmallImage',
      body: {'adminId': adminId},
      forceJsonPost: true,
    );
    return response.message;
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
