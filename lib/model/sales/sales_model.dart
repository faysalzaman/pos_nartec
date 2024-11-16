class SalesModel {
  List<Orders>? orders;
  Pagination? pagination;

  SalesModel({this.orders, this.pagination});

  SalesModel.fromJson(Map<String, dynamic> json) {
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(Orders.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class Orders {
  String? id;
  String? orderNo;
  Customer? customer;
  num? items;
  String? orderType;
  String? kitchenStatus;
  String? paymentStatus;
  num? progress;
  String? bookedAt;
  String? completedAt;
  Total? total;
  String? table;
  String? preparedAt;

  Orders(
      {this.id,
      this.orderNo,
      this.customer,
      this.items,
      this.orderType,
      this.kitchenStatus,
      this.paymentStatus,
      this.progress,
      this.bookedAt,
      this.completedAt,
      this.total,
      this.table,
      this.preparedAt});

  Orders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderNo = json['orderNo'];
    customer =
        json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    items = json['items'];
    orderType = json['orderType'];
    kitchenStatus = json['kitchenStatus'];
    paymentStatus = json['paymentStatus'];
    progress = json['progress'];
    bookedAt = json['bookedAt'];
    completedAt = json['completedAt'];
    total = json['total'] != null ? Total.fromJson(json['total']) : null;
    table = json['table'];
    preparedAt = json['preparedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['orderNo'] = orderNo;
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    data['items'] = items;
    data['orderType'] = orderType;
    data['kitchenStatus'] = kitchenStatus;
    data['paymentStatus'] = paymentStatus;
    data['progress'] = progress;
    data['bookedAt'] = bookedAt;
    data['completedAt'] = completedAt;
    if (total != null) {
      data['total'] = total!.toJson();
    }
    data['table'] = table;
    data['preparedAt'] = preparedAt;
    return data;
  }
}

class Customer {
  String? name;
  String? type;

  Customer({this.name, this.type});

  Customer.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    return data;
  }
}

class Total {
  num? amount;
  num? discount;
  num? tax;

  Total({this.amount, this.discount, this.tax});

  Total.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    discount = json['discount'];
    tax = json['tax'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    data['discount'] = discount;
    data['tax'] = tax;
    return data;
  }
}

class Pagination {
  num? total;
  num? page;
  num? pages;
  num? limit;

  Pagination({this.total, this.page, this.pages, this.limit});

  Pagination.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    page = json['page'];
    pages = json['pages'];
    limit = json['limit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['page'] = page;
    data['pages'] = pages;
    data['limit'] = limit;
    return data;
  }
}
