import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:car_workshop/core/common/widgets/widgets.dart';
import 'package:car_workshop/core/style/app_fonts.dart';
import 'package:car_workshop/features/service/presentation/controllers/service_controller.dart';

class AddServiceScreen extends StatelessWidget {
  const AddServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ServiceController controller = Get.find<ServiceController>();

    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController =
        TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController durationController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Service'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Service Details',
                style: AppFonts.size24W600,
              ),
              SizedBox(height: 20.h),
              Text(
                'Service Name',
                style: AppFonts.size16W500,
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: nameController,
                hintText: 'e.g., Oil Change',
                prefixIcon: Icons.build_circle,
              ),
              SizedBox(height: 20.h),
              Text(
                'Description',
                style: AppFonts.size16W500,
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: descriptionController,
                hintText: 'Describe the service',
                prefixIcon: Icons.description,
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price (\$)',
                          style: AppFonts.size16W500,
                        ),
                        SizedBox(height: 8.h),
                        CustomTextField(
                          controller: priceController,
                          hintText: '0.00',
                          prefixIcon: Icons.attach_money,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Duration (min)',
                          style: AppFonts.size16W500,
                        ),
                        SizedBox(height: 8.h),
                        CustomTextField(
                          controller: durationController,
                          hintText: '30',
                          prefixIcon: Icons.schedule,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.h),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => CustomButton(
                    labelText: controller.isLoading.value
                        ? 'Creating...'
                        : 'Create Service',
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            final name = nameController.text.trim();
                            final description =
                                descriptionController.text.trim();
                            final priceText = priceController.text.trim();
                            final durationText = durationController.text.trim();

                            if (name.isEmpty ||
                                description.isEmpty ||
                                priceText.isEmpty ||
                                durationText.isEmpty) {
                              Get.snackbar(
                                'Validation Error',
                                'Please fill in all fields',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            try {
                              final price = double.parse(priceText);
                              final duration = int.parse(durationText);

                              if (price < 0 || duration <= 0) {
                                Get.snackbar(
                                  'Validation Error',
                                  'Price must be >= 0 and duration > 0',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              controller.createService(
                                name: name,
                                description: description,
                                price: price,
                                durationMinutes: duration,
                              );

                              // Navigate back after success
                              Future.delayed(const Duration(seconds: 1), () {
                                Get.back();
                              });
                            } catch (e) {
                              Get.snackbar(
                                'Input Error',
                                'Invalid price or duration format',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
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
