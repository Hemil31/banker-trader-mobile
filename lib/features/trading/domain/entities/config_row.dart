class ConfigRow {
  const ConfigRow({
    required this.key,
    required this.group,
    required this.type,
    required this.value,
    required this.label,
    required this.isEditable,
  });

  final String key;
  final String group;
  final String type;
  final Object? value;
  final String label;
  final bool isEditable;

  factory ConfigRow.fromJson(Map<String, dynamic> json) {
    return ConfigRow(
      key: json['key'] as String? ?? '',
      group: json['group'] as String? ?? 'general',
      type: json['type'] as String? ?? 'string',
      value: json['value'],
      label: json['label'] as String? ?? json['key'] as String? ?? '',
      isEditable: json['is_editable'] as bool? ?? false,
    );
  }
}
