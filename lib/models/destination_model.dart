class Destination {
  final int? id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String? openTime;
  final String? closeTime;
  final String? imagePath;
  final String createdAt;

  Destination({
    this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.openTime,
    this.closeTime,
    this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'openTime': openTime,
      'closeTime': closeTime,
      'imagePath': imagePath,
      'createdAt': createdAt,
    };
  }

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      openTime: map['openTime'] as String?,
      closeTime: map['closeTime'] as String?,
      imagePath: map['imagePath'] as String?,
      createdAt: map['createdAt'] as String,
    );
  }

  Destination copyWith({
    int? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? openTime,
    String? closeTime,
    String? imagePath,
    String? createdAt,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
