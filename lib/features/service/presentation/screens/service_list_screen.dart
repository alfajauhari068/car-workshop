import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:car_workshop/core/common/widgets/widgets.dart';
import 'package:car_workshop/core/routes/app_routes.dart';
import 'package:car_workshop/core/style/app_fonts.dart';
import 'package:car_workshop/features/service/presentation/controllers/service_controller.dart';

class ServiceListScreen extends StatelessWidget {
  final String workshopId;

  const ServiceListScreen({
    super.key,
    required this.workshopId,
  });

  @override
  Widget build(BuildContext context) {
    final ServiceController controller = Get.find<ServiceController>();

    // Initialize with workshop ID when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.currentWorkshopId.value != workshopId) {
        controller.initializeWithWorkshop(workshopId);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchServices(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.services.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.services.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.miscellaneous_services_outlined,
                  size: 80.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 20.h),
                Text(
                  'No Services Yet',
                  style: AppFonts.size24W600,
                ),
                SizedBox(height: 10.h),
                Text(
                  'Add services to offer customers',
                  style: AppFonts.size14W400,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.h),
                SizedBox(
                  width: 150.w,
                  child: CustomButton(
                    labelText: 'Add Service',
                    onPressed: () => Get.toNamed(
                      AppRoutes.addService,
                      arguments: {'workshopId': workshopId},
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.services.length,
          itemBuilder: (context, index) {
            final service = controller.services[index];
            final isSelected =
                controller.selectedService.value?.id == service.id;

            return GestureDetector(
              onTap: () => controller.selectService(service),
              child: Card(
                margin: EdgeInsets.only(bottom: 16.h),
                elevation: isSelected ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(
                    color: isSelected ? Colors.blue : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.build_circle_outlined,
                            size: 24.sp,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.name,
                                  style: AppFonts.size24W600,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  service.description,
                                  style: AppFonts.size14W400,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.blue,
                                size: 20.sp,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Divider(height: 1, color: Colors.grey.shade200),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price: ${service.price.toStringAsFixed(2)}',
                                style: AppFonts.size16W500,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Duration: ${service.durationMinutes} min',
                                style: AppFonts.size14W400,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(
                                height: 32.h,
                                child: TextButton(
                                  onPressed: () {
                                    // Navigate to edit service
                                  },
                                  child: Text(
                                    'Edit',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              SizedBox(
                                height: 32.h,
                                child: TextButton(
                                  onPressed: () {
                                    _showDeleteConfirmation(
                                      context,
                                      controller,
                                      service.id!,
                                    );
                                  },
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(
          AppRoutes.addService,
          arguments: {'workshopId': workshopId},
        ),
        tooltip: 'Add Service',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ServiceController controller,
    String serviceId,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Service'),
        content: const Text(
          'Are you sure you want to delete this service? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteService(serviceId);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
