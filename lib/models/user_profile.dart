class UserProfile {
  final String? profileImagePath;
  final String name;
  final int age;
  final String email;
  final String skinType;
  final String skinConcerns;
  final String? allergies;
  final List<ProductExperience> productExperiences;

  UserProfile({
    this.profileImagePath,
    required this.name,
    required this.age,
    required this.email,
    required this.skinType,
    required this.skinConcerns,
    this.allergies,
    required this.productExperiences,
  });

  UserProfile copyWith({
    String? profileImagePath,
    String? name,
    int? age,
    String? email,
    String? skinType,
    String? skinConcerns,
    String? allergies,
    List<ProductExperience>? productExperiences,
  }) {
    return UserProfile(
      profileImagePath: profileImagePath ?? this.profileImagePath,
      name: name ?? this.name,
      age: age ?? this.age,
      email: email ?? this.email,
      skinType: skinType ?? this.skinType,
      skinConcerns: skinConcerns ?? this.skinConcerns,
      allergies: allergies ?? this.allergies,
      productExperiences: productExperiences ?? this.productExperiences,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileImagePath': profileImagePath,
      'name': name,
      'age': age,
      'email': email,
      'skinType': skinType,
      'skinConcerns': skinConcerns,
      'allergies': allergies,
      'productExperiences': productExperiences.map((e) => e.toJson()).toList(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'profileImagePath': profileImagePath,
      'name': name,
      'age': age,
      'email': email,
      'skinType': skinType,
      'skinConcerns': skinConcerns,
      'allergies': allergies,
      'productExperiences': productExperiences.map((e) => e.toMap()).toList(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      profileImagePath: json['profileImagePath'],
      name: json['name'],
      age: json['age'],
      email: json['email'],
      skinType: json['skinType'],
      skinConcerns: json['skinConcerns'],
      allergies: json['allergies'],
      productExperiences:
          (json['productExperiences'] as List)
              .map((e) => ProductExperience.fromJson(e))
              .toList(),
    );
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      profileImagePath: map['profileImagePath'],
      name: map['name'],
      age: map['age'],
      email: map['email'],
      skinType: map['skinType'],
      skinConcerns: map['skinConcerns'],
      allergies: map['allergies'],
      productExperiences:
          (map['productExperiences'] as List)
              .map((e) => ProductExperience.fromMap(e))
              .toList(),
    );
  }
}

class ProductExperience {
  final String name;
  final int rating;
  final String review;
  final DateTime date;

  ProductExperience({
    required this.name,
    required this.rating,
    required this.review,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rating': rating,
      'review': review,
      'date': date.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rating': rating,
      'review': review,
      'date': date.toIso8601String(),
    };
  }

  factory ProductExperience.fromJson(Map<String, dynamic> json) {
    return ProductExperience(
      name: json['name'],
      rating: json['rating'],
      review: json['review'],
      date: DateTime.parse(json['date']),
    );
  }

  factory ProductExperience.fromMap(Map<String, dynamic> map) {
    return ProductExperience(
      name: map['name'],
      rating: map['rating'],
      review: map['review'],
      date: DateTime.parse(map['date']),
    );
  }
}
