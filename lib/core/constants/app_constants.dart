class AppConstants {
  // App Info
  static const String appName = 'Wedly';

  // User Roles
  static const String roleUser = 'user';
  static const String roleProvider = 'provider';

  // API Endpoints (for future use)
  static const String baseUrl = 'https://api.wedlyinfo.com';

  // Storage Keys
  static const String keyUserRole = 'user_role';
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';

  // Service Categories (will be fetched from API in production)
  static const List<String> serviceCategories = [
    'تصوير فوتوغرافي',
    'كوش وديكور',
    'فرق موسيقية',
    'قاعات أفراح',
    'تجميل وميك أب',
    'تنظيم حفلات',
    'كيك وحلويات',
    'دي جي',
  ];

  // Service Category Icons Mapping (optional, for UI)
  static const Map<String, String> categoryIcons = {
    'تصوير فوتوغرافي': '📷',
    'كوش وديكور': '🎨',
    'فرق موسيقية': '🎵',
    'قاعات أفراح': '🏛️',
    'تجميل وميك أب': '💄',
    'تنظيم حفلات': '🎉',
    'كيك وحلويات': '🎂',
    'دي جي': '🎧',
  };

  // Egyptian Cities (will be fetched from API in production)
  static const List<String> egyptianCities = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'أسوان',
    'أسيوط',
    'الأقصر',
    'البحيرة',
    'بني سويف',
    'بورسعيد',
    'جنوب سيناء',
    'الدقهلية',
    'دمياط',
    'سوهاج',
    'السويس',
    'الشرقية',
    'شمال سيناء',
    'الغربية',
    'الفيوم',
    'القليوبية',
    'قنا',
    'كفر الشيخ',
    'مطروح',
    'المنوفية',
    'المنيا',
    'الوادي الجديد',
    'البحر الأحمر',
    'الإسماعيلية',
  ];
}

