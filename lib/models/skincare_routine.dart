import 'package:flutter/material.dart';

class SkincareProduct {
  final String name;
  final String description;
  final DateTime expirationDate;
  final String category; // e.g., cleanser, toner, serum, etc.
  final TimeOfDay? useTime; // specific time to use the product

  SkincareProduct({
    required this.name,
    required this.description,
    required this.expirationDate,
    required this.category,
    this.useTime,
  });
}

class SkincareRoutine {
  final String name;
  final TimeOfDay time;
  final List<SkincareProduct> products;
  final bool isCompleted;
  final String notes;

  SkincareRoutine({
    required this.name,
    required this.time,
    required this.products,
    this.isCompleted = false,
    this.notes = '',
  });
}

class SkincareDailyLog {
  final DateTime date;
  final String skinCondition;
  final String notes;
  final String? photoPath;
  final List<SkincareRoutine> completedRoutines;

  SkincareDailyLog({
    required this.date,
    required this.skinCondition,
    required this.notes,
    this.photoPath,
    required this.completedRoutines,
  });
}

class SkincareAppointment {
  final String title;
  final DateTime dateTime;
  final String location;
  final String notes;
  final bool isRecurring;
  final Duration? recurringInterval;

  SkincareAppointment({
    required this.title,
    required this.dateTime,
    required this.location,
    this.notes = '',
    this.isRecurring = false,
    this.recurringInterval,
  });
} 