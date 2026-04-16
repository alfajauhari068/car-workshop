import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:car_workshop/core/common/widgets/widgets.dart';
import 'package:car_workshop/core/routes/app_routes.dart';
import 'package:car_workshop/core/style/app_fonts.dart';
import '../controllers/workshop_controller.dart';

class WorkshopSetupScreen extends StatelessWidget {
  const WorkshopSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkshopController controller = Get.find<WorkshopController>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController locationController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Workshop'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Workshop Details',
                style: AppFonts.size24W600,
              ),
              SizedBox(height: 20.h),
              Text(
                'Workshop Name',
                style: AppFonts.size16W500,
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: nameController,
                hintText: 'Enter workshop name (e.g., John\'s Auto Service)',
                prefixIcon: Icons.business,
              ),
              SizedBox(height: 20.h),
              Text(
                'Location',
                style: AppFonts.size16W500,
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: locationController,
                hintText: 'Enter workshop location (e.g., Main Street, Downtown)',
                prefixIcon: Icons.location_on,
              ),
              SizedBox(height: 40.h),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => CustomButton(
                    labelText: controller.isLoading.value
                        ? 'Creating...'
                        : 'Create Workshop',
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            final name = nameController.text.trim();
                            final location = locationController.text.trim();

                            if (name.isEmpty || location.isEmpty) {
                              Get.snackbar(
                                'Validation Error',
                                'Please fill in all fields',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            controller.createWorkshop(
                              name: name,
                              location: location,
                            );

                            // Navigate to dashboard after success
                            Future.delayed(const Duration(seconds: 1), () {
                              Get.offAllNamed(AppRoutes.workshopDashboard);
                            });
                          },
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
