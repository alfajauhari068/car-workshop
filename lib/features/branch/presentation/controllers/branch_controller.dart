import 'package:get/get.dart';
import 'package:car_workshop/core/errors/failure.dart';
import 'package:car_workshop/core/services/snackbar_service.dart';
import 'package:car_workshop/core/utils/logger_util.dart';
import 'package:car_workshop/features/branch/domain/entities/branch_entity.dart';
import 'package:car_workshop/features/branch/data/repositories/branch_repository.dart';

class BranchController extends GetxController {
  final BranchRepository branchRepository;

  BranchController(this.branchRepository);

  var branches = <BranchEntity>[].obs;
  var selectedBranch = Rx<BranchEntity?>(null);
  var currentWorkshopId = ''.obs;
  var isLoading = false.obs;
  var failureMessage = ''.obs;

  /// Initialize controller with workshop ID and fetch branches
  void initializeWithWorkshop(String workshopId) {
    currentWorkshopId.value = workshopId;
    fetchBranches();
  }

  /// Create new branch for current workshop
  Future<void> createBranch({
    required String name,
    required String address,
    required String phone,
  }) async {
    // Validation
    if (name.isEmpty || address.isEmpty || phone.isEmpty) {
      SnackbarService.showErrorMessage('All fields are required');
      return;
    }

    if (currentWorkshopId.isEmpty) {
      SnackbarService.showErrorMessage('Workshop not selected');
      return;
    }

    isLoading.value = true;
    Logger.featureEntry('BranchController.createBranch', {
      'name': name,
      'address': address,
      'phone': phone,
      'workshopId': currentWorkshopId.value,
    });

    try {
      final result = await branchRepository.createBranch(
        workshopId: currentWorkshopId.value,
        name: name,
        address: address,
        phone: phone,
      );

      isLoading.value = false;

      result.fold(
        (Failure failure) {
          failureMessage.value = failure.message;
          SnackbarService.showErrorMessage(failure.message);
          Logger.error('Branch creation failed: ${failure.message}');
        },
        (branchModel) {
          branches.add(branchModel.toEntity());
          selectedBranch.value = branchModel.toEntity();
          SnackbarService.showSuccessMessage('Branch created successfully');
          Logger.success('Branch created: ${branchModel.id}');
          Logger.featureExit('BranchController.createBranch', {'success': true});
        },
      );
    } catch (e) {
      isLoading.value = false;
      failureMessage.value = e.toString();
      SnackbarService.showErrorMessage('Failed to create branch');
      Logger.error('Exception in createBranch: $e');
    }
  }

  /// Fetch all branches for current workshop
  Future<void> fetchBranches() async {
    if (currentWorkshopId.isEmpty) {
      Logger.warning('Workshop ID not set for fetchBranches');
      return;
    }

    isLoading.value = true;
    Logger.featureEntry('BranchController.fetchBranches', {
      'workshopId': currentWorkshopId.value,
    });

    try {
      final result = await branchRepository.getBranchesForWorkshop(
        currentWorkshopId.value,
      );

      isLoading.value = false;

      result.fold(
        (Failure failure) {
          failureMessage.value = failure.message;
          Logger.error('Failed to fetch branches: ${failure.message}');
        },
        (branchModels) {
          branches.value = branchModels.map((m) => m.toEntity()).toList();
          if (branches.isNotEmpty) {
            selectedBranch.value = branches.first;
          }
          Logger.success('Branches fetched: ${branches.length}');
          Logger.featureExit('BranchController.fetchBranches',
              {'count': branches.length});
        },
      );
    } catch (e) {
      isLoading.value = false;
      failureMessage.value = e.toString();
      Logger.error('Exception in fetchBranches: $e');
    }
  }

  /// Select branch
  void selectBranch(BranchEntity branch) {
    selectedBranch.value = branch;
    Logger.info('Branch selected: ${branch.id}');
  }

  /// Update branch
  Future<void> updateBranch({
    required String branchId,
    required String name,
    required String address,
    required String phone,
  }) async {
    if (name.isEmpty || address.isEmpty || phone.isEmpty) {
      SnackbarService.showErrorMessage('All fields are required');
      return;
    }

    isLoading.value = true;

    try {
      final result = await branchRepository.updateBranch(
        workshopId: currentWorkshopId.value,
        branchId: branchId,
        name: name,
        address: address,
        phone: phone,
      );

      isLoading.value = false;

      result.fold(
        (Failure failure) {
          failureMessage.value = failure.message;
          SnackbarService.showErrorMessage(failure.message);
        },
        (_) {
          // Update local list
          final index = branches.indexWhere((b) => b.id == branchId);
          if (index != -1) {
            branches[index] = branches[index].copyWith(
              name: name,
              address: address,
              phone: phone,
              updatedAt: DateTime.now(),
            );
          }
          SnackbarService.showSuccessMessage('Branch updated successfully');
          Logger.success('Branch updated: $branchId');
        },
      );
    } catch (e) {
      isLoading.value = false;
      failureMessage.value = e.toString();
      SnackbarService.showErrorMessage('Failed to update branch');
      Logger.error('Exception in updateBranch: $e');
    }
  }

  /// Delete branch
  Future<void> deleteBranch(String branchId) async {
    isLoading.value = true;

    try {
      final result = await branchRepository.deleteBranch(
        workshopId: currentWorkshopId.value,
        branchId: branchId,
      );

      isLoading.value = false;

      result.fold(
        (Failure failure) {
          failureMessage.value = failure.message;
          SnackbarService.showErrorMessage(failure.message);
        },
        (_) {
          branches.removeWhere((b) => b.id == branchId);
          if (selectedBranch.value?.id == branchId) {
            selectedBranch.value = branches.isNotEmpty ? branches.first : null;
          }
          SnackbarService.showSuccessMessage('Branch deleted successfully');
          Logger.success('Branch deleted: $branchId');
        },
      );
    } catch (e) {
      isLoading.value = false;
      failureMessage.value = e.toString();
      SnackbarService.showErrorMessage('Failed to delete branch');
      Logger.error('Exception in deleteBranch: $e');
    }
  }
}
