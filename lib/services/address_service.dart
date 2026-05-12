import '../models/user_address_model.dart';
import 'api_service.dart';

class AddressService {
  AddressService(this._apiService);

  final ApiService _apiService;

  Future<List<UserAddressModel>> getUserAddresses(String userId) async {
    final response = await _apiService.post(
      action: 'getUserAddresses',
      body: {'userId': userId},
    );
    if (!response.success) return [];
    return (response.data as List? ?? [])
        .whereType<Map>()
        .map(
          (item) => UserAddressModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<String> saveAddress({
    required bool isEdit,
    required Map<String, dynamic> address,
  }) async {
    final response = await _apiService.post(
      action: isEdit ? 'updateUserAddress' : 'addUserAddress',
      body: address,
    );
    return response.message;
  }

  Future<String> deleteAddress({
    required String userId,
    required String addressId,
  }) async {
    final response = await _apiService.post(
      action: 'deleteUserAddress',
      body: {'userId': userId, 'addressId': addressId},
    );
    return response.message;
  }
}
