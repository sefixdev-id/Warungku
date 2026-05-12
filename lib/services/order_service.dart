import '../models/order_model.dart';
import 'api_service.dart';

class OrderService {
  OrderService(this._apiService);

  final ApiService _apiService;

  Future<OrderModel?> createOrder({
    required String userId,
    required String productId,
    required num qty,
    required String orderType,
    required String paymentMethod,
    String addressId = '',
    String note = '',
  }) async {
    final response = await _apiService.post(
      action: 'createOrder',
      body: {
        'userId': userId,
        'productId': productId,
        'qty': qty,
        'orderType': orderType,
        'addressId': addressId,
        'paymentMethod': paymentMethod,
        'note': note,
      },
    );
    if (!response.success || response.data == null) return null;
    return OrderModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<List<OrderModel>> getOrdersByUser(String userId) async {
    final response = await _apiService.post(
      action: 'getOrdersByUser',
      body: {'userId': userId},
    );
    return _parseOrders(response.data);
  }

  Future<List<OrderModel>> getAllOrdersForAdmin(String adminId) async {
    final response = await _apiService.post(
      action: 'getAllOrdersForAdmin',
      body: {'adminId': adminId},
    );
    return _parseOrders(response.data);
  }

  Future<OrderModel?> getOrderDetail({
    required String orderId,
    String? userId,
    String? adminId,
  }) async {
    final response = await _apiService.post(
      action: 'getOrderDetail',
      body: {'orderId': orderId, 'userId': ?userId, 'adminId': ?adminId},
    );
    if (!response.success || response.data == null) return null;
    return OrderModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<String> updateOrderStatus({
    required String adminId,
    required String orderId,
    required String orderStatus,
  }) async {
    final response = await _apiService.post(
      action: 'updateOrderStatus',
      body: {
        'adminId': adminId,
        'orderId': orderId,
        'orderStatus': orderStatus,
      },
    );
    return response.message;
  }

  Future<String> updateOrderPaymentStatus({
    required String adminId,
    required String orderId,
    required String paymentStatus,
  }) async {
    final response = await _apiService.post(
      action: 'updateOrderPaymentStatus',
      body: {
        'adminId': adminId,
        'orderId': orderId,
        'paymentStatus': paymentStatus,
      },
    );
    return response.message;
  }

  List<OrderModel> _parseOrders(dynamic data) {
    return (data as List? ?? [])
        .whereType<Map>()
        .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
