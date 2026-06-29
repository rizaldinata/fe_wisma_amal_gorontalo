class FeatureToggleModel {
  final int id;
  final int? parentId;
  final String key;
  final String name;
  final String? description;
  final String? icon;
  final bool isActive;
  final bool isLocked;
  final bool isLicensed;
  final int sortOrder;
  final List<FeatureToggleModel> children;

  FeatureToggleModel({
    required this.id,
    this.parentId,
    required this.key,
    required this.name,
    this.description,
    this.icon,
    required this.isActive,
    required this.isLocked,
    this.isLicensed = true,
    required this.sortOrder,
    this.children = const [],
  });

  factory FeatureToggleModel.fromJson(Map<String, dynamic> json) {
    return FeatureToggleModel(
      id: json['id'],
      parentId: json['parent_id'],
      key: json['key'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      isLocked: json['is_locked'] == 1 || json['is_locked'] == true,
      isLicensed: json['is_licensed'] ?? true, // Default true jika tidak ada
      sortOrder: json['sort_order'] ?? 0,
      children: json['children'] != null
          ? (json['children'] as List)
              .map((e) => FeatureToggleModel.fromJson(e))
              .toList()
          : [],
    );
  }

  FeatureToggleModel copyWith({
    int? id,
    int? parentId,
    String? key,
    String? name,
    String? description,
    String? icon,
    bool? isActive,
    bool? isLocked,
    bool? isLicensed,
    int? sortOrder,
    List<FeatureToggleModel>? children,
  }) {
    return FeatureToggleModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      key: key ?? this.key,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      isLocked: isLocked ?? this.isLocked,
      isLicensed: isLicensed ?? this.isLicensed,
      sortOrder: sortOrder ?? this.sortOrder,
      children: children ?? this.children,
    );
  }
}
