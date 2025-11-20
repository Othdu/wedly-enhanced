import 'package:equatable/equatable.dart';
import 'package:wedly/data/models/address_model.dart';

abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {
  const AddressInitial();
}

class AddressLoading extends AddressState {
  const AddressLoading();
}

class CitiesLoaded extends AddressState {
  final List<String> cities;

  const CitiesLoaded(this.cities);

  @override
  List<Object?> get props => [cities];
}

class DistrictsLoaded extends AddressState {
  final List<String> cities;
  final String selectedCity;
  final List<String> districts;

  const DistrictsLoaded({
    required this.cities,
    required this.selectedCity,
    required this.districts,
  });

  @override
  List<Object?> get props => [cities, selectedCity, districts];
}

class AddressFormState extends AddressState {
  final List<String> cities;
  final String? selectedCity;
  final List<String> districts;
  final String? selectedDistrict;
  final String? buildingNumber;
  final AddressModel? existingAddress;

  const AddressFormState({
    required this.cities,
    this.selectedCity,
    required this.districts,
    this.selectedDistrict,
    this.buildingNumber,
    this.existingAddress,
  });

  @override
  List<Object?> get props => [
        cities,
        selectedCity,
        districts,
        selectedDistrict,
        buildingNumber,
        existingAddress,
      ];

  AddressFormState copyWith({
    List<String>? cities,
    String? selectedCity,
    List<String>? districts,
    String? selectedDistrict,
    String? buildingNumber,
    AddressModel? existingAddress,
  }) {
    return AddressFormState(
      cities: cities ?? this.cities,
      selectedCity: selectedCity ?? this.selectedCity,
      districts: districts ?? this.districts,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      existingAddress: existingAddress ?? this.existingAddress,
    );
  }

  bool get isValid =>
      selectedCity != null &&
      selectedDistrict != null &&
      buildingNumber != null &&
      buildingNumber!.isNotEmpty;
}

class UserAddressLoaded extends AddressState {
  final AddressModel? address;

  const UserAddressLoaded(this.address);

  @override
  List<Object?> get props => [address];
}

class AddressSaved extends AddressState {
  final AddressModel address;

  const AddressSaved(this.address);

  @override
  List<Object?> get props => [address];
}

class AddressError extends AddressState {
  final String message;

  const AddressError(this.message);

  @override
  List<Object?> get props => [message];
}
