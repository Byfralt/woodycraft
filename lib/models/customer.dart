// models/customer.dart
class Customer {
  int id;
  String forename;
  String surname;
  String add1;
  String add2;
  String add3;
  String postcode;
  String phone;
  String email;
  int registered;
  DateTime createdAt;
  DateTime updatedAt;

  Customer({
    required this.id,
    required this.forename,
    required this.surname,
    required this.add1,
    required this.add2,
    required this.add3,
    required this.postcode,
    required this.phone,
    required this.email,
    required this.registered,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'],
        forename: json['forename'],
        surname: json['surname'],
        add1: json['add1'],
        add2: json['add2'],
        add3: json['add3'],
        postcode: json['postcode'],
        phone: json['phone'],
        email: json['email'],
        registered: json['registered'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'forename': forename,
        'surname': surname,
        'add1': add1,
        'add2': add2,
        'add3': add3,
        'postcode': postcode,
        'phone': phone,
        'email': email,
        'registered': registered,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
