class OrdersModel {
  final String id;
  final String tracking;
  final Map<String, dynamic> instructions;
  final KitchenStatus kitchen;
  final PaymentDetails payment;
  final FinancialDetails financial;
  final CustomerDetails customer;
  final OrderDetails orderDetails;
  final int progress;
  final String orderStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrdersModel({
    required this.id,
    required this.tracking,
    required this.instructions,
    required this.kitchen,
    required this.payment,
    required this.financial,
    required this.customer,
    required this.orderDetails,
    required this.progress,
    required this.orderStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrdersModel.fromJson(Map<String, dynamic> json) {
    return OrdersModel(
      id: json['id'] ?? '',
      tracking: json['tracking'] ?? '',
      instructions: json['instructions'] ?? {},
      kitchen: KitchenStatus.fromJson(json['kitchen'] ?? {}),
      payment: PaymentDetails.fromJson(json['payment'] ?? {}),
      financial: FinancialDetails.fromJson(json['financial'] ?? {}),
      customer: CustomerDetails.fromJson(json['customer'] ?? {}),
      orderDetails: OrderDetails.fromJson(json['orderDetails'] ?? {}),
      progress: json['progress'] ?? 0,
      orderStatus: json['orderStatus'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tracking': tracking,
      'instructions': instructions,
      'kitchen': kitchen.toJson(),
      'payment': payment.toJson(),
      'financial': financial.toJson(),
      'customer': customer.toJson(),
      'orderDetails': orderDetails.toJson(),
      'progress': progress,
      'orderStatus': orderStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class KitchenStatus {
  final String status;
  final String? chef;

  KitchenStatus({
    required this.status,
    this.chef,
  });

  factory KitchenStatus.fromJson(Map<String, dynamic> json) {
    return KitchenStatus(
      status: json['status'] ?? '',
      chef: json['chef'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'chef': chef,
    };
  }
}

class PaymentDetails {
  final String? method;
  final String status;
  final Map<String, dynamic> details;

  PaymentDetails({
    this.method,
    required this.status,
    required this.details,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      method: json['method'],
      status: json['status'] ?? '',
      details: json['details'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'status': status,
      'details': details,
    };
  }
}

class FinancialDetails {
  final double subtotal;
  final DiscountDetails discount;
  final List<dynamic> taxes;
  final double netAmount;
  final double grandTotal;

  FinancialDetails({
    required this.subtotal,
    required this.discount,
    required this.taxes,
    required this.netAmount,
    required this.grandTotal,
  });

  factory FinancialDetails.fromJson(Map<String, dynamic> json) {
    return FinancialDetails(
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      discount: DiscountDetails.fromJson(json['discount'] ?? {}),
      taxes: json['taxes'] ?? [],
      netAmount: (json['netAmount'] ?? 0.0).toDouble(),
      grandTotal: (json['grandTotal'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'discount': discount.toJson(),
      'taxes': taxes,
      'netAmount': netAmount,
      'grandTotal': grandTotal,
    };
  }
}

class DiscountDetails {
  final String type;

  DiscountDetails({
    required this.type,
  });

  factory DiscountDetails.fromJson(Map<String, dynamic> json) {
    return DiscountDetails(
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
    };
  }
}

class CustomerDetails {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String type;

  CustomerDetails({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.type,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'type': type,
    };
  }
}

class OrderDetails {
  final String orderType;
  final LocationDetails location;
  final List<OrderItem> items;

  OrderDetails({
    required this.orderType,
    required this.location,
    required this.items,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      orderType: json['orderType'] ?? '',
      location: LocationDetails.fromJson(json['location'] ?? {}),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderType': orderType,
      'location': location.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class LocationDetails {
  final String type;
  final Map<String, dynamic> details;

  LocationDetails({
    required this.type,
    required this.details,
  });

  factory LocationDetails.fromJson(Map<String, dynamic> json) {
    return LocationDetails(
      type: json['type'] ?? '',
      details: json['details'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'details': details,
    };
  }
}

class OrderItem {
  final String id;
  final MenuItem menuItem;
  final int quantity;
  final double price;
  final List<ModifierItem> modifiers;
  final KitchenItemStatus kitchen;
  final double subTotal;
  final double modifiersTotal;

  OrderItem({
    required this.id,
    required this.menuItem,
    required this.quantity,
    required this.price,
    required this.modifiers,
    required this.kitchen,
    required this.subTotal,
    required this.modifiersTotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      menuItem: MenuItem.fromJson(json['menuItem'] ?? {}),
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
      modifiers: (json['modifiers'] as List<dynamic>?)
              ?.map((mod) => ModifierItem.fromJson(mod))
              .toList() ??
          [],
      kitchen: KitchenItemStatus.fromJson(json['kitchen'] ?? {}),
      subTotal: (json['subTotal'] ?? 0.0).toDouble(),
      modifiersTotal: (json['modifiersTotal'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuItem': menuItem.toJson(),
      'quantity': quantity,
      'price': price,
      'modifiers': modifiers.map((mod) => mod.toJson()).toList(),
      'kitchen': kitchen.toJson(),
      'subTotal': subTotal,
      'modifiersTotal': modifiersTotal,
    };
  }
}

class MenuItem {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String? image;
  final List<ItemModifier> itemModifiers;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.image,
    required this.itemModifiers,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      description: json['description'],
      image: json['image'],
      itemModifiers: (json['itemModifiers'] as List<dynamic>?)
              ?.map((mod) => ItemModifier.fromJson(mod))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'image': image,
      'itemModifiers': itemModifiers.map((mod) => mod.toJson()).toList(),
    };
  }
}

class ItemModifier {
  final String id;
  final String name;
  final String unit;

  ItemModifier({
    required this.id,
    required this.name,
    required this.unit,
  });

  factory ItemModifier.fromJson(Map<String, dynamic> json) {
    return ItemModifier(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
    };
  }
}

class ModifierItem {
  final String name;
  final String unit;
  final int quantity;
  final double price;

  ModifierItem({
    required this.name,
    required this.unit,
    required this.quantity,
    required this.price,
  });

  factory ModifierItem.fromJson(Map<String, dynamic> json) {
    return ModifierItem(
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
      'quantity': quantity,
      'price': price,
    };
  }
}

class KitchenItemStatus {
  final String status;
  final bool isReady;
  final DateTime? completedAt;

  KitchenItemStatus({
    required this.status,
    required this.isReady,
    this.completedAt,
  });

  factory KitchenItemStatus.fromJson(Map<String, dynamic> json) {
    return KitchenItemStatus(
      status: json['status'] ?? '',
      isReady: json['isReady'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'isReady': isReady,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
