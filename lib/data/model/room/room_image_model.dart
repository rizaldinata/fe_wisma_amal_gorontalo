import 'package:frontend/core/services/network/api_config.dart';

class RoomImageModel {
  final int id;
  final String url;
  final String thumbnail;
  final int order;

  RoomImageModel({
    required this.id,
    required this.url,
    required this.thumbnail,
    required this.order,
  });

  factory RoomImageModel.fromJson(Map<String, dynamic> json) {
    return RoomImageModel(
      id: json['id'],
      url: json['url'],
      thumbnail: json['thumbnail'],
      order: json['order'],
    );
  }

  get fullImageUrl {
    var fullUrl = '${ApiConfig.getServerUrl().baseUrl}$url';
    print(fullUrl);
    return fullUrl;
  }

  get fullThumbnailUrl {
    var fullUrl = '${ApiConfig.getServerUrl().baseUrl}$thumbnail';
    print(fullUrl);
    return fullUrl;
  }
}
