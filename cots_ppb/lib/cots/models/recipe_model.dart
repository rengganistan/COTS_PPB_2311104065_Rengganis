class Recipe {
  final int? id;
  final String title;
  final String category;
  final String ingredients;
  final String steps;
  final String? note;
  final String? createdAt;
  final String? updatedAt;

  Recipe({
    this.id,
    required this.title,
    required this.category,
    required this.ingredients,
    required this.steps,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      ingredients: json['ingredients'] ?? '',
      steps: json['steps'] ?? '',
      note: json['note'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'ingredients': ingredients,
      'steps': steps,
      'note': note,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Recipe copyWith({
    int? id,
    String? title,
    String? category,
    String? ingredients,
    String? steps,
    String? note,
    String? createdAt,
    String? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
