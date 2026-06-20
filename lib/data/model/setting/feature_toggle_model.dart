class FeatureToggleModel {
  final int id;
  final int? parentId;
  final String key;
  final String name;
  final String? description;
  final bool isActive;
  final bool isLocked;
  final int sortOrder;
  final List<FeatureToggleModel> children;

  FeatureToggleModel({
    required this.id,
    this.parentId,
    required this.key,
    required this.name,
    this.description,
    required this.isActive,
    required this.isLocked,
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
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      isLocked: json['is_locked'] == 1 || json['is_locked'] == true,
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
    bool? isActive,
    bool? isLocked,
    int? sortOrder,
    List<FeatureToggleModel>? children,
  }) {
    return FeatureToggleModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      key: key ?? this.key,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      isLocked: isLocked ?? this.isLocked,
      sortOrder: sortOrder ?? this.sortOrder,
      children: children ?? this.children,
    );
  }
}
