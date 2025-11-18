import 'package:equatable/equatable.dart';
import 'package:wedly/data/models/cart_item_model.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  final List<CartItemModel> items;
  final int itemCount;
  final double totalPrice;

  const CartLoaded({
    required this.items,
    required this.itemCount,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [items, itemCount, totalPrice];

  CartLoaded copyWith({
    List<CartItemModel>? items,
    int? itemCount,
    double? totalPrice,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      itemCount: itemCount ?? this.itemCount,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

class CartError extends CartState {
  final String message;

  const CartError({required this.message});

  @override
  List<Object?> get props => [message];
}
