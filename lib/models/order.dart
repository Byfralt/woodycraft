// models/order.dart
class Order {
  int id;
  DateTime createdAt;
  DateTime updatedAt;
  int customerId;
  int registered;
  int deliveryAddId;
  String paymentType;
  DateTime date;
  int status;
  String session;
  double total;

  Order({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.customerId,
    required this.registered,
    required this.deliveryAddId,
    required this.paymentType,
    required this.date,
    required this.status,
    required this.session,
    required this.total,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        customerId: json['customer_id'],
        registered: json['registered'],
        deliveryAddId: json['delivery_add_id'],
        paymentType: json['payment_type'],
        date: DateTime.parse(json['date']),
        status: json['status'],
        session: json['session'],
        total: json['total'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'customer_id': customerId,
        'registered': registered,
        'delivery_add_id': deliveryAddId,
        'payment_type': paymentType,
        'date': date.toIso8601String(),
        'status': status,
        'session': session,
        'total': total,
      };
}
