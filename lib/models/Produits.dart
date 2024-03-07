class Product {
  int id;
  String name;
  String description;
  String image;
  int categoryId;
  double price; // Modifier cette ligne en double
  int stock;
  DateTime createdAt;
  DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.categoryId,
    required this.price,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'] ?? '', // Utilisation de ?? pour fournir une valeur par défaut si la valeur est null
    description: json['description'] ?? '',
    image: json['image'] ?? '',
    categoryId: json['cat_id'],
    price: json['price'] != null ? json['price'].toDouble() : 0.0, // Vérifiez si la valeur est null avant de la convertir en double
    stock: json['stock'],
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(), // Vous pouvez fournir une valeur par défaut ou gérer ce cas selon vos besoins
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
  );


  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image': image,
        'cat_id': categoryId,
        'price': price,
        'stock': stock,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
