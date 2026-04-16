import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:car_workshop/core/common/widgets/widgets.dart';
import 'package:car_workshop/core/style/app_fonts.dart';
import 'package:car_workshop/features/branch/presentation/controllers/branch_controller.dart';

class AddBranchScreen extends StatelessWidget {
  const AddBranchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BranchController controller = Get.find<BranchController>();

    final TextEditingController nameController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Branch'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Branch Details',
                style: AppFonts.size24W600,
              ),
              SizedBox(height: 20.h),
              Text(
                'Branch Name',
                style: AppFonts.size16W500,
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: nameController,
                hintText: 'Enter branch name (e.g., Main Branch)',
                prefixIcon: Icons.apartment,
              ),
              SizedBox(height: 20.h),
              Text(
                'Address',
                style: AppFonts.size16W500,
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: addressController,
                hintText: 'Enter branch address',
                prefixIcon: Icons.location_on,
              ),
              SizedBox(height: 20.h),
              Text(
                'Phone Number',
                style: AppFonts.size16W500,
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: phoneController,
                hintText: 'Enter phone number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 40.h),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => CustomButton(
                    labelText: controller.isLoading.value
                        ? 'Creating...'
                        : 'Create Branch',
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            final name = nameController.text.trim();
                            final address = addressController.text.trim();
                            final phone = phoneController.text.trim();

                            if (name.isEmpty || address.isEmpty || phone.isEmpty) {
                              Get.snackbar(
                                'Validation Error',
                                'Please fill in all fields',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            controller.createBranch(
                              name: name,
                              address: address,
                              phone: phone,
                            );

                            // Navigate back after success
                            Future.delayed(const Duration(seconds: 1), () {
                              Get.back();
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
