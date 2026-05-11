import '../models/category_model.dart';
import 'api_service.dart';

class CategoryService {
  CategoryService(this._apiService);

  final ApiService _apiService;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiService.post(action: 'getCategories');
    if (!response.success) return [];
    return (response.data as List? ?? [])
        .whereType<Map>()
        .map((item) => CategoryModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
