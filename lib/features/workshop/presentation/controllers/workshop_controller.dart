import 'package:get/get.dart';
import 'package:car_workshop/core/errors/failure.dart';
import 'package:car_workshop/core/services/auth_service.dart';
import 'package:car_workshop/core/services/snackbar_service.dart';
import 'package:car_workshop/core/utils/logger_util.dart';
import 'package:car_workshop/features/workshop/domain/entities/workshop_entity.dart';
import 'package:car_workshop/features/workshop/data/repositories/workshop_repository.dart';

class WorkshopController extends GetxController {
  final WorkshopRepository workshopRepository;
  final AuthService authService;

  WorkshopController(this.workshopRepository, this.authService);

  var workshops = <WorkshopEntity>[].obs;
  var selectedWorkshop = Rx<WorkshopEntity?>(null);
  var isLoading = false.obs;
  var failureMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWorkshops();
  }

  /// Create new workshop
  Future<void> createWorkshop({
    required String name,
    required String location,
  }) async {
    // Validation
    if (name.isEmpty || location.isEmpty) {
      SnackbarService.showErrorMessage('Name and location cannot be empty');
      return;
    }

    if (authService.currentUser == null) {
      SnackbarService.showErrorMessage('User not authenticated');
      return;
    }

    isLoading.value = true;
    Logger.featureEntry('WorkshopController.createWorkshop', {
      'name': name,
      'location': location,
    });

    try {
      final result = await workshopRepository.createWorkshop(
        name: name,
        location: location,
        ownerId: authService.currentUser!.id!,
        ownerName: authService.currentUser!.name,
        ownerEmail: authService.currentUser!.email,
      );

      isLoading.value = false;

      result.fold(
        (Failure failure) {
          failureMessage.value = failure.message;
          SnackbarService.showErrorMessage(failure.message);
          Logger.error('Workshop creation failed: ${failure.message}');
        },
        (workshopModel) {
          workshops.add(workshopModel.toEntity());
          selectedWorkshop.value = workshopModel.toEntity();
          SnackbarService.showSuccessMessage('Workshop created successfully');
          Logger.success('Workshop created: ${workshopModel.id}');
          Logger.featureExit('WorkshopController.createWorkshop', {'success': true});
        },
      );
    } catch (e) {
      isLoading.value = false;
      failureMessage.value = e.toString();
      SnackbarService.showErrorMessage('Failed to create workshop');
      Logger.error('Exception in createWorkshop: $e');
    }
  }

  /// Fetch all workshops for current user
  Future<void> fetchWorkshops() async {
    if (authService.currentUser == null) {
      Logger.warning('User not authenticated for fetchWorkshops');
      return;
    }

    isLoading.value = true;
    Logger.featureEntry('WorkshopController.fetchWorkshops', {});

    try {
      final result =
          await workshopRepository.getWorkshopsForUser(authService.currentUser!.id!);

      isLoading.value = false;

      result.fold(
        (Failure failure) {
          failureMessage.value = failure.message;
          Logger.error('Failed to fetch workshops: ${failure.message}');
        },
        (workshopModels) {
          workshops.value = workshopModels.map((m) => m.toEntity()).toList();
          if (workshops.isNotEmpty) {
            selectedWorkshop.value = workshops.first;
          }
          Logger.success('Workshops fetched: ${workshops.length}');
          Logger.featureExit('WorkshopController.fetchWorkshops',
              {'count': workshops.length});
        },
      );
    } catch (e) {
      isLoading.value = false;
      failureMessage.value = e.toString();
      Logger.error('Exception in fetchWorkshops: $e');
    }
  }

  /// Select workshop
  void selectWorkshop(WorkshopEntity workshop) {
    selectedWorkshop.value = workshop;
    Logger.info('Workshop selected: ${workshop.id}');
  }

  /// Update workshop
  Future<void> updateWorkshop({
    required String workshopId,
    required String name,
    required String location,
  }) async {
    if (name.isEmpty || location.isEmpty) {
      SnackbarService.showErrorMessage('Name and location cannot be empty');
      return;
    }

    isLoading.value = true;

    try {
      final result = await workshopRepository.updateWorkshop(
        workshopId: workshopId,
        name: name,
        location: location,
      );

      isLoading.value = false;

      result.fold(
        (Failure failure) {
          failureMessage.value = failure.message;
          SnackbarService.showErrorMessage(failure.message);
        },
        (_) {
          // Update local list
          final index =
              workshops.indexWhere((w) => w.id == workshopId);
          if (index != -1) {
            workshops[index] = workshops[index].copyWith(
              name: name,
              location: location,
              updatedAt: DateTime.now(),
            );
          }
          SnackbarService.showSuccessMessage('Workshop updated successfully');
          Logger.success('Workshop updated: $workshopId');
        },
      );
    } catch (e) {
      isLoading.value = false;
      failureMessage.value = e.toString();
      SnackbarService.showErrorMessage('Failed to update workshop');
      Logger.error('Exception in updateWorkshop: $e');
    }
  }

  /// Delete workshop
  Future<void> deleteWorkshop(String workshopId) async {
    isLoading.value = true;

    try {
      final result = await workshopRepository.deleteWorkshop(workshopId);

      isLoading.value = false;

      result.fold(
        (Failure failure) {
          failureMessage.value = failure.message;
          SnackbarService.showErrorMessage(failure.message);
        },
        (_) {
          workshops.removeWhere((w) => w.id == workshopId);
          if (selectedWorkshop.value?.id == workshopId) {
            selectedWorkshop.value = workshops.isNotEmpty ? workshops.first : null;
          }
          SnackbarService.showSuccessMessage('Workshop deleted successfully');
          Logger.success('Workshop deleted: $workshopId');
        },
      );
    } catch (e) {
      isLoading.value = false;
      failureMessage.value = e.toString();
      SnackbarService.showErrorMessage('Failed to delete workshop');
      Logger.error('Exception in deleteWorkshop: $e');
    }
  }
}
