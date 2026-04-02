import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/utils/error_handler.dart';
import 'package:wedly/data/models/cart_item_model.dart';
import 'package:wedly/data/repositories/cart_repository.dart';
import 'package:wedly/data/repositories/service_repository.dart';
import 'package:wedly/logic/blocs/cart/cart_event.dart';
import 'package:wedly/logic/blocs/cart/cart_state.dart';
import 'package:wedly/core/di/injection_container.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;

  // Local cache to preserve timeSlot and other fields that API might not return correctly
  final Map<String, CartItemModel> _localItemCache = {};

  CartBloc({required this.cartRepository}) : super(const CartInitial()) {
    on<CartItemsRequested>(_onCartItemsRequested);
    on<CartItemAdded>(_onCartItemAdded);
    on<CartItemRemoved>(_onCartItemRemoved);
    on<CartItemUpdated>(_onCartItemUpdated);
    on<CartCleared>(_onCartCleared);
    on<CartInitializeMockData>(_onCartInitializeMockData);
    on<CartPricesValidated>(_onCartPricesValidated);
  }

  Future<void> _onCartItemsRequested(
    CartItemsRequested event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(const CartLoading());

      final apiItems = await cartRepository.getCartItems(event.userId);

      debugPrint('🛒 CartBloc._onCartItemsRequested - Loaded ${apiItems.length} items from API');

      // Merge API items with local cache to preserve timeSlot
      final List<CartItemModel> mergedItems = [];
      for (final apiItem in apiItems) {
        // Try both cache keys: by API ID and by service+date
        final cachedById = _localItemCache[apiItem.id];
        final cacheKeyByService = '${apiItem.service.id}_${apiItem.date}';
        final cachedByService = _localItemCache[cacheKeyByService];
        final cachedItem = cachedById ?? cachedByService;

        if (cachedItem != null) {
          // Use cached item's timeSlot if API returned empty/default
          final preservedTimeSlot = (apiItem.timeSlot.isEmpty || apiItem.timeSlot == 'morning')
              && cachedItem.timeSlot.isNotEmpty
              ? cachedItem.timeSlot
              : apiItem.timeSlot;

          final mergedItem = apiItem.copyWith(timeSlot: preservedTimeSlot);
          mergedItems.add(mergedItem);

          // Update cache with the correct API ID
          _localItemCache[apiItem.id] = mergedItem;

          debugPrint('   - ${mergedItem.service.name}: timeSlot="${mergedItem.timeSlot}" (ID: ${apiItem.id}, preserved from cache)');
        } else {
          mergedItems.add(apiItem);
          // Cache API item for future reference
          _localItemCache[apiItem.id] = apiItem;
          debugPrint('   - ${apiItem.service.name}: timeSlot="${apiItem.timeSlot}" (ID: ${apiItem.id}, from API)');
        }
      }

      final itemCount = mergedItems.length;
      final totalPrice = mergedItems.fold<double>(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );

      emit(CartLoaded(
        items: mergedItems,
        itemCount: itemCount,
        totalPrice: totalPrice,
      ));
    } catch (e) {
      emit(CartError(message: 'فشل تحميل السلة: ${ErrorHandler.getUserFriendlyMessage(e)}'));
    }
  }

  Future<void> _onCartItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    try {
      debugPrint('🛒 CartBloc._onCartItemAdded - Adding item with timeSlot: "${event.item.timeSlot}"');

      // Cache the item with correct timeSlot BEFORE adding to API
      // Use service ID as the cache key since the local ID will change
      final cacheKey = '${event.item.service.id}_${event.item.date}';
      _localItemCache[cacheKey] = event.item;
      debugPrint('🛒 CartBloc - Cached item with key "$cacheKey" timeSlot: "${event.item.timeSlot}"');

      // Add to API/storage
      await cartRepository.addToCart(event.item);

      // IMPORTANT: Reload from API to get the correct backend-generated ID
      // This is necessary because the local ID (timestamp) won't work for delete operations
      final apiItems = await cartRepository.getCartItems('');

      debugPrint('🛒 CartBloc - Reloaded ${apiItems.length} items from API after add');

      // Merge API items with local cache to preserve timeSlot
      final List<CartItemModel> mergedItems = [];
      for (final apiItem in apiItems) {
        // Try to find cached item by service ID + date (since IDs don't match)
        final itemCacheKey = '${apiItem.service.id}_${apiItem.date}';
        final cachedItem = _localItemCache[itemCacheKey];

        if (cachedItem != null) {
          // Use cached item's timeSlot if API returned empty/default
          final preservedTimeSlot = (apiItem.timeSlot.isEmpty || apiItem.timeSlot == 'morning')
              && cachedItem.timeSlot.isNotEmpty
              ? cachedItem.timeSlot
              : apiItem.timeSlot;

          final mergedItem = apiItem.copyWith(timeSlot: preservedTimeSlot);
          mergedItems.add(mergedItem);

          // Update cache with correct API ID
          _localItemCache[apiItem.id] = mergedItem;

          debugPrint('   - ${mergedItem.service.name}: timeSlot="${mergedItem.timeSlot}" (ID: ${apiItem.id})');
        } else {
          mergedItems.add(apiItem);
          _localItemCache[apiItem.id] = apiItem;
          debugPrint('   - ${apiItem.service.name}: timeSlot="${apiItem.timeSlot}" (ID: ${apiItem.id}, no cache)');
        }
      }

      final itemCount = mergedItems.length;
      final totalPrice = mergedItems.fold<double>(
        0.0,
        (sum, item) => sum + (item.totalPrice),
      );

      emit(CartLoaded(
        items: mergedItems,
        itemCount: itemCount,
        totalPrice: totalPrice,
      ));
    } catch (e) {
      emit(CartError(message: 'فشل إضافة العنصر: ${ErrorHandler.getUserFriendlyMessage(e)}'));
    }
  }

  Future<void> _onCartItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    // Save the original state to restore if deletion fails
    final CartState originalState = state;

    try {
      debugPrint('🗑️ CartBloc._onCartItemRemoved called with itemId: "${event.itemId}"');

      // Keep track of updated items locally (to preserve timeSlot and other local data)
      List<CartItemModel> updatedItems = [];

      // Optimistically update UI by removing item from current state
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        updatedItems = currentState.items
            .where((item) => item.id != event.itemId)
            .toList();

        // Calculate new totals
        final newItemCount = updatedItems.length;
        final newTotalPrice = updatedItems.fold<double>(
          0.0,
          (sum, item) => sum + item.totalPrice,
        );

        // Emit optimistic update immediately
        emit(CartLoaded(
          items: updatedItems,
          itemCount: newItemCount,
          totalPrice: newTotalPrice,
        ));
      }

      // Perform actual deletion in background
      debugPrint('🗑️ Calling cartRepository.removeFromCart("${event.itemId}")');
      await cartRepository.removeFromCart(event.itemId);

      // Remove from local cache
      _localItemCache.remove(event.itemId);

      // DON'T reload from API - keep using local items to preserve timeSlot
      // The API might not return time_slot correctly
      debugPrint('🛒 CartBloc._onCartItemRemoved - Keeping local items (not reloading from API):');
      for (final item in updatedItems) {
        debugPrint('   - ${item.service.name}: timeSlot="${item.timeSlot}"');
      }
    } catch (e) {
      debugPrint('❌ CartBloc._onCartItemRemoved error: $e');
      debugPrint('   Error type: ${e.runtimeType}');

      // Restore original state since deletion failed
      if (originalState is CartLoaded) {
        emit(originalState);
      }

      // Extract meaningful error message
      String errorMessage = 'فشل حذف العنصر';
      if (e.toString().contains('Invalid id format')) {
        errorMessage = 'معرف العنصر غير صحيح. يرجى إعادة تحميل السلة والمحاولة مرة أخرى';
      } else if (e.toString().contains('404') || e.toString().contains('not found')) {
        errorMessage = 'العنصر غير موجود في السلة';
      } else if (e.toString().contains('401') || e.toString().contains('unauthorized')) {
        errorMessage = 'يرجى تسجيل الدخول مرة أخرى';
      } else if (e.toString().contains('network') || e.toString().contains('internet')) {
        errorMessage = 'تحقق من اتصالك بالإنترنت';
      }

      // Emit error but keep the cart items visible by re-emitting the original loaded state first
      emit(CartError(message: errorMessage));

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed && originalState is CartLoaded) {
          emit(originalState);
        }
      });
    }
  }

  Future<void> _onCartItemUpdated(
    CartItemUpdated event,
    Emitter<CartState> emit,
  ) async {
    try {
      // Update local cache first
      _localItemCache[event.item.id] = event.item;

      await cartRepository.updateCartItem(event.item);

      // Update locally instead of reloading from API
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        final updatedItems = currentState.items.map((item) {
          if (item.id == event.item.id) {
            return event.item;
          }
          return item;
        }).toList();

        final itemCount = updatedItems.length;
        final totalPrice = updatedItems.fold<double>(
          0.0,
          (sum, item) => sum + item.totalPrice,
        );

        emit(CartLoaded(
          items: updatedItems,
          itemCount: itemCount,
          totalPrice: totalPrice,
        ));
      }
    } catch (e) {
      emit(CartError(message: 'فشل تحديث العنصر: ${ErrorHandler.getUserFriendlyMessage(e)}'));
    }
  }

  Future<void> _onCartCleared(
    CartCleared event,
    Emitter<CartState> emit,
  ) async {
    try {
      await cartRepository.clearCart();

      // Clear local cache
      _localItemCache.clear();

      emit(const CartLoaded(
        items: [],
        itemCount: 0,
        totalPrice: 0,
      ));
    } catch (e) {
      emit(CartError(message: 'فشل تفريغ السلة: ${ErrorHandler.getUserFriendlyMessage(e)}'));
    }
  }

  Future<void> _onCartInitializeMockData(
    CartInitializeMockData event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(const CartLoading());

      final items = await cartRepository.getCartItems('current_user');
      final itemCount = await cartRepository.getCartItemCount();
      final totalPrice = await cartRepository.getTotalPrice();

      emit(CartLoaded(
        items: items,
        itemCount: itemCount,
        totalPrice: totalPrice,
      ));
    } catch (e) {
      emit(CartError(message: 'فشل تحميل البيانات: ${ErrorHandler.getUserFriendlyMessage(e)}'));
    }
  }

  Future<void> _onCartPricesValidated(
    CartPricesValidated event,
    Emitter<CartState> emit,
  ) async {
    try {
      // Only validate if we have items in cart
      if (state is! CartLoaded) return;

      final currentState = state as CartLoaded;
      if (currentState.items.isEmpty) return;

      debugPrint('💰 CartBloc - Validating prices for ${currentState.items.length} items');

      // Get service repository to fetch current prices
      final serviceRepository = getIt<ServiceRepository>();

      // Validate and update each item's price to current price
      final List<CartItemModel> updatedItems = [];

      for (final item in currentState.items) {
        try {
          // Fetch current service data
          final currentService = await serviceRepository.getServiceById(item.service.id);

          if (currentService == null) {
            // Service not found, keep original item
            updatedItems.add(item);
            continue;
          }

          // Calculate current price based on service type
          double currentPrice;

          // Determine actual time slot - use timeSlot field, but also check the 'time' display field
          // because API might not return time_slot correctly
          String effectiveTimeSlot = item.timeSlot;

          // If timeSlot is default 'morning' but time display shows evening, use evening
          if (item.timeSlot == 'morning' &&
              (item.time.contains('مسائي') || item.time.contains('مساء'))) {
            effectiveTimeSlot = 'evening';
            debugPrint('   ⚠️ Correcting timeSlot from "morning" to "evening" based on time display: "${item.time}"');
          } else if (item.timeSlot == 'evening' &&
              (item.time.contains('صباحي') || item.time.contains('صباح'))) {
            effectiveTimeSlot = 'morning';
            debugPrint('   ⚠️ Correcting timeSlot from "evening" to "morning" based on time display: "${item.time}"');
          }

          debugPrint('   🔍 Item: ${item.service.name}');
          debugPrint('   🔍 TimeSlot field: "${item.timeSlot}"');
          debugPrint('   🔍 Time display: "${item.time}"');
          debugPrint('   🔍 Effective TimeSlot: "$effectiveTimeSlot"');
          debugPrint('   🔍 Morning price: ${currentService.morningPrice}');
          debugPrint('   🔍 Evening price: ${currentService.eveningPrice}');
          debugPrint('   🔍 Has offer: ${currentService.hasApprovedOffer}');
          debugPrint('   🔍 Discount: ${currentService.discountPercentage}%');

          if (effectiveTimeSlot == 'morning' && currentService.morningPrice != null) {
            // For venues with morning slot - check for discount
            if (currentService.hasApprovedOffer && currentService.discountPercentage != null) {
              currentPrice = currentService.morningPrice! * (1 - currentService.discountPercentage! / 100);
              debugPrint('   💰 Using discounted morning price: $currentPrice');
            } else {
              currentPrice = currentService.morningPrice!;
              debugPrint('   💰 Using regular morning price: $currentPrice');
            }
          } else if (effectiveTimeSlot == 'evening' && currentService.eveningPrice != null) {
            // For venues with evening slot - check for discount
            if (currentService.hasApprovedOffer && currentService.discountPercentage != null) {
              currentPrice = currentService.eveningPrice! * (1 - currentService.discountPercentage! / 100);
              debugPrint('   💰 Using discounted evening price: $currentPrice');
            } else {
              currentPrice = currentService.eveningPrice!;
              debugPrint('   💰 Using regular evening price: $currentPrice');
            }
          } else {
            // Check if service has dynamic sections
            // Backend doesn't store selected options, so we can't recalculate
            try {
              final sections = await serviceRepository.getDynamicSections(currentService.id);

              if (sections.isNotEmpty) {
                // Service has dynamic sections - use stored price from cart
                currentPrice = item.servicePrice;
                debugPrint('   💰 Service has dynamic sections - using stored cart price: $currentPrice');
              } else {
                // Regular service without dynamic sections - use current service price
                currentPrice = currentService.finalPrice ?? currentService.price ?? item.servicePrice;
                debugPrint('   💰 Regular service - using current service price: $currentPrice');
              }
            } catch (e) {
              debugPrint('   ❌ Error checking dynamic sections: $e');
              // Fallback to stored price if API call fails
              currentPrice = item.servicePrice;
              debugPrint('   💰 Using stored cart price (fallback): $currentPrice');
            }
          }

          debugPrint('   📊 Stored price in cart: ${item.servicePrice}');
          debugPrint('   📊 Current price from service: $currentPrice');

          // Always update to current price (no warning, just update)
          updatedItems.add(item.copyWith(
            servicePrice: currentPrice,
            service: currentService, // Update service data too
            priceChanged: false, // Never show as changed
          ));

          debugPrint('   ✅ Updated cart item to current price: ${currentPrice.toInt()} EGP');
        } catch (e) {
          debugPrint('   ❌ Error validating ${item.service.name}: $e');
          // Keep original item if validation fails
          updatedItems.add(item);
        }
      }

      // Recalculate total price
      final newTotalPrice = updatedItems.fold<double>(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );

      debugPrint('✅ Cart prices synced with current service prices');

      emit(CartLoaded(
        items: updatedItems,
        itemCount: updatedItems.length,
        totalPrice: newTotalPrice,
      ));
    } catch (e) {
      debugPrint('❌ Error validating cart prices: $e');
      // Don't emit error - just keep current state
    }
  }
}
