class CategoryModel {
  final int categoryId;
  final String categoryName;

  CategoryModel({required this.categoryId, required this.categoryName});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['categoryid'] as int,
      categoryName: json['categoryname'] as String,
    );
  }
}
