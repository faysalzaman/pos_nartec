class StatusModel {
  String id;
  String tracking;
  String orderType;
  String customer;
  Location location;
  DateTime createdAt;
  DateTime updatedAt;
  int progress;

  StatusModel({
    required this.id,
    required this.tracking,
    required this.orderType,
    required this.customer,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    required this.progress,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      id: json['id'],
      tracking: json['tracking'],
      orderType: json['orderType'],
      customer: json['customer'],
      location: Location.fromJson(json['location']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      progress: json['progress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tracking': tracking,
      'orderType': orderType,
      'customer': customer,
      'location': location.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'progress': progress,
    };
  }
}

class Location {
  String type;
  String details;

  Location({
    required this.type,
    required this.details,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'],
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'details': details,
    };
  }
}
