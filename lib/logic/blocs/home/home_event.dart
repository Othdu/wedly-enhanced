import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeServicesRequested extends HomeEvent {
  final String? userId;

  const HomeServicesRequested({this.userId});

  @override
  List<Object?> get props => [userId];
}

class HomeCategoriesRequested extends HomeEvent {
  const HomeCategoriesRequested();
}

