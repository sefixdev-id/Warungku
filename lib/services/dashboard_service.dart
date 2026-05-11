import 'api_service.dart';

class DashboardService {
  DashboardService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> getAdminDashboard(String adminId) async {
    final response = await _apiService.post(
      action: 'getAdminDashboard',
      body: {'adminId': adminId},
    );
    if (!response.success || response.data == null) return {};
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> getUserDashboard(String userId) async {
    final response = await _apiService.post(
      action: 'getUserDashboard',
      body: {'userId': userId},
    );
    if (!response.success || response.data == null) return {};
    return Map<String, dynamic>.from(response.data);
  }
}
