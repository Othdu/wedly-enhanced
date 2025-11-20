import 'package:equatable/equatable.dart';
import 'package:wedly/data/models/address_model.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

class LoadCities extends AddressEvent {
  const LoadCities();
}

class LoadDistricts extends AddressEvent {
  final String city;

  const LoadDistricts(this.city);

  @override
  List<Object?> get props => [city];
}

class LoadUserAddress extends AddressEvent {
  final String userId;

  const LoadUserAddress(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SaveAddress extends AddressEvent {
  final String userId;
  final AddressModel address;

  const SaveAddress({
    required this.userId,
    required this.address,
  });

  @override
  List<Object?> get props => [userId, address];
}

class UpdateAddress extends AddressEvent {
  final String userId;
  final AddressModel address;

  const UpdateAddress({
    required this.userId,
    required this.address,
  });

  @override
  List<Object?> get props => [userId, address];
}

class SelectCity extends AddressEvent {
  final String city;

  const SelectCity(this.city);

  @override
  List<Object?> get props => [city];
}

class SelectDistrict extends AddressEvent {
  final String district;

  const SelectDistrict(this.district);

  @override
  List<Object?> get props => [district];
}

class SetBuildingNumber extends AddressEvent {
  final String buildingNumber;

  const SetBuildingNumber(this.buildingNumber);

  @override
  List<Object?> get props => [buildingNumber];
}
