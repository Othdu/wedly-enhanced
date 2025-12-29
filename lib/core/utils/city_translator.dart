/// Utility class to translate city names from English to Arabic
/// Used when API returns city names in English but UI needs Arabic display
class CityTranslator {
  // Map of English city names to Arabic translations
  // Includes all 27 Egyptian governorates and major cities/areas
  static final Map<String, String> _cityTranslations = {
    // ========== Cairo Governorate (محافظة القاهرة) ==========
    'cairo': 'القاهرة',
    'new cairo': 'القاهرة الجديدة',
    '5th settlement': 'التجمع الخامس',
    'fifth settlement': 'التجمع الخامس',
    '1st settlement': 'التجمع الأول',
    'first settlement': 'التجمع الأول',
    '3rd settlement': 'التجمع الثالث',
    'third settlement': 'التجمع الثالث',
    'nasr city': 'مدينة نصر',
    'heliopolis': 'مصر الجديدة',
    'maadi': 'المعادي',
    'downtown': 'وسط البلد',
    'downtown cairo': 'وسط البلد',
    'zamalek': 'الزمالك',
    'dokki': 'الدقي',
    'mohandessin': 'المهندسين',
    'agouza': 'العجوزة',
    'garden city': 'جاردن سيتي',
    'shoubra': 'شبرا',
    'ain shams': 'عين شمس',
    'abbasia': 'العباسية',
    'abbasiya': 'العباسية',
    'matariya': 'المطرية',
    'el matareya': 'المطرية',
    'zeitoun': 'الزيتون',
    'hadayek el kobba': 'حدائق القبة',
    'rod el farag': 'روض الفرج',
    'shubra el kheima': 'شبرا الخيمة',
    'manial': 'المنيل',
    'sayeda zeinab': 'السيدة زينب',
    'old cairo': 'مصر القديمة',
    'masr el adima': 'مصر القديمة',
    'helwan': 'حلوان',
    'mokattam': 'المقطم',
    'muqattam': 'المقطم',
    'dar el salam': 'دار السلام',
    'masr el gedida': 'مصر الجديدة',
    'sheraton': 'شيراتون',
    'rehab': 'الرحاب',
    'el rehab': 'الرحاب',
    'rehab city': 'مدينة الرحاب',
    'katameya': 'القطامية',
    'el katameya': 'القطامية',

    // ========== Giza Governorate (محافظة الجيزة) ==========
    'giza': 'الجيزة',
    '6th of october': '6 أكتوبر',
    'sixth of october': '6 أكتوبر',
    '6 october': '6 أكتوبر',
    'october': 'أكتوبر',
    'sheikh zayed': 'الشيخ زايد',
    'zayed': 'زايد',
    'haram': 'الهرم',
    'faisal': 'فيصل',
    'hadayek el ahram': 'حدائق الأهرام',
    'october gardens': 'حدائق أكتوبر',
    'hadayek october': 'حدائق أكتوبر',
    'imbaba': 'إمبابة',
    'mohandiseen': 'المهندسين',
    'kit kat': 'كيت كات',
    'bulaq': 'بولاق',
    'warraq': 'الوراق',
    'el warraq': 'الوراق',
    'el omraniya': 'العمرانية',
    'omraniya': 'العمرانية',
    'awsim': 'أوسيم',
    'kerdasa': 'كرداسة',
    'badrashein': 'البدرشين',
    'saqqara': 'سقارة',

    // ========== Alexandria Governorate (محافظة الإسكندرية) ==========
    'alexandria': 'الإسكندرية',
    'alex': 'الإسكندرية',
    'miami': 'ميامي',
    'smouha': 'سموحة',
    'san stefano': 'سان ستيفانو',
    'stanley': 'ستانلي',
    'stanly': 'ستانلي',
    'montazah': 'المنتزه',
    'el montazah': 'المنتزه',
    'abou qir': 'أبو قير',
    'abu qir': 'أبو قير',
    'el max': 'المكس',
    'max': 'المكس',
    'agami': 'العجمي',
    'el agami': 'العجمي',
    'sidi gaber': 'سيدي جابر',
    'sporting': 'سبورتنج',
    'rushdy': 'رشدي',
    'kafr abdo': 'كفر عبده',
    'mandara': 'المندرة',
    'sidi bishr': 'سيدي بشر',
    'louran': 'لوران',
    'glim': 'جليم',
    'raml station': 'محطة الرمل',
    'borg el arab': 'برج العرب',

    // ========== Port Said Governorate (محافظة بورسعيد) ==========
    'port said': 'بورسعيد',
    'bur said': 'بورسعيد',
    'port fouad': 'بور فؤاد',

    // ========== Suez Governorate (محافظة السويس) ==========
    'suez': 'السويس',
    'el suez': 'السويس',
    'ain sokhna': 'العين السخنة',
    'ein sokhna': 'العين السخنة',

    // ========== Ismailia Governorate (محافظة الإسماعيلية) ==========
    'ismailia': 'الإسماعيلية',
    'el ismailia': 'الإسماعيلية',
    'fayed': 'فايد',
    'qantara': 'القنطرة',

    // ========== Damietta Governorate (محافظة دمياط) ==========
    'damietta': 'دمياط',
    'dumyat': 'دمياط',
    'ras el bar': 'رأس البر',
    'new damietta': 'دمياط الجديدة',
    'ezbet el borg': 'عزبة البرج',

    // ========== Dakahlia Governorate (محافظة الدقهلية) ==========
    'mansoura': 'المنصورة',
    'el mansoura': 'المنصورة',
    'talkha': 'طلخا',
    'meet ghamr': 'ميت غمر',
    'mit ghamr': 'ميت غمر',
    'manzala': 'المنزلة',
    'gamasa': 'جمصة',
    'aga': 'أجا',

    // ========== Sharqia Governorate (محافظة الشرقية) ==========
    'zagazig': 'الزقازيق',
    'el zagazig': 'الزقازيق',
    'belbeis': 'بلبيس',
    'tenth of ramadan': 'العاشر من رمضان',
    '10th of ramadan': 'العاشر من رمضان',
    'mashtul': 'مشتول السوق',
    'abu hammad': 'أبو حماد',
    'faqous': 'فاقوس',
    'hehya': 'ههيا',

    // ========== Qalyubia Governorate (محافظة القليوبية) ==========
    'banha': 'بنها',
    'el banha': 'بنها',
    'qalyub': 'قليوب',
    'qalyubia': 'القليوبية',
    'qanatir': 'القناطر الخيرية',
    'el qanatir': 'القناطر الخيرية',
    'khanka': 'الخانكة',
    'el khanka': 'الخانكة',
    'obour': 'العبور',
    'el obour': 'العبور',
    'obour city': 'مدينة العبور',
    'khosous': 'الخصوص',

    // ========== Kafr El Sheikh Governorate (محافظة كفر الشيخ) ==========
    'kafr el sheikh': 'كفر الشيخ',
    'kafr sheikh': 'كفر الشيخ',
    'desouk': 'دسوق',
    'baltim': 'بلطيم',
    'metoubes': 'مطوبس',

    // ========== Gharbia Governorate (محافظة الغربية) ==========
    'tanta': 'طنطا',
    'el tanta': 'طنطا',
    'mahalla': 'المحلة الكبرى',
    'el mahalla': 'المحلة الكبرى',
    'mahalla el kubra': 'المحلة الكبرى',
    'kafr el zayat': 'كفر الزيات',
    'zefta': 'زفتى',
    'samanoud': 'السنطة',

    // ========== Monufia Governorate (محافظة المنوفية) ==========
    'shebin el kom': 'شبين الكوم',
    'shibin el kom': 'شبين الكوم',
    'menouf': 'منوف',
    'ashmoun': 'أشمون',
    'quesna': 'قويسنا',
    'berket el sabaa': 'بركة السبع',
    'sadat city': 'مدينة السادات',

    // ========== Beheira Governorate (محافظة البحيرة) ==========
    'damanhour': 'دمنهور',
    'damanhur': 'دمنهور',
    'rashid': 'رشيد',
    'rosetta': 'رشيد',
    'idku': 'إدكو',
    'kafr el dawwar': 'كفر الدوار',
    'kom hamada': 'كوم حمادة',
    'el nubariya': 'النوبارية',
    'nubariya': 'النوبارية',
    'abou matamir': 'أبو المطامير',
    'abou homos': 'أبو حمص',

    // ========== Matruh Governorate (محافظة مطروح) ==========
    'marsa matruh': 'مرسى مطروح',
    'matrouh': 'مطروح',
    'marsa matrouh': 'مرسى مطروح',
    'el alamein': 'العلمين',
    'alamein': 'العلمين',
    'new alamein': 'العلمين الجديدة',
    'sidi abdel rahman': 'سيدي عبد الرحمن',
    'siwa': 'سيوة',
    'sallum': 'السلوم',

    // ========== North Sinai Governorate (محافظة شمال سيناء) ==========
    'arish': 'العريش',
    'el arish': 'العريش',
    'sheikh zuweid': 'الشيخ زويد',
    'rafah': 'رفح',
    'bir el abd': 'بئر العبد',

    // ========== South Sinai Governorate (محافظة جنوب سيناء) ==========
    'sharm el sheikh': 'شرم الشيخ',
    'sharm': 'شرم الشيخ',
    'dahab': 'دهب',
    'nuweiba': 'نويبع',
    'taba': 'طابا',
    'saint catherine': 'سانت كاترين',
    'st catherine': 'سانت كاترين',
    'ras sidr': 'رأس سدر',
    'ras sudr': 'رأس سدر',

    // ========== Red Sea Governorate (محافظة البحر الأحمر) ==========
    'hurghada': 'الغردقة',
    'el gouna': 'الجونة',
    'gouna': 'الجونة',
    'safaga': 'سفاجا',
    'quseer': 'القصير',
    'el quseer': 'القصير',
    'marsa alam': 'مرسى علم',
    'sahl hasheesh': 'سهل حشيش',
    'soma bay': 'خليج سوما',
    'makadi bay': 'خليج مكادي',

    // ========== Fayoum Governorate (محافظة الفيوم) ==========
    'fayoum': 'الفيوم',
    'faiyum': 'الفيوم',
    'el fayoum': 'الفيوم',
    'ibsheway': 'إبشواي',
    'tamiya': 'طامية',
    'sinnuris': 'سنورس',

    // ========== Beni Suef Governorate (محافظة بني سويف) ==========
    'beni suef': 'بني سويف',
    'bani suef': 'بني سويف',
    'el fashn': 'الفشن',
    'bush': 'ببا',
    'nasser': 'ناصر',

    // ========== Minya Governorate (محافظة المنيا) ==========
    'minya': 'المنيا',
    'el minya': 'المنيا',
    'mallawi': 'ملوي',
    'samalut': 'سمالوط',
    'maghagha': 'مغاغة',
    'beni mazar': 'بني مزار',
    'matai': 'مطاي',

    // ========== Asyut Governorate (محافظة أسيوط) ==========
    'asyut': 'أسيوط',
    'assiut': 'أسيوط',
    'el asyut': 'أسيوط',
    'abnub': 'أبنوب',
    'manfalut': 'منفلوط',
    'qusiya': 'القوصية',
    'abou tig': 'أبو تيج',
    'dairut': 'ديروط',

    // ========== Sohag Governorate (محافظة سوهاج) ==========
    'sohag': 'سوهاج',
    'suhag': 'سوهاج',
    'el sohag': 'سوهاج',
    'akhmim': 'أخميم',
    'girga': 'جرجا',
    'el balyana': 'البلينا',
    'balyana': 'البلينا',

    // ========== Qena Governorate (محافظة قنا) ==========
    'qena': 'قنا',
    'qina': 'قنا',
    'el qena': 'قنا',
    'nag hammadi': 'نجع حمادي',
    'nag hamadi': 'نجع حمادي',
    'qus': 'قوص',
    'dishna': 'دشنا',

    // ========== Luxor Governorate (محافظة الأقصر) ==========
    'luxor': 'الأقصر',
    'el luxor': 'الأقصر',
    'karnak': 'الكرنك',
    'west bank': 'البر الغربي',
    'valley of kings': 'وادي الملوك',

    // ========== Aswan Governorate (محافظة أسوان) ==========
    'aswan': 'أسوان',
    'el aswan': 'أسوان',
    'kom ombo': 'كوم أمبو',
    'kom ombu': 'كوم أمبو',
    'edfu': 'إدفو',
    'idfu': 'إدفو',
    'abu simbel': 'أبو سمبل',
    'philae': 'فيلة',

    // ========== New Administrative Capital (العاصمة الإدارية) ==========
    'new capital': 'العاصمة الإدارية الجديدة',
    'new administrative capital': 'العاصمة الإدارية الجديدة',
    'administrative capital': 'العاصمة الإدارية',
    'nac': 'العاصمة الإدارية الجديدة',

    // ========== North Coast & Resort Areas ==========
    'north coast': 'الساحل الشمالي',
    'north shore': 'الساحل الشمالي',
    'marina': 'مارينا',
    'el marina': 'مارينا',
    'hacienda': 'هاسيندا',
    'hacienda bay': 'خليج هاسيندا',
    'amwaj': 'أمواج',
    'marassi': 'مراسي',
    'caesar': 'قيصر',
  };

  /// Translates a city name from English to Arabic
  /// If the city name is already in Arabic or not found in the map, returns the original
  static String translate(String cityName) {
    if (cityName.isEmpty) return cityName;

    // Check if the city name is already in Arabic (contains Arabic characters)
    if (_containsArabic(cityName)) {
      return cityName;
    }

    // Convert to lowercase for case-insensitive matching
    final lowerCityName = cityName.toLowerCase().trim();

    // Check for exact match
    if (_cityTranslations.containsKey(lowerCityName)) {
      return _cityTranslations[lowerCityName]!;
    }

    // Check for partial match (e.g., "5th Settlement, Cairo" contains "5th settlement")
    for (final entry in _cityTranslations.entries) {
      if (lowerCityName.contains(entry.key)) {
        // If found, replace the English part with Arabic
        return cityName.replaceFirst(
          RegExp(entry.key, caseSensitive: false),
          entry.value,
        );
      }
    }

    // If no translation found, return original
    return cityName;
  }

  /// Checks if a string contains Arabic characters
  static bool _containsArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
}
