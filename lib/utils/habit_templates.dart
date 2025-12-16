/// Habit templates for quick creation
class HabitTemplate {
  final String name;
  final String icon;
  final String description;

  const HabitTemplate({
    required this.name,
    required this.icon,
    required this.description,
  });
}

/// Predefined habit templates
const List<HabitTemplate> habitTemplates = [
  HabitTemplate(
    name: 'Drink Water',
    icon: '💧',
    description: 'Stay hydrated throughout the day',
  ),
  HabitTemplate(
    name: 'Exercise',
    icon: '🏃',
    description: '30 minutes of physical activity',
  ),
  HabitTemplate(
    name: 'Read',
    icon: '📚',
    description: 'Read for 30 minutes',
  ),
  HabitTemplate(
    name: 'Meditate',
    icon: '🧘',
    description: '10 minutes of mindfulness',
  ),
  HabitTemplate(
    name: 'Eat Healthy',
    icon: '🍎',
    description: 'Make healthy food choices',
  ),
  HabitTemplate(
    name: 'Sleep Early',
    icon: '💤',
    description: 'Go to bed before 11 PM',
  ),
  HabitTemplate(
    name: 'Write Journal',
    icon: '✍️',
    description: 'Write in your journal',
  ),
  HabitTemplate(
    name: 'Learn Something',
    icon: '🧠',
    description: 'Learn a new skill or concept',
  ),
  HabitTemplate(
    name: 'Practice Gratitude',
    icon: '🙏',
    description: 'Write 3 things you\'re grateful for',
  ),
  HabitTemplate(
    name: 'Limit Screen Time',
    icon: '📱',
    description: 'Reduce phone usage',
  ),
  HabitTemplate(
    name: 'No Social Media',
    icon: '🚫',
    description: 'Avoid social media for the day',
  ),
  HabitTemplate(
    name: 'Practice Music',
    icon: '🎵',
    description: 'Practice your instrument',
  ),
];

