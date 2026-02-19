class Receipt {
  final String id;
  final String name;
  final String cuisine;
  final List<String> ingredients;
  final String youtubeLink;

  Receipt({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.ingredients,
    required this.youtubeLink,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'],
      name: json['name'],
      cuisine: json['cuisine'],
      ingredients: List<String>.from(json['ingredients']),
      youtubeLink: json['youtube_link'],
    );
  }
}
