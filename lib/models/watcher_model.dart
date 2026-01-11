class WatcherModel {
  final int? id;
  final String name;
  final String phoneNumber;

  WatcherModel({
    this.id,
    required this.name,
    required this.phoneNumber,
  });

  factory WatcherModel.fromJson(Map<String, dynamic> json) {
    return WatcherModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
    };
  }

  WatcherModel copyWith({
    int? id,
    String? name,
    String? phoneNumber,
  }) {
    return WatcherModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

