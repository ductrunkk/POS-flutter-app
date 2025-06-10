class DishModel {
  final int dishId;
  final String dishName;
  final double price;
  final String? description;
  final int categoryId;
  final String? imageUrl;

  DishModel({
    required this.dishId,
    required this.dishName,
    required this.price,
    this.description,
    required this.categoryId,
    this.imageUrl,
  });

  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      dishId: json['dishid'] as int,
      dishName: json['dishname'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      categoryId: json['categoryid'] as int,
      imageUrl: json['image'] as String?,
    );
  }
}