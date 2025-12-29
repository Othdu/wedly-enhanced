import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/repositories/cart_repository.dart';
import 'package:wedly/logic/blocs/cart/cart_event.dart';
import 'package:wedly/logic/blocs/cart/cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;

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

      final items = await cartRepository.getCartItems(event.userId);
      final itemCount = await cartRepository.getCartItemCount();
      final totalPrice = await cartRepository.getTotalPrice();

      emit(CartLoaded(
        items: items,
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
      await cartRepository.addToCart(event.item);

      // Reload cart
      final items = await cartRepository.getCartItems('current_user');
      final itemCount = await cartRepository.getCartItemCount();
      final totalPrice = await cartRepository.getTotalPrice();

      emit(CartLoaded(
        items: items,
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
      // Optimistically update UI by removing item from current state
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        final updatedItems = currentState.items
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

      // Add small delay to allow backend to process deletion
      await Future.delayed(const Duration(milliseconds: 500));

      // Reload cart from backend to ensure consistency
      final items = await cartRepository.getCartItems('current_user');
      final itemCount = await cartRepository.getCartItemCount();
      final totalPrice = await cartRepository.getTotalPrice();

      emit(CartLoaded(
        items: items,
        itemCount: itemCount,
        totalPrice: totalPrice,
      ));
    } catch (e) {
      emit(CartError(message: 'فشل حذف العنصر: ${e.toString()}'));
    }
  }

  Future<void> _onCartItemUpdated(
    CartItemUpdated event,
    Emitter<CartState> emit,
  ) async {
    try {
      await cartRepository.updateCartItem(event.item);

      // Reload cart
      final items = await cartRepository.getCartItems('current_user');
      final itemCount = await cartRepository.getCartItemCount();
      final totalPrice = await cartRepository.getTotalPrice();

      emit(CartLoaded(
        items: items,
        itemCount: itemCount,
        totalPrice: totalPrice,
      ));
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
