abstract class SettingEvent {}

class FetchSettingsEvent extends SettingEvent {}

class UpdateSettingsEvent extends SettingEvent {
  final Map<String, dynamic> updatedSettings;

  UpdateSettingsEvent(this.updatedSettings);
}
