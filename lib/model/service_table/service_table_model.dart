class ServiceTableModel {
  String? sId;
  String? tableName;
  int? capacity;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? iV;

  ServiceTableModel({
    this.sId,
    this.tableName,
    this.capacity,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  ServiceTableModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    tableName = json['tableName'];
    capacity = json['capacity'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['tableName'] = tableName;
    data['capacity'] = capacity;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
