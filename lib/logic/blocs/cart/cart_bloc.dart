import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/models/cart_item_model.dart';
import 'package:wedly/data/repositories/cart_repository.dart';
import 'package:wedly/logic/blocs/cart/cart_event.dart';
import 'package:wedly/logic/blocs/cart/cart_state.dart';

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
  }

  Future<void> _onCartItemsRequested(
    CartItemsRequested event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(const CartLoading());

      final apiItems = await cartRepository.getCartItems(event.userId);

      print('🛒 CartBloc._onCartItemsRequested - Loaded ${apiItems.length} items from API');

      // Merge API items with local cache to preserve timeSlot
      final List<CartItemModel> mergedItems = [];
      for (final apiItem in apiItems) {
        final cachedItem = _localItemCache[apiItem.id];
        if (cachedItem != null) {
          // Use cached item's timeSlot if API returned empty/default
          final preservedTimeSlot = (apiItem.timeSlot.isEmpty || apiItem.timeSlot == 'morning')
              && cachedItem.timeSlot.isNotEmpty
              ? cachedItem.timeSlot
              : apiItem.timeSlot;

          final mergedItem = apiItem.copyWith(timeSlot: preservedTimeSlot);
          mergedItems.add(mergedItem);
          print('   - ${mergedItem.service.name}: timeSlot="${mergedItem.timeSlot}" (preserved from cache: ${preservedTimeSlot != apiItem.timeSlot})');
        } else {
          mergedItems.add(apiItem);
          // Cache API item for future reference
          _localItemCache[apiItem.id] = apiItem;
          print('   - ${apiItem.service.name}: timeSlot="${apiItem.timeSlot}" (from API, no cache)');
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
      emit(CartError(message: 'فشل تحميل السلة: ${e.toString()}'));
    }
  }

  Future<void> _onCartItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    try {
      print('🛒 CartBloc._onCartItemAdded - Adding item with timeSlot: "${event.item.timeSlot}"');

      // Cache the item with correct timeSlot BEFORE adding to API
      _localItemCache[event.item.id] = event.item;
      print('🛒 CartBloc - Cached item ${event.item.id} with timeSlot: "${event.item.timeSlot}"');

      // Get current items before adding (to preserve local data)
      List<CartItemModel> currentItems = [];
      if (state is CartLoaded) {
        currentItems = List.from((state as CartLoaded).items);
      }

      // Add to API/storage
      await cartRepository.addToCart(event.item);

      // IMPORTANT: Use the original item with correct timeSlot
      // Don't reload from API because API might not return time_slot correctly
      currentItems.add(event.item);

      print('🛒 CartBloc - Items after add:');
      for (final item in currentItems) {
        print('   - ${item.service.name}: timeSlot="${item.timeSlot}"');
      }

      final itemCount = currentItems.length;
      final totalPrice = currentItems.fold<double>(
        0.0,
        (sum, item) => sum + (item.totalPrice),
      );

      emit(CartLoaded(
        items: currentItems,
        itemCount: itemCount,
        totalPrice: totalPrice,
      ));
    } catch (e) {
      emit(CartError(message: 'فشل إضافة العنصر: ${e.toString()}'));
    }
  }

  Future<void> _onCartItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    try {
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
      await cartRepository.removeFromCart(event.itemId);

      // Remove from local cache
      _localItemCache.remove(event.itemId);

      // DON'T reload from API - keep using local items to preserve timeSlot
      // The API might not return time_slot correctly
      print('🛒 CartBloc._onCartItemRemoved - Keeping local items (not reloading from API):');
      for (final item in updatedItems) {
        print('   - ${item.service.name}: timeSlot="${item.timeSlot}"');
      }
    } catch (e) {
      emit(CartError(message: 'فشل حذف العنصر: ${e.toString()}'));
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
      emit(CartError(message: 'فشل تحديث العنصر: ${e.toString()}'));
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
      emit(CartError(message: 'فشل تفريغ السلة: ${e.toString()}'));
    }
  }

  Future<void> _onCartInitializeMockData(
    CartInitializeMockData event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(const CartLoading());

      await cartRepository.initializeMockData();

      final items = await cartRepository.getCartItems('current_user');
      final itemCount = await cartRepository.getCartItemCount();
      final totalPrice = await cartRepository.getTotalPrice();

      emit(CartLoaded(
        items: items,
        itemCount: itemCount,
        totalPrice: totalPrice,
      ));
    } catch (e) {
      emit(CartError(message: 'فشل تحميل البيانات التجريبية: ${e.toString()}'));
    }
  }
}
