import 'package:flutter/material.dart';

// 1. User Model
class User {
  final String id;
  final String name;
  final String email;
  final int age;
  final String skinType;
  final String skinConcerns;
  final String? allergies;
  final String? profileImagePath;
  final List<ProductExperience> productExperiences;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.skinType,
    required this.skinConcerns,
    this.allergies,
    this.profileImagePath,
    this.productExperiences = const [],
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? skinType,
    String? skinConcerns,
    String? allergies,
    String? profileImagePath,
    List<ProductExperience>? productExperiences,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      skinType: skinType ?? this.skinType,
      skinConcerns: skinConcerns ?? this.skinConcerns,
      allergies: allergies ?? this.allergies,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      productExperiences: productExperiences ?? this.productExperiences,
    );
  }
}

// 2. Product Model
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<String> ingredients;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final DateTime expiryDate;
  final Map<String, String> usageInstructions;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.ingredients,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    required this.expiryDate,
    required this.usageInstructions,
  });
}

// 3. Blog/Article Model
class BlogPost {
  final String id;
  final String title;
  final String content;
  final DateTime publishDate;
  final String authorName;
  final String? beforeImageUrl;
  final String? afterImageUrl;
  final String category;
  final List<Comment> comments;

  BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.publishDate,
    required this.authorName,
    this.beforeImageUrl,
    this.afterImageUrl,
    required this.category,
    this.comments = const [],
  });
}

// 4. Skincare Schedule Model
class SkincareSchedule {
  final String id;
  final DateTime date;
  final Map<String, bool> morningRoutine;
  final Map<String, bool> eveningRoutine;
  final List<Appointment> appointments;
  final String dailyReview;
  final String mood;
  final List<String> usedProducts;
  final Map<String, dynamic> weatherData;

  SkincareSchedule({
    required this.id,
    required this.date,
    required this.morningRoutine,
    required this.eveningRoutine,
    this.appointments = const [],
    this.dailyReview = '',
    this.mood = 'Neutral',
    this.usedProducts = const [],
    required this.weatherData,
  });
}

// 5. Skin Analysis Result Model
class SkinAnalysisResult {
  final String id;
  final String userId;
  final DateTime analysisDate;
  final String skinType;
  final List<String> concerns;
  final Map<String, double> conditionScores;
  final List<String> recommendations;
  final String? imagePath;
  final Map<String, dynamic> additionalData;

  SkinAnalysisResult({
    required this.id,
    required this.userId,
    required this.analysisDate,
    required this.skinType,
    required this.concerns,
    required this.conditionScores,
    required this.recommendations,
    this.imagePath,
    this.additionalData = const {},
  });
}

// Supporting Models
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
}

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.timestamp,
  });
}

class Appointment {
  final String id;
  final String type;
  final DateTime date;
  final String time;
  final IconData icon;
  final Map<String, dynamic> reminderSettings;

  Appointment({
    required this.id,
    required this.type,
    required this.date,
    required this.time,
    required this.icon,
    this.reminderSettings = const {},
  });
}
