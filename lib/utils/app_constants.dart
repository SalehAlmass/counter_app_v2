class AppConstants {
  // Default team names
  static const List<String> DEFAULT_TEAM_NAMES = [
    'الفريق الأول',
    'الفريق الثاني', 
    'الفريق الثالث',
    'الفريق الرابع'
  ];
  
  // Table dimensions
  static const double TABLE_QUESTION_COLUMN_WIDTH = 70.0;
  static const double TABLE_TEAM_COLUMN_WIDTH = 110.0;
  static const double TABLE_ACTION_COLUMN_WIDTH = 70.0;
  
  // Button sizes
  static const double ICON_BUTTON_SIZE = 18.0;
  static const double ICON_BUTTON_CONSTRAINT = 32.0;
  
  // Spacing
  static const double DEFAULT_PADDING = 16.0;
  static const double SMALL_PADDING = 8.0;
  static const double LARGE_PADDING = 24.0;
  
  // Typography
  static const double HEADING_TEXT_SIZE = 20.0;
  static const double BODY_TEXT_SIZE = 16.0;
  static const double SMALL_TEXT_SIZE = 14.0;
  
  // Game settings
  static const int TOTAL_QUESTIONS = 10;
  
  // Colors (can be moved to theme later)
  static const String WINNER_GRADIENT_START = '0xFFFFA726';
  static const String WINNER_GRADIENT_END = '0xFFFF6D00';
}