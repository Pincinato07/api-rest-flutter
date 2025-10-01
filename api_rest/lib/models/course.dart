class CourseModel {
  final String id;
  final String name;
  final String desc;
  final num price;

  CourseModel({
    required this.id,
    required this.name,
    required this.desc,
    required this.price,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      desc: json['desc'] ?? '',
      price: json['price'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'desc': desc,
        'price': price,
      };
}
