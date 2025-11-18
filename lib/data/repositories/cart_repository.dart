import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedly/data/models/cart_item_model.dart';
import 'package:wedly/data/models/service_model.dart';

class CartRepository {
  static const String _cartKey = 'cart_items';
  List<CartItemModel> _cartItems = [];
  bool _isInitialized = false;

  // Load cart from SharedPreferences
  Future<void> _loadCart() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);

    if (cartJson != null) {
      final List<dynamic> decoded = json.decode(cartJson);
      _cartItems = decoded.map((item) => CartItemModel.fromJson(item)).toList();
    }

    _isInitialized = true;
  }

  // Save cart to SharedPreferences
  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = json.encode(
      _cartItems.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_cartKey, cartJson);
  }

  // Get all cart items for a user
  Future<List<CartItemModel>> getCartItems(String userId) async {
    await _loadCart();
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_cartItems);
  }

  // Add item to cart
  Future<void> addToCart(CartItemModel item) async {
    await _loadCart();
    await Future.delayed(const Duration(milliseconds: 300));
    _cartItems.add(item);
    await _saveCart();
  }

  // Remove item from cart
  Future<void> removeFromCart(String itemId) async {
    await _loadCart();
    await Future.delayed(const Duration(milliseconds: 300));
    _cartItems.removeWhere((item) => item.id == itemId);
    await _saveCart();
  }

  // Update cart item
  Future<void> updateCartItem(CartItemModel item) async {
    await _loadCart();
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _cartItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _cartItems[index] = item;
      await _saveCart();
    }
  }

  // Clear all cart items
  Future<void> clearCart() async {
    await _loadCart();
    await Future.delayed(const Duration(milliseconds: 300));
    _cartItems.clear();
    await _saveCart();
  }

  // Get cart item count
  Future<int> getCartItemCount() async {
    await _loadCart();
    await Future.delayed(const Duration(milliseconds: 100));
    return _cartItems.length;
  }

  // Calculate total price
  Future<double> getTotalPrice() async {
    await _loadCart();
    await Future.delayed(const Duration(milliseconds: 100));
    return _cartItems.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Initialize with mock data for testing (only if cart is empty)
  Future<void> initializeMockData() async {
    await _loadCart();

    // Only initialize if cart is empty
    if (_cartItems.isNotEmpty) {
      return;
    }

    // Mock services for cart
    final venueService = ServiceModel(
      id: '1',
      name: 'قاعة رؤيا',
      description: 'قاعة فخمة للمناسبات',
      imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f29da1b3e4',
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
      imageUrl: 'https://images.unsplash.com/photo-1542038784456-1ea8e935640e',
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
