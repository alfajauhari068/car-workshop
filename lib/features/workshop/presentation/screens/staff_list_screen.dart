import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:car_workshop/core/style/app_colors.dart';
import 'package:car_workshop/core/utils/logger_util.dart';
import 'package:car_workshop/features/workshop/domain/entities/workshop_staff_entity.dart';
import '../controllers/workshop_staff_controller.dart';

class StaffListScreen extends StatefulWidget {
  final String workshopId;
  final String workshopName;

  const StaffListScreen({
    super.key,
    required this.workshopId,
    required this.workshopName,
  });

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  late final WorkshopStaffController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<WorkshopStaffController>();
    controller.loadStaffForWorkshop(widget.workshopId);
  }

  void _showRoleMenu(int index) {
    final staff = controller.staffList[index];
    Logger.info('Showing role menu for staff: ${staff.id}');

    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Role for ${staff.name}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                title: const Text('Mechanic'),
                selected: staff.role == WorkshopRole.mechanic,
                onTap: () async {
                  Navigator.pop(context);
                  final success = await controller.updateStaffRole(
                    staffId: staff.id,
                    newRole: 'mechanic',
                  );
                  if (success) {
                    Get.snackbar(
                      'Success',
                      'Role updated to Mechanic',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  } else {
                    Get.snackbar(
                      'Error',
                      controller.errorMessage.value,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                    );
                  }
                },
              ),
              ListTile(
                title: const Text('Manager'),
                selected: staff.role == WorkshopRole.manager,
                onTap: () async {
                  Navigator.pop(context);
                  final success = await controller.updateStaffRole(
                    staffId: staff.id,
                    newRole: 'manager',
                  );
                  if (success) {
                    Get.snackbar(
                      'Success',
                      'Role updated to Manager',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  } else {
                    Get.snackbar(
                      'Error',
                      controller.errorMessage.value,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                    );
                  }
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    final staff = controller.staffList[index];
    Logger.info('Showing delete confirmation for staff: ${staff.id}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Staff Member'),
        content: Text(
          'Are you sure you want to remove ${staff.name} from the workshop?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.removeStaffFromWorkshop(
                staff.id,
              );
              if (success) {
                Get.snackbar(
                  'Success',
                  'Staff member removed',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else {
                Get.snackbar(
                  'Error',
                  controller.errorMessage.value,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                );
              }
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('${widget.workshopName} - Staff'),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.staffList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.staffList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No staff members yet',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(12.w),
          itemCount: controller.staffList.length,
          itemBuilder: (context, index) {
            final staff = controller.staffList[index];
            final roleColor =
                staff.role == WorkshopRole.mechanic
                    ? Colors.blue
                    : Colors.orange;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.h),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(staff.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4.h),
                    Text(
                      staff.email,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        staff.role.value.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: roleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Change Role'),
                      onTap: () {
                        Future.delayed(
                          const Duration(milliseconds: 100),
                          () => _showRoleMenu(index),
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: const Text(
                        'Remove',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        Future.delayed(
                          const Duration(milliseconds: 100),
                          () => _showDeleteConfirmation(index),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Logger.info('Navigating to add staff screen');
          Get.toNamed(
            '/add_staff',
            arguments: {
              'workshopId': widget.workshopId,
              'workshopName': widget.workshopName,
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
