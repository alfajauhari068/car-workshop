import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/widgets/widgets.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/style/app_fonts.dart';
import '../../../../core/services/auth_service.dart';

class MechanicDashboardScreen extends StatelessWidget {
  const MechanicDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${currentUser?.name ?? 'Mechanic'}'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Get.toNamed(AppRoutes.profile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              // User info card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser?.name ?? 'Unknown',
                        style: AppFonts.size16W600,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        currentUser?.email ?? '',
                        style: AppFonts.size14W400,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              // Available jobs section
              Text(
                'Available Jobs',
                style: AppFonts.size16W600,
              ),
              SizedBox(height: 16.h),
              // Placeholder for jobs list
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 48.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'No jobs available yet',
                        style: AppFonts.size14W400,
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: 200.w,
                        child: CustomButton(
                          labelText: 'Browse Workshops',
                          onPressed: () {
                            Get.snackbar(
                              'Info',
                              'Workshop browsing akan diimplementasikan di fase berikutnya',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
