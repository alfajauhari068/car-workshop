import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:car_workshop/core/common/widgets/widgets.dart';
import 'package:car_workshop/core/routes/app_routes.dart';
import 'package:car_workshop/core/style/app_fonts.dart';
import '../controllers/branch_controller.dart';

class BranchListScreen extends StatelessWidget {
  final String workshopId;

  const BranchListScreen({
    super.key,
    required this.workshopId,
  });

  @override
  Widget build(BuildContext context) {
    final BranchController controller = Get.find<BranchController>();

    // Initialize with workshop ID when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.currentWorkshopId.value != workshopId) {
        controller.initializeWithWorkshop(workshopId);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Branches'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchBranches(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.branches.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.branches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_city_outlined,
                  size: 80.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 20.h),
                Text(
                  'No Branches Yet',
                  style: AppFonts.size24W600,
                ),
                SizedBox(height: 10.h),
                Text(
                  'Add a branch to manage your workshop locations',
                  style: AppFonts.size14W400,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.h),
                SizedBox(
                  width: 150.w,
                  child: CustomButton(
                    labelText: 'Add Branch',
                    onPressed: () => Get.toNamed(
                      AppRoutes.addBranch,
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
          itemCount: controller.branches.length,
          itemBuilder: (context, index) {
            final branch = controller.branches[index];
            final isSelected =
                controller.selectedBranch.value?.id == branch.id;

            return GestureDetector(
              onTap: () => controller.selectBranch(branch),
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
                            Icons.apartment,
                            size: 24.sp,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  branch.name,
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
                                        branch.address,
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
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 16.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            branch.phone,
                            style: AppFonts.size14W400,
                          ),
                          const Spacer(),
                          Text(
                            'Created: ${_formatDate(branch.createdAt)}',
                            style: AppFonts.size14W400,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 32.h,
                            child: TextButton(
                              onPressed: () {
                                // Navigate to edit branch
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
                                  branch.id!,
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
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(
          AppRoutes.addBranch,
          arguments: {'workshopId': workshopId},
        ),
        tooltip: 'Add Branch',
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }

  void _showDeleteConfirmation(
    BuildContext context,
    BranchController controller,
    String branchId,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Branch'),
        content: const Text(
          'Are you sure you want to delete this branch? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteBranch(branchId);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
