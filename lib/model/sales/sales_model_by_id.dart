class SalesModelById {
  final bool success;
  final Order order;

  SalesModelById({
    required this.success,
    required this.order,
  });

  factory SalesModelById.fromJson(Map<String, dynamic> json) => SalesModelById(
        success: json['success'] ?? false,
        order: Order.fromJson(json['order'] ?? {}),
      );
}

class Order {
  String? id;
  String? tracking;
  Instructions? instructions;
  Kitchen? kitchen;
  Payment? payment;
  Financial? financial;
  Customer? customer;
  OrderDetails? orderDetails;
  int? progress;
  String? orderStatus;
  DateTime? createdAt;
  DateTime? updatedAt;

  Order({
    this.id,
    this.tracking,
    this.instructions,
    this.kitchen,
    this.payment,
    this.financial,
    this.customer,
    this.orderDetails,
    this.progress,
    this.orderStatus,
    this.createdAt,
    this.updatedAt,
  });

  // From JSON
  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        tracking: json['tracking'],
        instructions: json['instructions'] != null
            ? Instructions.fromJson(json['instructions'])
            : null,
        kitchen:
            json['kitchen'] != null ? Kitchen.fromJson(json['kitchen']) : null,
        payment:
            json['payment'] != null ? Payment.fromJson(json['payment']) : null,
        financial: json['financial'] != null
            ? Financial.fromJson(json['financial'])
            : null,
        customer: json['customer'] != null
            ? Customer.fromJson(json['customer'])
            : null,
        orderDetails: json['orderDetails'] != null
            ? OrderDetails.fromJson(json['orderDetails'])
            : null,
        progress: json['progress'],
        orderStatus: json['orderStatus'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
      );

  // To JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'tracking': tracking,
        'instructions': instructions?.toJson(),
        'kitchen': kitchen?.toJson(),
        'payment': payment?.toJson(),
        'financial': financial?.toJson(),
        'customer': customer?.toJson(),
        'orderDetails': orderDetails?.toJson(),
        'progress': progress,
        'orderStatus': orderStatus,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}

class Instructions {
  String? kitchen;
  String? staff;
  String? payment;

  Instructions({this.kitchen, this.staff, this.payment});

  factory Instructions.fromJson(Map<String, dynamic> json) => Instructions(
        kitchen: json['kitchen'],
        staff: json['staff'],
        payment: json['payment'],
      );

  Map<String, dynamic> toJson() => {
        'kitchen': kitchen,
        'staff': staff,
        'payment': payment,
      };
}

class Kitchen {
  String? status;
  String? chef;
  DateTime? startedAt;
  DateTime? completedAt;

  Kitchen({this.status, this.chef, this.startedAt, this.completedAt});

  factory Kitchen.fromJson(Map<String, dynamic> json) => Kitchen(
        status: json['status'],
        chef: json['chef'],
        startedAt: json['startedAt'] != null
            ? DateTime.parse(json['startedAt'])
            : null,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'chef': chef,
        'startedAt': startedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };
}

class Payment {
  String? method;
  String? status;
  Map<String, dynamic>? details;

  Payment({this.method, this.status, this.details});

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        method: json['method'],
        status: json['status'],
        details: json['details'] ?? {},
      );

  Map<String, dynamic> toJson() => {
        'method': method,
        'status': status,
        'details': details,
      };
}

class Financial {
  double? subtotal;
  dynamic discount;
  double? taxAmount;
  double? netAmount;
  double? grandTotal;

  Financial(
      {this.subtotal,
      this.discount,
      this.taxAmount,
      this.netAmount,
      this.grandTotal});

  factory Financial.fromJson(Map<String, dynamic> json) => Financial(
        subtotal: json['subtotal']?.toDouble(),
        discount: json['discount'],
        taxAmount: json['taxAmount']?.toDouble(),
        netAmount: json['netAmount']?.toDouble(),
        grandTotal: json['grandTotal']?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'subtotal': subtotal,
        'discount': discount,
        'taxAmount': taxAmount,
        'netAmount': netAmount,
        'grandTotal': grandTotal,
      };
}

class Customer {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? type;

  Customer(
      {this.id, this.name, this.email, this.phone, this.address, this.type});

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        address: json['address'],
        type: json['type'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'type': type,
      };
}

class OrderDetails {
  String? orderType;
  Location? location;
  List<Item>? items;

  OrderDetails({this.orderType, this.location, this.items});

  // From JSON
  factory OrderDetails.fromJson(Map<String, dynamic> json) => OrderDetails(
        orderType: json['orderType'],
        location: json['location'] != null
            ? Location.fromJson(json['location'])
            : null,
        items: json['items'] != null
            ? (json['items'] as List).map((i) => Item.fromJson(i)).toList()
            : [],
      );

  // To JSON
  Map<String, dynamic> toJson() => {
        'orderType': orderType,
        'location': location?.toJson(),
        'items': items?.map((i) => i.toJson()).toList(),
      };
}

class Location {
  String? type;
  LocationDetails? details;

  Location({this.type, this.details});

  // From JSON
  factory Location.fromJson(Map<String, dynamic> json) => Location(
        type: json['type'],
        details: json['details'] != null
            ? LocationDetails.fromJson(json['details'])
            : null,
      );

  // To JSON
  Map<String, dynamic> toJson() => {
        'type': type,
        'details': details?.toJson(),
      };
}

class LocationDetails {
  String? id;
  String? place;
  String? person;
  String? phone;
  String? address;
  String? tableName;
  int? capacity;
  String? status;

  LocationDetails({
    this.id,
    this.place,
    this.person,
    this.phone,
    this.address,
    this.tableName,
    this.capacity,
    this.status,
  });

  // From JSON
  factory LocationDetails.fromJson(Map<String, dynamic> json) =>
      LocationDetails(
        id: json['id'],
        place: json['place'],
        person: json['person'],
        phone: json['phone'],
        address: json['address'],
        tableName: json['tableName'],
        capacity: json['capacity'],
        status: json['status'],
      );

  // To JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'place': place,
        'person': person,
        'phone': phone,
        'address': address,
        'tableName': tableName,
        'capacity': capacity,
        'status': status,
      };
}

class Item {
  String? id;
  MenuItem? menuItem;
  int? quantity;
  double? price;
  Kitchen? kitchen;
  double? subTotal;

  Item(
      {this.id,
      this.menuItem,
      this.quantity,
      this.price,
      this.kitchen,
      this.subTotal});

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'],
        menuItem: MenuItem.fromJson(json['menuItem']),
        quantity: json['quantity'],
        price: json['price']?.toDouble(),
        kitchen: Kitchen.fromJson(json['kitchen'] ?? {}),
        subTotal: json['subTotal']?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'menuItem': menuItem?.toJson(),
        'quantity': quantity,
        'price': price,
        'kitchen': kitchen?.toJson(),
        'subTotal': subTotal,
      };
}

class MenuItem {
  String? id;
  String? name;
  double? price;
  String? description;
  String? image;

  MenuItem({this.id, this.name, this.price, this.description, this.image});

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'],
        name: json['name'],
        price: json['price']?.toDouble(),
        description: json['description'],
        image: json['image'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'image': image,
      };
}
