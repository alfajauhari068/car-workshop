import 'package:get/get.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../domain/usecases/update_profile_use_case.dart';

class ProfileController extends GetxController {
  final UpdateProfileUseCase updateProfileUseCase;
  final AuthService authService;

  ProfileController(this.updateProfileUseCase, this.authService);

  var isLoading = false.obs;
  var failureMessage = ''.obs;

  Future<void> completeProfile(List<String> skills, String yearsOfExperience) async {
    // Validate input
    if (skills.isEmpty) {
      SnackbarService.showErrorMessage('Please enter at least one skill');
      return;
    }

    if (yearsOfExperience.isEmpty) {
      SnackbarService.showErrorMessage('Please enter years of experience');
      return;
    }

    isLoading.value = true;
    final currentUser = authService.currentUser;

    if (currentUser == null || currentUser.id == null) {
      isLoading.value = false;
      SnackbarService.showErrorMessage('User not found');
      return;
    }

    final result = await updateProfileUseCase.call(
      UpdateProfileParams(
        uid: currentUser.id!,
        skills: skills,
        yearsOfExperience: yearsOfExperience,
      ),
    );

    isLoading.value = false;

    result.fold(
      (Failure failure) {
        failureMessage.value = failure.message;
        SnackbarService.showErrorMessage(failure.message);
      },
      (updatedUser) {
        SnackbarService.showSuccessMessage('Profile updated successfully!');
        // Redirect to mechanic dashboard
        Get.offAllNamed(AppRoutes.mechanicDashboard);
      },
    );
  }
}
