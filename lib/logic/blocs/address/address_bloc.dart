import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/repositories/address_repository.dart';
import 'package:wedly/logic/blocs/address/address_event.dart';
import 'package:wedly/logic/blocs/address/address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository addressRepository;

  AddressBloc({required this.addressRepository}) : super(const AddressInitial()) {
    on<LoadCities>(_onLoadCities);
    on<LoadDistricts>(_onLoadDistricts);
    on<LoadUserAddress>(_onLoadUserAddress);
    on<SaveAddress>(_onSaveAddress);
    on<UpdateAddress>(_onUpdateAddress);
    on<SelectCity>(_onSelectCity);
    on<SelectDistrict>(_onSelectDistrict);
    on<SetBuildingNumber>(_onSetBuildingNumber);
  }

  Future<void> _onLoadCities(
    LoadCities event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressLoading());
    try {
      final cities = await addressRepository.getCities();
      emit(AddressFormState(cities: cities, districts: const []));
    } catch (e) {
      emit(AddressError('فشل في تحميل المدن: ${e.toString()}'));
    }
  }

  Future<void> _onLoadDistricts(
    LoadDistricts event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressLoading());
    try {
      final cities = await addressRepository.getCities();
      final districts = await addressRepository.getDistricts(event.city);
      emit(DistrictsLoaded(
        cities: cities,
        selectedCity: event.city,
        districts: districts,
      ));
    } catch (e) {
      emit(AddressError('فشل في تحميل المناطق: ${e.toString()}'));
    }
  }

  Future<void> _onLoadUserAddress(
    LoadUserAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressLoading());
    try {
      final cities = await addressRepository.getCities();
      final address = await addressRepository.getUserAddress(event.userId);

      if (address != null) {
        // Load districts for the saved city
        final districts = await addressRepository.getDistricts(address.city);
        emit(AddressFormState(
          cities: cities,
          selectedCity: address.city,
          districts: districts,
          selectedDistrict: address.district,
          buildingNumber: address.buildingNumber,
          existingAddress: address,
        ));
      } else {
        emit(AddressFormState(cities: cities, districts: const []));
      }
    } catch (e) {
      emit(AddressError('فشل في تحميل العنوان: ${e.toString()}'));
    }
  }

  Future<void> _onSaveAddress(
    SaveAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressLoading());
    try {
      final savedAddress = await addressRepository.saveAddress(
        event.userId,
        event.address,
      );
      emit(AddressSaved(savedAddress));
    } catch (e) {
      emit(AddressError('فشل في حفظ العنوان: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateAddress(
    UpdateAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressLoading());
    try {
      final updatedAddress = await addressRepository.updateAddress(
        event.userId,
        event.address,
      );
      emit(AddressSaved(updatedAddress));
    } catch (e) {
      emit(AddressError('فشل في تحديث العنوان: ${e.toString()}'));
    }
  }

  Future<void> _onSelectCity(
    SelectCity event,
    Emitter<AddressState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AddressFormState) return;

    // Show loading while fetching districts
    emit(const AddressLoading());

    try {
      final districts = await addressRepository.getDistricts(event.city);
      emit(currentState.copyWith(
        selectedCity: event.city,
        districts: districts,
        selectedDistrict: null, // Reset district when city changes
      ));
    } catch (e) {
      emit(AddressError('فشل في تحميل المناطق: ${e.toString()}'));
    }
  }

  Future<void> _onSelectDistrict(
    SelectDistrict event,
    Emitter<AddressState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AddressFormState) return;

    emit(currentState.copyWith(selectedDistrict: event.district));
  }

  Future<void> _onSetBuildingNumber(
    SetBuildingNumber event,
    Emitter<AddressState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AddressFormState) return;

    emit(currentState.copyWith(buildingNumber: event.buildingNumber));
  }
}
