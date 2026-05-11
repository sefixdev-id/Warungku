import '../models/api_response.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'local_session_service.dart';

class AuthService {
  AuthService(this._apiService, this._sessionService);

  final ApiService _apiService;
  final LocalSessionService _sessionService;

  Future<ApiResponse<UserModel>> login(String email, String password) async {
    final response = await _apiService.post(
      action: 'login',
      body: {'email': email, 'password': password},
    );
    if (!response.success || response.data == null) {
      return ApiResponse(success: false, message: response.message);
    }
    final user = UserModel.fromJson(Map<String, dynamic>.from(response.data));
    await _sessionService.saveUser(user);
    return ApiResponse(success: true, message: response.message, data: user);
  }

  Future<ApiResponse<UserModel>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      action: 'registerUser',
      body: {
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
      },
    );
    if (!response.success || response.data == null) {
      return ApiResponse(success: false, message: response.message);
    }
    final user = UserModel.fromJson(Map<String, dynamic>.from(response.data));
    await _sessionService.saveUser(user);
    return ApiResponse(success: true, message: response.message, data: user);
  }

  Future<UserModel?> currentUser() => _sessionService.getUser();

  Future<ApiResponse<void>> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await _apiService.post(
      action: 'changePassword',
      body: {
        'userId': userId,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
    return ApiResponse(success: response.success, message: response.message);
  }

  Future<void> logout() => _sessionService.clear();
}
