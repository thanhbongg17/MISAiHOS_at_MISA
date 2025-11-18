// models.dart
import 'package:flutter/material.dart';

class User {
  final String name;
  final String initials;
  final Color color;
  final DateTime dateOfBirth; // Ngày sinh đầy đủ

  User({
    required this.name,
    required this.initials,
    required this.color,
    required this.dateOfBirth,
  });
}