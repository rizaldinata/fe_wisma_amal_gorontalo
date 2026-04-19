class SettingEntity {
  final Map<String, dynamic> settings;

  SettingEntity({required this.settings});

  String? getString(String key) => settings[key]?.toString();
  
  bool getBool(String key) => settings[key]?.toString() == 'true';
  
  List<String> getList(String key) {
    if (settings[key] == null) return [];
    try {
      final value = settings[key];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      final stripped = value.toString().replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
      return stripped.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } catch (e) {
      return [];
    }
  }
}
