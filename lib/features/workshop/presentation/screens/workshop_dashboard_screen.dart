import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:car_workshop/core/common/widgets/widgets.dart';
import 'package:car_workshop/core/routes/app_routes.dart';
import 'package:car_workshop/core/style/app_fonts.dart';
import '../controllers/workshop_controller.dart';

class WorkshopDashboardScreen extends StatelessWidget {
  const WorkshopDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkshopController controller = Get.find<WorkshopController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workshops'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchWorkshops(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.workshops.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.workshops.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.business_center_outlined,
                  size: 80.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 20.h),
                Text(
                  'No Workshops Yet',
                  style: AppFonts.size24W600,
                ),
                SizedBox(height: 10.h),
                Text(
                  'Create your first workshop to get started',
                  style: AppFonts.size14W400,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.h),
                SizedBox(
                  width: 200.w,
                  child: CustomButton(
                    labelText: 'Create Workshop',
                    onPressed: () =>
                        Get.toNamed(AppRoutes.workshopSetup),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.workshops.length,
          itemBuilder: (context, index) {
            final workshop = controller.workshops[index];
            final isSelected =
                controller.selectedWorkshop.value?.id == workshop.id;

            return GestureDetector(
              onTap: () => controller.selectWorkshop(workshop),
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
                            Icons.business,
                            size: 24.sp,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  workshop.name,
                                  style: AppFonts.size24W600,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 14.sp,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 4.w),
                                    Expanded(
                                      child: Text(
                                        workshop.location,
                                        style: AppFonts.size14W400,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
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
                          Text(
                            'Created: ${_formatDate(workshop.createdAt)}',
                            style: AppFonts.size14W400,
                            textAlign: TextAlign.center,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                height: 32.h,
                                child: TextButton(
                                  onPressed: () {
                                    // Navigate to workshop details
                                  },
                                  child: Text(
                                    'Details',
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
                                    // Show delete confirmation
                                    _showDeleteConfirmation(
                                      context,
                                      controller,
                                      workshop.id!,
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
        onPressed: () => Get.toNamed(AppRoutes.workshopSetup),
        tooltip: 'Create Workshop',
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WorkshopController controller,
    String workshopId,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Workshop'),
        content: const Text(
          'Are you sure you want to delete this workshop? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteWorkshop(workshopId);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
