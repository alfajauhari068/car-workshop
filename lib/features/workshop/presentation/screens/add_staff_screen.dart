import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:car_workshop/core/constants/app_strings.dart';
import 'package:car_workshop/core/common/widgets/widgets.dart';
import 'package:car_workshop/core/style/app_colors.dart';
import 'package:car_workshop/core/utils/logger_util.dart';
import '../controllers/workshop_staff_controller.dart';

class AddStaffScreen extends StatefulWidget {
  final String workshopId;
  final String workshopName;

  const AddStaffScreen({
    super.key,
    required this.workshopId,
    required this.workshopName,
  });

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  late final WorkshopStaffController controller;
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  Rx<String?> selectedRole = Rx<String?>(null);
  RxBool isSubmitting = false.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.find<WorkshopStaffController>();
  }

  bool _validateInputs() {
    if (userIdController.text.isEmpty) {
      _showError('Please enter user ID (email)');
      return false;
    }

    if (nameController.text.isEmpty) {
      _showError('Please enter staff name');
      return false;
    }

    if (emailController.text.isEmpty) {
      _showError('Please enter staff email');
      return false;
    }

    if (!_isValidEmail(emailController.text)) {
      _showError('Please enter a valid email');
      return false;
    }

    if (selectedRole.value == null) {
      _showError('Please select a role');
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _showError(String message) {
    Get.snackbar(
      'Validation Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    Logger.warning('Validation error: $message');
  }

  Future<void> _submitAddStaff() async {
    if (!_validateInputs()) {
      return;
    }

    try {
      isSubmitting(true);
      Logger.info(
        'Adding staff: user=${userIdController.text}, workshop=${widget.workshopId}, role=${selectedRole.value}',
      );

      final success = await controller.addStaffToWorkshop(
        workshopId: widget.workshopId,
        userId: userIdController.text.trim(),
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        role: selectedRole.value!,
      );

      if (success) {
        Logger.success('Staff added successfully');
        Get.snackbar(
          'Success',
          'Staff member added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.back();
        });
      } else {
        Logger.error('Failed to add staff: ${controller.errorMessage.value}');
        Get.snackbar(
          'Error',
          controller.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Logger.error('Exception adding staff: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting(false);
    }
  }

  Widget _buildRoleOption({
    required String role,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(
          color: selectedRole.value == role
              ? AppColors.primary
              : Colors.grey[300]!,
          width: selectedRole.value == role ? 2 : 1,
        ),
      ),
      leading: Checkbox(
        value: selectedRole.value == role,
        onChanged: (value) {
          if (value == true) {
            selectedRole.value = role;
            Logger.info('Selected role: $role');
          }
        },
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {
        selectedRole.value = role;
        Logger.info('Selected role: $role');
      },
    );
  }

  @override
  void dispose() {
    userIdController.dispose();
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Add Staff Member'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workshop info
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Workshop',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    widget.workshopName,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Info box: 1 user many workshops
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                border: Border.all(color: Colors.blue, width: 1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'One user can be staff in multiple workshops',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // User ID
            Text(
              'User ID (Email)',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            CustomTextField(
              controller: userIdController,
              hintText: 'Enter user email',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 4.h),
            Text(
              'Use the user\'s email address as their ID',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            SizedBox(height: 16.h),

            // Staff Name
            Text(
              'Staff Name',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            CustomTextField(
              controller: nameController,
              hintText: 'Enter staff name',
            ),
            SizedBox(height: 16.h),

            // Email
            Text(
              'Email',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            CustomTextField(
              controller: emailController,
              hintText: 'Enter staff email',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.h),

            // Role Selection
            Text(
              'Role',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Obx(() => Column(
              children: [
                _buildRoleOption(
                  role: 'mechanic',
                  title: 'Mechanic',
                  subtitle: 'Can perform repairs and maintenance',
                ),
                SizedBox(height: 12.h),
                _buildRoleOption(
                  role: 'manager',
                  title: 'Manager',
                  subtitle: 'Can manage staff and bookings',
                ),
              ],
            )),
            SizedBox(height: 32.h),

            // Submit Button
            Obx(() => CustomButton(
              labelText: isSubmitting.value
                  ? AppStrings.pleaseWait
                  : 'Add Staff Member',
              backgroundColor: isSubmitting.value
                  ? Colors.grey
                  : AppColors.primary,
              onPressed: isSubmitting.value
                  ? null
                  : _submitAddStaff,
            )),
            SizedBox(height: 16.h),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Logger.info('Cancelled adding staff');
                  Get.back();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
