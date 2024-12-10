class PickupModel {
  String? sId;
  String? placeTitle;
  String? personName;
  String? phone;
  String? address;
  String? createdAt;
  String? updatedAt;
  int? iV;

  PickupModel({
    this.sId,
    this.placeTitle,
    this.personName,
    this.phone,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  PickupModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    placeTitle = json['placeTitle'];
    personName = json['personName'];
    phone = json['phone'];
    address = json['address'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['placeTitle'] = placeTitle;
    data['personName'] = personName;
    data['phone'] = phone;
    data['address'] = address;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
