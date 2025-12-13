import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/service_repository.dart';
import 'provider_service_event.dart';
import 'provider_service_state.dart';

class ProviderServiceBloc extends Bloc<ProviderServiceEvent, ProviderServiceState> {
  final ServiceRepository serviceRepository;

  ProviderServiceBloc({required this.serviceRepository})
      : super(ProviderServiceInitial()) {
    on<FetchProviderServices>(_onFetchProviderServices);
    on<AddService>(_onAddService);
    on<UpdateService>(_onUpdateService);
    on<DeleteService>(_onDeleteService);
    on<ToggleServiceStatus>(_onToggleServiceStatus);
    on<RefreshProviderServices>(_onRefreshProviderServices);
  }

  Future<void> _onFetchProviderServices(
    FetchProviderServices event,
    Emitter<ProviderServiceState> emit,
  ) async {
    emit(ProviderServiceLoading());
    try {
      final services = await serviceRepository.getProviderServices(event.providerId);

      if (services.isEmpty) {
        emit(const ProviderServicesEmpty('لم تقم بإضافة أي خدمات بعد'));
      } else {
        emit(ProviderServicesLoaded(services));
      }
    } catch (e) {
      emit(ProviderServiceError('فشل تحميل الخدمات: ${e.toString()}', error: e));
    }
  }

  Future<void> _onAddService(
    AddService event,
    Emitter<ProviderServiceState> emit,
  ) async {
    emit(ProviderServiceLoading());
    try {
      final newService = await serviceRepository.addService(event.service);
      emit(ServiceAdded(newService, 'تم إضافة الخدمة بنجاح'));
    } catch (e) {
      emit(ProviderServiceError('فشل إضافة الخدمة: ${e.toString()}', error: e));
    }
  }

  Future<void> _onUpdateService(
    UpdateService event,
    Emitter<ProviderServiceState> emit,
  ) async {
    emit(ProviderServiceLoading());
    try {
      final updatedService = await serviceRepository.updateService(event.service);
      emit(ServiceUpdated(updatedService, 'تم تعديل الخدمة بنجاح'));
    } catch (e) {
      emit(ProviderServiceError('فشل تعديل الخدمة: ${e.toString()}', error: e));
    }
  }

  Future<void> _onDeleteService(
    DeleteService event,
    Emitter<ProviderServiceState> emit,
  ) async {
    try {
      await serviceRepository.deleteService(event.serviceId);
      emit(ServiceDeleted(event.serviceId, 'تم حذف الخدمة بنجاح'));
    } catch (e) {
      emit(ProviderServiceError('فشل حذف الخدمة: ${e.toString()}', error: e));
    }
  }

  Future<void> _onToggleServiceStatus(
    ToggleServiceStatus event,
    Emitter<ProviderServiceState> emit,
  ) async {
    try {
      final updatedService = await serviceRepository.toggleServiceStatus(event.serviceId);
      final statusText = updatedService.isActive ? 'مفعلة' : 'معطلة';
      emit(ServiceStatusToggled(
        updatedService,
        'الخدمة الآن $statusText',
      ));
    } catch (e) {
      emit(ProviderServiceError('فشل تحديث حالة الخدمة: ${e.toString()}', error: e));
    }
  }

  Future<void> _onRefreshProviderServices(
    RefreshProviderServices event,
    Emitter<ProviderServiceState> emit,
  ) async {
    try {
      final services = await serviceRepository.getProviderServices(event.providerId);

      if (services.isEmpty) {
        emit(const ProviderServicesEmpty('لم تقم بإضافة أي خدمات بعد'));
      } else {
        emit(ProviderServicesLoaded(services));
      }
    } catch (e) {
      emit(ProviderServiceError('فشل تحديث الخدمات: ${e.toString()}', error: e));
    }
  }
}
