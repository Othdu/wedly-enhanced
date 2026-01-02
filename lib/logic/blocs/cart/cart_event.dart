import 'package:equatable/equatable.dart';
import 'package:wedly/data/models/cart_item_model.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartItemsRequested extends CartEvent {
  final String userId;

  const CartItemsRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class CartItemAdded extends CartEvent {
  final CartItemModel item;

  const CartItemAdded({required this.item});

  @override
  List<Object?> get props => [item];
}

class CartItemRemoved extends CartEvent {
  final String itemId;

  const CartItemRemoved({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

class CartItemUpdated extends CartEvent {
  final CartItemModel item;

  const CartItemUpdated({required this.item});

  @override
  List<Object?> get props => [item];
}

class CartCleared extends CartEvent {
  const CartCleared();
}

class CartInitializeMockData extends CartEvent {
  const CartInitializeMockData();
}

class CartPricesValidated extends CartEvent {
  final String userId;

  const CartPricesValidated({required this.userId});

  @override
  List<Object?> get props => [userId];
}
