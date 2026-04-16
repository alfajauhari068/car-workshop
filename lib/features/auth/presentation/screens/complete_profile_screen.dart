import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/widgets/widgets.dart';
import '../../../../core/style/app_fonts.dart';
import '../controllers/profile_controller.dart';

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();
    final TextEditingController skillsController = TextEditingController();
    final TextEditingController experienceController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Text(
                'Lengkapi profil Anda terlebih dahulu',
                style: AppFonts.size24W600,
              ),
              SizedBox(height: 10.h),
              Text(
                'Informasi ini diperlukan untuk melamar ke workshop',
                style: AppFonts.size14W400,
              ),
              SizedBox(height: 30.h),
              // Skills field
              Text(
                'Keahlian (Skills)',
                style: AppFonts.size16W600,
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: skillsController,
                hintText: 'Contoh: Engine Repair, Electrical, AC',
                prefixIcon: Icons.build,
              ),
              SizedBox(height: 20.h),
              // Experience field
              Text(
                'Pengalaman (Tahun)',
                style: AppFonts.size16W600,
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: experienceController,
                hintText: 'Berapa tahun pengalaman Anda?',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.date_range,
              ),
              SizedBox(height: 40.h),
              // Submit button
              Obx(
                () => CustomButton(
                  labelText: profileController.isLoading.value
                      ? 'Please wait...'
                      : 'Simpan Profil',
                  onPressed: profileController.isLoading.value
                      ? null
                      : () {
                          final String skillsText = skillsController.text.trim();
                          final String experienceText =
                              experienceController.text.trim();

                          // Parse skills (split by comma)
                          final List<String> skills = skillsText
                              .split(',')
                              .map((skill) => skill.trim())
                              .where((skill) => skill.isNotEmpty)
                              .toList();

                          profileController.completeProfile(
                            skills,
                            experienceText,
                          );
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
