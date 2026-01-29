import 'package:flutter/foundation.dart';
import 'package:wedly/data/models/cart_item_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';

class CartRepository {
  final ApiClient _apiClient;

  CartRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get all cart items for a user
  Future<List<CartItemModel>> getCartItems(String userId) async {
    try {
      final response = await _apiClient.get(ApiConstants.cart);
      final responseData = response.data['data'] ?? response.data;

      dynamic cartItemsList;
      if (responseData is Map) {
        cartItemsList = responseData['items'] ?? responseData['cart_items'] ?? [];
      } else if (responseData is List) {
        cartItemsList = responseData;
      } else {
        cartItemsList = [];
      }

      if (cartItemsList is! List) {
        debugPrint('⚠️ Cart API returned unexpected format: $cartItemsList');
        return [];
      }

      return cartItemsList
          .map((json) => CartItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error in getCartItems: $e');
      rethrow;
    }
  }

  /// Add item to cart
  Future<void> addToCart(CartItemModel item) async {
    await _apiClient.post(
      ApiConstants.addToCart,
      data: item.toJson(),
    );
  }

  /// Remove item from cart
  Future<void> removeFromCart(String itemId) async {
    await _apiClient.delete(ApiConstants.removeFromCart(itemId));
  }

  /// Update cart item
  Future<void> updateCartItem(CartItemModel item) async {
    await removeFromCart(item.id);
    await addToCart(item);
  }

  /// Clear all cart items
  Future<void> clearCart() async {
    await _apiClient.delete(ApiConstants.clearCart);
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
}
