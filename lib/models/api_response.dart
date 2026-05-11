class ApiResponse<T> {
  const ApiResponse({required this.success, required this.message, this.data});

  final bool success;
  final String message;
  final T? data;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, [
    T Function(dynamic json)? parser,
  ]) {
    return ApiResponse<T>(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: parser == null ? json['data'] as T? : parser(json['data']),
    );
  }
}
