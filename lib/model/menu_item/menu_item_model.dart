class MenuItemModel {
  final String id;
  final String name;
  final CategoryModel category;
  final double price;
  final String description;
  final String image;
  final bool status;
  final List<ModifierModel> modifiers;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.image,
    required this.status,
    required this.modifiers,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) => MenuItemModel(
        id: json["_id"],
        name: json["name"],
        category: CategoryModel.fromJson(json["category"]),
        price: json["price"]?.toDouble() ?? 0.0,
        description: json["description"],
        image: json["image"],
        status: json["status"],
        modifiers: List<ModifierModel>.from(
            (json["modifiers"] ?? []).map((x) => ModifierModel.fromJson(x))),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "category": category.toJson(),
        "price": price,
        "description": description,
        "image": image,
        "status": status,
        "modifiers": modifiers,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
}

class CategoryModel {
  final String id;
  final String name;

  CategoryModel({
    required this.id,
    required this.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json["_id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
      };
}

class MenuItemResponse {
  final List<MenuItemModel> menuItems;
  final int totalPages;
  final int currentPage;
  final int totalItems;

  MenuItemResponse({
    required this.menuItems,
    required this.totalPages,
    required this.currentPage,
    required this.totalItems,
  });

  factory MenuItemResponse.fromJson(Map<String, dynamic> json) =>
      MenuItemResponse(
        menuItems: List<MenuItemModel>.from(
            json["menuItems"].map((x) => MenuItemModel.fromJson(x))),
        totalPages: json["totalPages"],
        currentPage: json["currentPage"],
        totalItems: json["totalItems"],
      );

  Map<String, dynamic> toJson() => {
        "menuItems": List<dynamic>.from(menuItems.map((x) => x.toJson())),
        "totalPages": totalPages,
        "currentPage": currentPage,
        "totalItems": totalItems,
      };
}

class ModifierModel {
  final String id;
  final String name;
  final double price;
  final String unit;
  final int stock;
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  ModifierModel({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.stock,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory ModifierModel.fromJson(Map<String, dynamic> json) => ModifierModel(
        id: json["_id"],
        name: json["name"],
        price: json["price"]?.toDouble() ?? 0.0,
        unit: json["unit"],
        stock: json["stock"],
        status: json["status"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "price": price,
        "unit": unit,
        "stock": stock,
        "status": status,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
}
