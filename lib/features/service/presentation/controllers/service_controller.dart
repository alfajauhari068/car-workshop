import 'package:get/get.dart';
import 'package:car_workshop/core/errors/failure.dart';
import 'package:car_workshop/core/services/snackbar_service.dart';
import 'package:car_workshop/core/utils/logger_util.dart';
import 'package:car_workshop/features/service/domain/entities/service_entity.dart';
import 'package:car_workshop/features/service/data/repositories/service_repository.dart';

class ServiceController extends GetxController {
  final ServiceRepository serviceRepository;

  ServiceController(this.serviceRepository);

  var services = <ServiceEntity>[].obs;
  var selectedService = Rx<ServiceEntity?>(null);
  var currentWorkshopId = ''.obs;
  var isLoading = false.obs;
  var failureMessage = ''.obs;

  /// Initialize controller with workshop ID and fetch services
  void initializeWithWorkshop(String workshopId) {
    currentWorkshopId.value = workshopId;
    fetchServices();
  }

  /// Create new service for current workshop
  Future<void> createService({
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
  }) async {
    // Validation
    if (name.isEmpty || description.isEmpty) {
      SnackbarService.showErrorMessage('Name and description are required');
      return;
    }
    if (price < 0 || durationMinutes <= 0) {
      SnackbarService.showErrorMessage('Price must be >= 0 and duration > 0');
      return;
    }
    if (currentWorkshopId.isEmpty) {
      SnackbarService.showErrorMessage('Workshop not selected');
      return;
    }

    isLoading.value = true;
    Logger.featureEntry('ServiceController.createService', {
      'name': name,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'workshopId': currentWorkshopId.value,
    });

    try {
      final result = await serviceRepository.createService(
        workshopId: currentWorkshopId.value,
        name: name,
        description: description,
        price: price,
        durationMinutes: durationMinutes,
      );

      isLoading.value = false;

      result.fold(
        (Failure failure) {
          failureMessage.value = failure.message;
          SnackbarService.showErrorMessage(failure.message);
          Logger.error('Service creation failed: ${failure.message}');
        },
        (serviceModel) {
          services.add(serviceModel.toEntity());
          selectedService.value = serviceModel.toEntity();
          SnackbarService.showSuccessMessage('Service created successfully');
          Logger.success('Service created: ${serviceModel.id}');
          Logger.featureExit('ServiceController.createService', {'success': true});
        },
      );
    } catch (e) {
      isLoading.value = false;
      failureMessage.value = e.toString();
      SnackbarService.showErrorMessage('Failed to create service');
      Logger.error('Exception in createService: $e');
    }
  }

  /// Fetch all services for current workshop
  Future<void> fetchServices() async {
    if (currentWorkshopId.isEmpty) {
      Logger.warning('Workshop ID not set for fetchServices');
      return;
    }

    isLoading.value = true;
    Logger.featureEntry('ServiceController.fetchServices', {
      'workshopId': currentWorkshopId.value,
    });

    try {
      final result = await serviceRepository.getServicesForWorkshop(
        currentWorkshopId.value,
      );

      isLoading.value = false;

      result.fold(
        (Failure failure) {
          failureMessage.value = failure.message;
          Logger.error('Failed to fetch services: ${failure.message}');
        },
        (serviceModels) {
          services.value = serviceModels.map((m) => m.toEntity()).toList();
          if (services.isNotEmpty) {
            selectedService.value = services.first;
          }
          Logger.success('Services fetched: ${services.length}');
          Logger.featureExit('ServiceController.fetchServices',
              {'count': services.length});
        },
      );
    } catch (e) {
      isLoading.value = false;
      failureMessage.value = e.toString();
      Logger.error('Exception in fetchServices: $e');
    }
  }

  /// Select service
  void selectService(ServiceEntity service) {
    selectedService.value = service;
    Logger.info('Service selected: ${service.id}');
  }

  /// Update service
  Future<void> updateService({
    required String serviceId,
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
  }) async {
    if (name.isEmpty || description.isEmpty) {
      SnackbarService.showErrorMessage('Name and description are required');
      return;
    }
    if (price < 0 || durationMinutes <= 0) {
      SnackbarService.showErrorMessage('Price must be >= 0 and duration > 0');
      return;
    }

    isLoading.value = true;

    try {
      final result = await serviceRepository.updateService(
        workshopId: currentWorkshopId.value,
        serviceId: serviceId,
        name: name,
        description: description,
        price: price,
        durationMinutes: durationMinutes,
      );

      isLoading.value = false;

      result.fold(
        (Failure failure) {
          failureMessage.value = failure.message;
          SnackbarService.showErrorMessage(failure.message);
        },
        (_) {
          // Update local list
          final index = services.indexWhere((s) => s.id == serviceId);
          if (index != -1) {
            services[index] = services[index].copyWith(
              name: name,
              description: description,
              price: price,
              durationMinutes: durationMinutes,
              updatedAt: DateTime.now(),
            );
          }
          SnackbarService.showSuccessMessage('Service updated successfully');
          Logger.success('Service updated: $serviceId');
        },
      );
    } catch (e) {
      isLoading.value = false;
      failureMessage.value = e.toString();
      SnackbarService.showErrorMessage('Failed to update service');
      Logger.error('Exception in updateService: $e');
    }
  }

  /// Delete service
  Future<void> deleteService(String serviceId) async {
    isLoading.value = true;

    try {
      final result = await serviceRepository.deleteService(
        workshopId: currentWorkshopId.value,
        serviceId: serviceId,
      );

      isLoading.value = false;

      result.fold(
        (Failure failure) {
          failureMessage.value = failure.message;
          SnackbarService.showErrorMessage(failure.message);
        },
        (_) {
          services.removeWhere((s) => s.id == serviceId);
          if (selectedService.value?.id == serviceId) {
            selectedService.value = services.isNotEmpty ? services.first : null;
          }
          SnackbarService.showSuccessMessage('Service deleted successfully');
          Logger.success('Service deleted: $serviceId');
        },
      );
    } catch (e) {
      isLoading.value = false;
      failureMessage.value = e.toString();
      SnackbarService.showErrorMessage('Failed to delete service');
      Logger.error('Exception in deleteService: $e');
    }
  }
}
