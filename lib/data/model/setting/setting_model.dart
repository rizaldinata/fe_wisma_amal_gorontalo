import '../../../domain/entity/setting/setting_entity.dart';

class SettingModel extends SettingEntity {
  SettingModel({required Map<String, dynamic> settings}) : super(settings: settings);

  factory SettingModel.fromJson(Map<String, dynamic> json) {
    return SettingModel(settings: json);
  }

  Map<String, dynamic> toJson() {
    return settings;
  }
}
