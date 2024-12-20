class CategoryData {
  final int id;
  final String name;
  final String type;
  final String picturePath;

  CategoryData({
    required this.id,
    required this.name,
    required this.type,
    required this.picturePath,
  });

  factory CategoryData.fromMap(Map<String, dynamic> map) {
    return CategoryData(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      picturePath: map['picturePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'picturePath': picturePath,
    };
  }
}