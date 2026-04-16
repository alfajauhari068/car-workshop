import 'package:car_workshop/core/utils/logger_util.dart';
import 'package:get/get.dart';
import 'package:car_workshop/features/workshop/data/repositories/workshop_staff_repository.dart';
import 'package:car_workshop/features/workshop/domain/entities/workshop_staff_entity.dart';

class WorkshopStaffController extends GetxController {
  final WorkshopStaffRepository repository;

  WorkshopStaffController(this.repository);

  // Observable state
  RxList<WorkshopStaffEntity> staffList = <WorkshopStaffEntity>[].obs;
  RxBool isLoading = false.obs;
  RxBool isAdding = false.obs;
  RxString errorMessage = ''.obs;
  RxString currentWorkshopId = ''.obs;

  /// Load all staff members for a workshop
  Future<void> loadStaffForWorkshop(String workshopId) async {
    try {
      isLoading(true);
      currentWorkshopId.value = workshopId;
      Logger.info('Loading staff for workshop: $workshopId');

      final result = await repository.getStaffForWorkshop(workshopId);

      result.fold(
        (failure) {
          Logger.error('Failed to load staff: $failure');
          errorMessage.value = failure.toString();
          staffList.clear();
        },
        (staff) {
          Logger.success('Loaded ${staff.length} staff members');
          staffList.assignAll(staff);
          errorMessage.value = '';
        },
      );
    } catch (e) {
      Logger.error('Error loading staff: $e');
      errorMessage.value = 'Error loading staff: $e';
    } finally {
      isLoading(false);
    }
  }

  /// Add new staff member to workshop
  Future<bool> addStaffToWorkshop({
    required String workshopId,
    required String userId,
    required String name,
    required String email,
    required String role,
  }) async {
    try {
      isAdding(true);
      Logger.info(
        'Adding staff: user=$userId, workshop=$workshopId, role=$role',
      );

      // Convert String role to WorkshopRole enum
      final workshopRole = WorkshopRoleExtension.fromString(role);

      final result = await repository.addStaffToWorkshop(
        workshopId: workshopId,
        userId: userId,
        name: name,
        email: email,
        role: workshopRole,
      );

      final success = result.fold(
        (failure) {
          Logger.error('Failed to add staff: $failure');
          errorMessage.value = failure.toString();
          return false;
        },
        (staff) {
          Logger.success('Staff added successfully');
          staffList.add(staff);
          errorMessage.value = '';
          return true;
        },
      );

      return success;
    } catch (e) {
      Logger.error('Error adding staff: $e');
      errorMessage.value = 'Error adding staff: $e';
      return false;
    } finally {
      isAdding(false);
    }
  }

  /// Update staff member role
  Future<bool> updateStaffRole({
    required String staffId,
    required String newRole,
  }) async {
    try {
      isLoading(true);
      Logger.info('Updating staff role: $staffId -> $newRole');

      final result = await repository.updateStaffRole(
        staffId: staffId,
        newRole: newRole,
      );

      final success = result.fold(
        (failure) {
          Logger.error('Failed to update staff: $failure');
          errorMessage.value = failure.toString();
          return false;
        },
        (updatedStaff) {
          Logger.success('Staff updated successfully');
          final index = staffList
              .indexWhere((staff) => staff.id == updatedStaff.id);
          if (index != -1) {
            staffList[index] = updatedStaff;
          }
          errorMessage.value = '';
          return true;
        },
      );

      return success;
    } catch (e) {
      Logger.error('Error updating staff: $e');
      errorMessage.value = 'Error updating staff: $e';
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// Remove staff member from workshop
  Future<bool> removeStaffFromWorkshop(String staffId) async {
    try {
      isLoading(true);
      Logger.info('Removing staff: $staffId');

      final result = await repository.removeStaffFromWorkshop(staffId);

      final success = result.fold(
        (failure) {
          Logger.error('Failed to remove staff: $failure');
          errorMessage.value = failure.toString();
          return false;
        },
        (_) {
          Logger.success('Staff removed successfully');
          staffList.removeWhere((staff) => staff.id == staffId);
          errorMessage.value = '';
          return true;
        },
      );

      return success;
    } catch (e) {
      Logger.error('Error removing staff: $e');
      errorMessage.value = 'Error removing staff: $e';
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// Get staff count for workshop
  Future<int> getStaffCount(String workshopId) async {
    try {
      final result = await repository.countStaffInWorkshop(workshopId);
      return result.fold(
        (failure) {
          Logger.error('Failed to count staff: $failure');
          return 0;
        },
        (count) => count,
      );
    } catch (e) {
      Logger.error('Error counting staff: $e');
      return 0;
    }
  }

  /// Clear state on route change
  void clearState() {
    staffList.clear();
    errorMessage.value = '';
    currentWorkshopId.value = '';
  }
}
