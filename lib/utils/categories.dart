import 'package:flutter/material.dart';

/// Habit categories with colors
class HabitCategory {
  final String name;
  final String icon;
  final Color color;

  const HabitCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Available habit categories
final List<HabitCategory> habitCategories = [
  const HabitCategory(
    name: 'Health',
    icon: '🏥',
    color: Color(0xFFEF4444), // Red
  ),
  const HabitCategory(
    name: 'Fitness',
    icon: '💪',
    color: Color(0xFFF59E0B), // Amber
  ),
  const HabitCategory(
    name: 'Productivity',
    icon: '📋',
    color: Color(0xFF3B82F6), // Blue
  ),
  const HabitCategory(
    name: 'Learning',
    icon: '📚',
    color: Color(0xFF8B5CF6), // Purple
  ),
  const HabitCategory(
    name: 'Mindfulness',
    icon: '🧘',
    color: Color(0xFF10B981), // Green
  ),
  const HabitCategory(
    name: 'Social',
    icon: '👥',
    color: Color(0xFFEC4899), // Pink
  ),
  const HabitCategory(
    name: 'Creative',
    icon: '🎨',
    color: Color(0xFFF97316), // Orange
  ),
  const HabitCategory(
    name: 'Finance',
    icon: '💰',
    color: Color(0xFF84CC16), // Lime
  ),
];

/// Get category by name
HabitCategory? getCategoryByName(String? name) {
  if (name == null) return null;
  try {
    return habitCategories.firstWhere((cat) => cat.name == name);
  } catch (e) {
    return null;
  }
}

