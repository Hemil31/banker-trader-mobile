/// A connectable broker on the platform (from `GET /api/brokers`).
class Broker {
  const Broker({
    required this.slug,
    required this.name,
    required this.paper,
    required this.active,
  });

  final String slug;
  final String name;
  final bool paper;
  final bool active;

  bool get isLive => active && !paper;

  factory Broker.fromJson(Map<String, dynamic> json) => Broker(
    slug: json['slug'] as String? ?? '',
    name: json['name'] as String? ?? '',
    paper: json['paper'] as bool? ?? false,
    active: json['active'] as bool? ?? false,
  );
}