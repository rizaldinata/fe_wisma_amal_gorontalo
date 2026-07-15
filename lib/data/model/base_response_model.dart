class BaseResponseModel<T> {
  final bool status;
  final String message;
  final T data;

  BaseResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BaseResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return BaseResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: fromJsonT(json['data']),
    );
  }
}
