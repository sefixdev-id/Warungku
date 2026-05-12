import '../models/debt_model.dart';
import '../models/debt_payment_model.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class DebtService {
  DebtService(this._apiService);

  final ApiService _apiService;

  Future<List<DebtModel>> getAllDebts(String adminId) async {
    final response = await _apiService.post(
      action: 'getAllDebts',
      body: {'adminId': adminId},
    );
    if (!response.success) return [];
    return _parseDebts(response.data);
  }

  Future<List<DebtModel>> getDebtsByUser(String userId) async {
    final response = await _apiService.post(
      action: 'getDebtsByUser',
      body: {'userId': userId},
    );
    if (!response.success) return [];
    return _parseDebts(response.data);
  }

  Future<DebtModel?> getDebtDetail(String debtId, {String? userId}) async {
    final response = await _apiService.post(
      action: 'getDebtDetail',
      body: {'debtId': debtId, 'userId': ?userId},
    );
    if (!response.success || response.data == null) return null;
    return DebtModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<List<DebtModel>> getDebtDetailsByUser(String userId) async {
    final debts = await getDebtsByUser(userId);
    final details = await Future.wait(
      debts.map((debt) => getDebtDetail(debt.id, userId: userId)),
    );
    final result = details.whereType<DebtModel>().toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  Future<String> addDebt({
    required String adminId,
    required String userId,
    required String note,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _apiService.post(
      action: 'addDebt',
      body: {
        'adminId': adminId,
        'userId': userId,
        'note': note,
        'items': items,
      },
    );
    return response.message;
  }

  Future<String> addPayment({
    required String adminId,
    required String debtId,
    required num amount,
    String note = '',
  }) async {
    final response = await addPaymentResult(
      adminId: adminId,
      debtId: debtId,
      amount: amount,
      note: note,
    );
    return response.message;
  }

  Future<ApiResponse<dynamic>> addPaymentResult({
    required String adminId,
    required String debtId,
    required num amount,
    String note = '',
  }) async {
    final response = await _apiService.post(
      action: 'addDebtPayment',
      body: {
        'adminId': adminId,
        'debtId': debtId,
        'amount': amount,
        'note': note,
      },
    );
    return response;
  }

  Future<List<DebtPaymentModel>> getPaymentsByDebt(String debtId) async {
    final response = await _apiService.post(
      action: 'getDebtPaymentsByDebt',
      body: {'debtId': debtId},
    );
    if (!response.success) return [];
    return (response.data as List? ?? [])
        .whereType<Map>()
        .map(
          (item) => DebtPaymentModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<List<DebtPaymentModel>> getPaymentsByUser(String userId) async {
    final response = await _apiService.post(
      action: 'getDebtPaymentsByUser',
      body: {'userId': userId},
    );
    if (!response.success) return [];
    final payments =
        (response.data as List? ?? [])
            .whereType<Map>()
            .map(
              (item) =>
                  DebtPaymentModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return payments;
  }

  List<DebtModel> _parseDebts(dynamic data) {
    return (data as List? ?? [])
        .whereType<Map>()
        .map((item) => DebtModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
