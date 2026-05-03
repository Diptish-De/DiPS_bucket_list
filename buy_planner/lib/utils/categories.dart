import 'package:flutter/material.dart';

class GoalCategory {
  final String name;
  final IconData icon;
  final Color color;

  const GoalCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

final List<GoalCategory> goalCategories = [
  GoalCategory(name: 'Tech', icon: Icons.phone_android, color: Color(0xFF4A90D9)),
  GoalCategory(name: 'Travel', icon: Icons.flight_takeoff, color: Color(0xFFFF6D3B)),
  GoalCategory(name: 'Fashion', icon: Icons.checkroom, color: Color(0xFFE91E63)),
  GoalCategory(name: 'Home', icon: Icons.home_outlined, color: Color(0xFF4CAF50)),
  GoalCategory(name: 'Gaming', icon: Icons.sports_esports, color: Color(0xFF9C27B0)),
  GoalCategory(name: 'Education', icon: Icons.school_outlined, color: Color(0xFFFF9800)),
  GoalCategory(name: 'Fitness', icon: Icons.fitness_center, color: Color(0xFF00BCD4)),
  GoalCategory(name: 'Other', icon: Icons.diamond_outlined, color: Color(0xFF607D8B)),
];

GoalCategory getCategoryByName(String name) {
  return goalCategories.firstWhere(
    (c) => c.name == name,
    orElse: () => goalCategories.last,
  );
}
