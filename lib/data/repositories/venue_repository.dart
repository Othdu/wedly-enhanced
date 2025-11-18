import 'package:wedly/data/models/venue_model.dart';

/// Repository for managing wedding venues (قاعات أفراح)
/// Currently uses mock data - ready for API integration
class VenueRepository {
  // TODO: API Integration - Replace mock data with real API calls
  // Base URL: /api/venues
  // GET /api/venues - Fetch all active venues
  // GET /api/venues/:id - Fetch single venue details
  // POST /api/admin/venues - Admin creates new venue
  // PUT /api/provider/venues/:id - Provider edits their venue
  // DELETE /api/admin/venues/:id - Admin deletes venue
  // GET /api/provider/venues - Provider fetches their venues

  /// Fetch all active venues
  /// Network delay: 800ms (simulated)
  Future<List<VenueModel>> getVenues() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // TODO: API Integration - Replace with: dio.get('/api/venues')
    return _mockVenues;
  }

  /// Fetch a single venue by ID
  /// Network delay: 500ms (simulated)
  Future<VenueModel?> getVenueById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: API Integration - Replace with: dio.get('/api/venues/$id')
    try {
      return _mockVenues.firstWhere((venue) => venue.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Mock data - 4 venues matching the screenshot
  /// These match the examples shown in the UI design
  static final List<VenueModel> _mockVenues = [
    // Venue 1: قاعة نوفا - التجمع الخامس
    const VenueModel(
      id: 'venue_1',
      name: 'قاعة نوفا - التجمع الخامس',
      description: 'قاعة أفراح فاخرة في قلب التجمع الخامس مع ديكورات كلاسيكية راقية وثريات كريستال',
      imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f29da1a26a?w=800&h=600&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1519167758481-83f29da1a26a?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800&h=600&fit=crop',
      ],
      rating: 4.8,
      reviewCount: 127,
      capacity: 200,
      pricePerPerson: 200.0,
      providerId: 'provider_1',
      address: 'التجمع الخامس، القاهرة الجديدة',
      latitude: 30.0131,
      longitude: 31.4318,
      isActive: true,
      isPendingApproval: false,
    ),

    // Venue 2: قاعة إيلات - الشيخ زايد
    const VenueModel(
      id: 'venue_2',
      name: 'قاعة إيلات - الشيخ زايد',
      description: 'قاعة عصرية بتصميم أنيق مع إضاءة رومانسية وديكورات زهور طبيعية',
      imageUrl: 'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=800&h=600&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&h=600&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 98,
      capacity: 250,
      pricePerPerson: 250.0,
      providerId: 'provider_2',
      address: 'الشيخ زايد، الجيزة',
      latitude: 30.0692,
      longitude: 31.0118,
      isActive: true,
      isPendingApproval: false,
    ),

    // Venue 3: قاعة روفاتا - 6 أكتوبر
    const VenueModel(
      id: 'venue_3',
      name: 'قاعة روفاتا - 6 أكتوبر',
      description: 'قاعة مودرن بإطلالة ساحرة مع كوش مميز وديكورات ذهبية فاخرة',
      imageUrl: 'https://images.unsplash.com/photo-1470229538611-16ba8c7ffbd7?w=800&h=600&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1470229538611-16ba8c7ffbd7?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=800&h=600&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 84,
      capacity: 300,
      pricePerPerson: 300.0,
      providerId: 'provider_3',
      address: '6 أكتوبر، الجيزة',
      latitude: 29.9622,
      longitude: 30.9199,
      isActive: true,
      isPendingApproval: false,
    ),

    // Venue 4: قاعة قلبي الشرطة - مدينة نصر
    const VenueModel(
      id: 'venue_4',
      name: 'قاعة قلبي الشرطة - مدينة نصر',
      description: 'قاعة كلاسيكية فخمة مع ديكورات أوروبية راقية وإضاءة مميزة',
      imageUrl: 'https://images.unsplash.com/photo-1505236858219-8359eb29e329?w=800&h=600&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1505236858219-8359eb29e329?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800&h=600&fit=crop',
      ],
      rating: 4.9,
      reviewCount: 156,
      capacity: 400,
      pricePerPerson: 400.0,
      providerId: 'provider_4',
      address: 'مدينة نصر، القاهرة',
      latitude: 30.0444,
      longitude: 31.3486,
      isActive: true,
      isPendingApproval: false,
    ),
  ];
}
