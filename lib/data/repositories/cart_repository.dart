import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedly/data/models/cart_item_model.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';

class CartRepository {
  final ApiClient? apiClient;
  final bool useMockData;

  CartRepository({
    this.apiClient,
    this.useMockData = true,
  });

  // Local cache (for mock mode)
  static const String _cartKey = 'cart_items';
  List<CartItemModel> _cartItems = [];
  bool _isInitialized = false;

  // ==================== PUBLIC METHODS ====================

  /// Get all cart items for a user
  Future<List<CartItemModel>> getCartItems(String userId) async {
    if (useMockData || apiClient == null) {
      return _mockGetCartItems(userId);
    }
    return _apiGetCartItems();
  }

  /// Add item to cart
  Future<void> addToCart(CartItemModel item) async {
    if (useMockData || apiClient == null) {
      return _mockAddToCart(item);
    }
    return _apiAddToCart(item);
  }

  /// Remove item from cart
  Future<void> removeFromCart(String itemId) async {
    if (useMockData || apiClient == null) {
      return _mockRemoveFromCart(itemId);
    }
    return _apiRemoveFromCart(itemId);
  }

  /// Update cart item
  Future<void> updateCartItem(CartItemModel item) async {
    if (useMockData || apiClient == null) {
      return _mockUpdateCartItem(item);
    }
    // API doesn't have update endpoint, so we remove and re-add
    await _apiRemoveFromCart(item.id);
    await _apiAddToCart(item);
  }

  /// Clear all cart items
  Future<void> clearCart() async {
    if (useMockData || apiClient == null) {
      return _mockClearCart();
    }
    return _apiClearCart();
  }

  /// Get cart item count
  Future<int> getCartItemCount() async {
    final items = await getCartItems('');
    return items.length;
  }

  /// Calculate total price
  Future<double> getTotalPrice() async {
    final items = await getCartItems('');
    return items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Initialize with mock data for testing (only in mock mode)
  Future<void> initializeMockData() async {
    if (useMockData || apiClient == null) {
      await _loadCart();
      if (_cartItems.isNotEmpty) {
        return;
      }

      // Mock services for cart
      final venueService = ServiceModel(
        id: '1',
        name: 'قاعة رؤيا',
        description: 'قاعة فخمة للمناسبات',
        imageUrl:
            'https://images.unsplash.com/photo-1519167758481-83f29da1b3e4',
        price: 12000,
        category: 'قاعات',
        providerId: 'provider1',
        rating: 4.8,
        reviewCount: 120,
      );

      final photographyService = ServiceModel(
        id: '2',
        name: 'المصور / مصطفى محمود',
        description: 'تصوير احترافي',
        imageUrl:
            'https://images.unsplash.com/photo-1542038784456-1ea8e935640e',
        price: 9000,
        category: 'تصوير',
        providerId: 'provider2',
        rating: 4.9,
        reviewCount: 85,
      );

      _cartItems.addAll([
        CartItemModel(
          id: 'cart_item_1',
          service: venueService,
          date: '15 نوفمبر',
          time: 'الساعة 8:00 مساءً',
          servicePrice: 12000,
          photographerPrice: 0,
          serviceCharge: 100,
          addedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        CartItemModel(
          id: 'cart_item_2',
          service: photographyService,
          date: '15 نوفمبر',
          time: 'الساعة 5:00 مساءً',
          servicePrice: 9000,
          photographerPrice: 0,
          serviceCharge: 100,
          addedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ]);

      await _saveCart();
    }
  }

  // ==================== API METHODS ====================

  /// API: Get cart items
  Future<List<CartItemModel>> _apiGetCartItems() async {
    try {
      final response = await apiClient!.get(ApiConstants.cart);
      final responseData = response.data['data'] ?? response.data;

      // Handle different response structures
      dynamic cartItemsList;

      if (responseData is Map) {
        // If response is a map, try to get 'items' key
        cartItemsList = responseData['items'] ?? responseData['cart_items'] ?? [];
      } else if (responseData is List) {
        // If response is already a list
        cartItemsList = responseData;
      } else {
        // Fallback to empty list
        cartItemsList = [];
      }

      // Ensure we have a list
      if (cartItemsList is! List) {
        print('⚠️ Cart API returned unexpected format: $cartItemsList');
        return [];
      }

      return cartItemsList
          .map((json) => CartItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error in _apiGetCartItems: $e');
      rethrow;
    }
  }

  /// API: Add item to cart
  Future<void> _apiAddToCart(CartItemModel item) async {
    await apiClient!.post(
      ApiConstants.addToCart,
      data: item.toJson(),
    );
  }

  /// API: Remove item from cart
  Future<void> _apiRemoveFromCart(String itemId) async {
    await apiClient!.delete(ApiConstants.removeFromCart(itemId));
  }

  /// API: Clear cart
  Future<void> _apiClearCart() async {
    await apiClient!.delete(ApiConstants.clearCart);
  }

  // ==================== MOCK METHODS (SharedPreferences) ====================

  /// Load cart from SharedPreferences
  Future<void> _loadCart() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);

    if (cartJson != null) {
      final List<dynamic> decoded = json.decode(cartJson);
      _cartItems =
          decoded.map((item) => CartItemModel.fromJson(item)).toList();
    }

    _isInitialized = true;
  }

  /// Save cart to SharedPreferences
  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = json.encode(
      _cartItems.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_cartKey, cartJson);
  }

  Future<List<CartItemModel>> _mockGetCartItems(String userId) async {
    await _loadCart();
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_cartItems);
  }

  Future<void> _mockAddToCart(CartItemModel item) async {
    await _loadCart();
    await Future.delayed(const Duration(milliseconds: 300));
    _cartItems.add(item);
    await _saveCart();
  }

  Future<void> _mockRemoveFromCart(String itemId) async {
    await _loadCart();
    await Future.delayed(const Duration(milliseconds: 300));
    _cartItems.removeWhere((item) => item.id == itemId);
    await _saveCart();
  }

  Future<void> _mockUpdateCartItem(CartItemModel item) async {
    await _loadCart();
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _cartItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _cartItems[index] = item;
      await _saveCart();
    }
  }

  Future<void> _mockClearCart() async {
    await _loadCart();
    await Future.delayed(const Duration(milliseconds: 300));
    _cartItems.clear();
    await _saveCart();
  }
}
