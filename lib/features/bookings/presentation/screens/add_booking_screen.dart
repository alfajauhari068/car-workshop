import 'package:car_workshop/core/constants/app_strings.dart';
import 'package:car_workshop/core/style/app_colors.dart';
import 'package:car_workshop/core/utils/logger_util.dart';
import 'package:car_workshop/features/branch/data/repositories/branch_repository.dart';
import 'package:car_workshop/features/service/data/repositories/service_repository.dart';
import 'package:car_workshop/features/workshop/data/repositories/workshop_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/widgets/widgets.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../branch/data/models/branch_model.dart';
import '../../../service/data/models/service_model.dart';
import '../../../workshop/data/models/workshop_model.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/car_entity.dart';
import '../../domain/entities/customer_entity.dart';
import '../controllers/booking_controller.dart';

// ignore: must_be_immutable
class AddBookingScreen extends StatefulWidget {
  const AddBookingScreen({super.key});

  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  final BookingsController bookingsController = Get.find<BookingsController>();
  final WorkshopRepository workshopRepository =
      Get.find<WorkshopRepository>();
  final BranchRepository branchRepository = Get.find<BranchRepository>();
  final ServiceRepository serviceRepository = Get.find<ServiceRepository>();

  final TextEditingController carMakeController = TextEditingController();
  final TextEditingController carModelController = TextEditingController();
  final TextEditingController carYearController = TextEditingController();
  final TextEditingController carRegistrationPlateController =
      TextEditingController();

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerPhoneNumberController =
      TextEditingController();
  final TextEditingController customerEmailController = TextEditingController();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController startDateTimeController = TextEditingController();
  final TextEditingController endDateTimeController = TextEditingController();

  late Rx<WorkshopModel?> selectedWorkshop = Rx<WorkshopModel?>(null);
  late Rx<BranchModel?> selectedBranch = Rx<BranchModel?>(null);
  late Rx<ServiceModel?> selectedService = Rx<ServiceModel?>(null);
  Rx<UserEntity?> selectedMechanic = Rx<UserEntity?>(null);

  RxList<WorkshopModel> workshops = <WorkshopModel>[].obs;
  RxList<BranchModel> branches = <BranchModel>[].obs;
  RxList<ServiceModel> services = <ServiceModel>[].obs;

  RxBool isLoadingWorkshops = true.obs;
  RxBool isLoadingBranches = false.obs;
  RxBool isLoadingServices = false.obs;

  @override
  void initState() {
    super.initState();
    _loadWorkshops();
  }

  Future<void> _loadWorkshops() async {
    try {
      isLoadingWorkshops(true);
      Logger.info('Loading workshops...');
      final authService = Get.find<AuthService>();
      final currentUser = authService.currentUser;
      
      Logger.info('Current user: ${currentUser?.id}, Email: ${currentUser?.email}, Role: ${currentUser?.role}');
      
      final userId = currentUser?.id ?? '';
      if (userId.isEmpty) {
        Logger.error('No current user found or empty user ID');
        Get.snackbar('Error', 'No user logged in');
        isLoadingWorkshops(false);
        return;
      }
      
      Logger.info('Fetching workshops for userId: $userId');
      final result = await workshopRepository.getWorkshopsForUser(userId);

      result.fold(
        (failure) {
          Logger.error('Failed to load workshops: $failure');
          Get.snackbar('Error', 'Failed to load workshops: $failure');
        },
        (loadedWorkshops) {
          Logger.info('Workshops loaded successfully: ${loadedWorkshops.length} workshops');
          for (var workshop in loadedWorkshops) {
            Logger.info('  - Workshop: ${workshop.name} (ID: ${workshop.id})');
          }
          workshops.value = loadedWorkshops;
          
          if (loadedWorkshops.isEmpty) {
            Logger.warning('No workshops found for user $userId');
            Get.snackbar('Info', 'No workshops found. Create one first.');
          }
        },
      );
    } catch (e) {
      Logger.error('Exception loading workshops: $e');
      Get.snackbar('Error', 'An error occurred while loading workshops: $e');
    } finally {
      isLoadingWorkshops(false);
    }
  }

  Future<void> _loadBranches(String workshopId) async {
    try {
      isLoadingBranches(true);
      Logger.info('Loading branches for workshop: $workshopId');
      selectedBranch.value = null;
      selectedService.value = null;

      final result = await branchRepository.getBranchesForWorkshop(workshopId);

      result.fold(
        (failure) {
          Logger.error('Failed to load branches: $failure');
          Get.snackbar('Error', 'Failed to load branches');
        },
        (loadedBranches) {
          Logger.info('Branches loaded: ${loadedBranches.length}');
          branches.value = loadedBranches;
        },
      );
    } catch (e) {
      Logger.error('Error loading branches: $e');
      Get.snackbar('Error', 'An error occurred while loading branches');
    } finally {
      isLoadingBranches(false);
    }
  }

  Future<void> _loadServices(String workshopId) async {
    try {
      isLoadingServices(true);
      Logger.info('Loading services for workshop: $workshopId');
      selectedService.value = null;

      final result = await serviceRepository.getServicesForWorkshop(workshopId);

      result.fold(
        (failure) {
          Logger.error('Failed to load services: $failure');
          Get.snackbar('Error', 'Failed to load services');
        },
        (loadedServices) {
          Logger.info('Services loaded: ${loadedServices.length}');
          services.value = loadedServices;
        },
      );
    } catch (e) {
      Logger.error('Error loading services: $e');
      Get.snackbar('Error', 'An error occurred while loading services');
    } finally {
      isLoadingServices(false);
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = "${picked.toLocal()}".split(' ')[0];
    }
  }

  bool _validateInputs() {
    if (selectedWorkshop.value == null) {
      Get.snackbar('Validation Error', 'Please select a workshop');
      return false;
    }
    if (selectedBranch.value == null) {
      Get.snackbar('Validation Error', 'Please select a branch');
      return false;
    }
    if (selectedService.value == null) {
      Get.snackbar('Validation Error', 'Please select a service');
      return false;
    }
    if (carMakeController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Please enter car make');
      return false;
    }
    if (carModelController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Please enter car model');
      return false;
    }
    if (carYearController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Please enter car year');
      return false;
    }
    if (carRegistrationPlateController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Please enter registration plate');
      return false;
    }
    if (customerNameController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Please enter customer name');
      return false;
    }
    if (customerPhoneNumberController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Please enter phone number');
      return false;
    }
    if (customerEmailController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Please enter email');
      return false;
    }
    if (titleController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Please enter booking title');
      return false;
    }
    if (startDateTimeController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Please select start date');
      return false;
    }
    if (endDateTimeController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Please select end date');
      return false;
    }
    if (selectedMechanic.value == null) {
      Get.snackbar('Validation Error', 'Please select a mechanic');
      return false;
    }
    return true;
  }

  void _submitBooking() {
    if (!_validateInputs()) {
      return;
    }

    try {
      Logger.info(
        'Submitting booking - workshop: ${selectedWorkshop.value!.id}, branch: ${selectedBranch.value!.id}, service: ${selectedService.value!.id}',
      );

      final int carYear = int.tryParse(carYearController.text) ?? 0;

      final car = CarEntity(
        make: carMakeController.text,
        model: carModelController.text,
        year: carYear,
        registrationPlate: carRegistrationPlateController.text,
      );

      final customer = CustomerEntity(
        name: customerNameController.text,
        phoneNumber: customerPhoneNumberController.text,
        email: customerEmailController.text,
      );

      final booking = BookingEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        workshopId: selectedWorkshop.value!.id!,
        branchId: selectedBranch.value!.id!,
        serviceId: selectedService.value!.id!,
        car: car,
        customer: customer,
        title: titleController.text,
        startDateTime: DateTime.parse(startDateTimeController.text),
        endDateTime: DateTime.parse(endDateTimeController.text),
        mechanic: selectedMechanic.value!,
      );

      Logger.repository(
        'SUBMIT',
        'bookings',
        {
          'workshop_id': booking.workshopId,
          'branch_id': booking.branchId,
          'service_id': booking.serviceId,
          'customer_name': booking.customer.name,
        },
      );

      bookingsController.addBooking(booking);
    } catch (e) {
      Logger.error('Error submitting booking: $e');
      Get.snackbar('Error', 'Failed to submit booking');
    }
  }

  @override
  void dispose() {
    carMakeController.dispose();
    carModelController.dispose();
    carYearController.dispose();
    carRegistrationPlateController.dispose();
    customerNameController.dispose();
    customerPhoneNumberController.dispose();
    customerEmailController.dispose();
    titleController.dispose();
    startDateTimeController.dispose();
    endDateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.addBooking),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STEP 1: Select Workshop
            Text(
              'Step 1: Select Workshop',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            Obx(() {
              if (isLoadingWorkshops.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return DropdownButton<WorkshopModel>(
                isExpanded: true,
                hint: const Text('Select Workshop'),
                value: selectedWorkshop.value,
                items: workshops
                    .map((workshop) => DropdownMenuItem<WorkshopModel>(
                          value: workshop,
                          child: Text(workshop.name),
                        ))
                    .toList(),
                onChanged: (workshop) {
                  if (workshop != null) {
                    Logger.info('Selected workshop: ${workshop.id}');
                    selectedWorkshop.value = workshop;
                    _loadBranches(workshop.id!);
                    _loadServices(workshop.id!);
                  }
                },
              );
            }),
            SizedBox(height: 20.h),

            // STEP 2: Select Branch
            Text(
              'Step 2: Select Branch',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            Obx(() {
              if (selectedWorkshop.value == null) {
                return const Text('Please select a workshop first');
              }
              if (isLoadingBranches.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (branches.isEmpty) {
                return const Text('No branches available for this workshop');
              }
              return DropdownButton<BranchModel>(
                isExpanded: true,
                hint: const Text('Select Branch'),
                value: selectedBranch.value,
                items: branches
                    .map((branch) => DropdownMenuItem<BranchModel>(
                          value: branch,
                          child: Text(branch.name),
                        ))
                    .toList(),
                onChanged: (branch) {
                  if (branch != null) {
                    Logger.info('Selected branch: ${branch.id}');
                    selectedBranch.value = branch;
                  }
                },
              );
            }),
            SizedBox(height: 20.h),

            // STEP 3: Select Service
            Text(
              'Step 3: Select Service',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            Obx(() {
              if (selectedWorkshop.value == null) {
                return const Text('Please select a workshop first');
              }
              if (isLoadingServices.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (services.isEmpty) {
                return const Text('No services available for this workshop');
              }
              return DropdownButton<ServiceModel>(
                isExpanded: true,
                hint: const Text('Select Service'),
                value: selectedService.value,
                items: services
                    .map((service) => DropdownMenuItem<ServiceModel>(
                          value: service,
                          child: Text('${service.name} - \$${service.price}'),
                        ))
                    .toList(),
                onChanged: (service) {
                  if (service != null) {
                    Logger.info('Selected service: ${service.id}');
                    selectedService.value = service;
                  }
                },
              );
            }),
            SizedBox(height: 30.h),

            // Car Details
            Text(
              AppStrings.carDetails,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            CustomTextField(
              controller: carMakeController,
              hintText: AppStrings.carMake,
            ),
            SizedBox(height: 10.h),
            CustomTextField(
              controller: carModelController,
              hintText: AppStrings.carModel,
            ),
            SizedBox(height: 10.h),
            CustomTextField(
              controller: carYearController,
              hintText: AppStrings.carYear,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10.h),
            CustomTextField(
              controller: carRegistrationPlateController,
              hintText: AppStrings.registrationPlate,
            ),
            SizedBox(height: 20.h),

            // Customer Details
            Text(
              AppStrings.customerDetails,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            CustomTextField(
              controller: customerNameController,
              hintText: AppStrings.customerName,
            ),
            SizedBox(height: 10.h),
            CustomTextField(
              controller: customerPhoneNumberController,
              hintText: AppStrings.phoneNumber,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10.h),
            CustomTextField(
              controller: customerEmailController,
              hintText: AppStrings.email,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20.h),

            // Booking Details
            Text(
              AppStrings.bookingDetails,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            CustomTextField(
              controller: titleController,
              hintText: AppStrings.bookingTitle,
            ),
            SizedBox(height: 20.h),
            Obx(() => CustomDropdownButton<UserEntity>(
                  hint: AppStrings.selectMechanic,
                  value: selectedMechanic.value,
                  items: bookingsController.mechanics
                      .map(
                        (mechanic) => DropdownMenuItem<UserEntity>(
                          value: mechanic,
                          child: Text(mechanic.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    selectedMechanic.value = value;
                  },
                )),
            SizedBox(height: 20.h),
            CustomTextField(
              controller: startDateTimeController,
              hintText: AppStrings.startDate,
              prefixIcon: Icons.calendar_today,
              obscureText: false,
              keyboardType: TextInputType.datetime,
              readOnly: true,
              onTap: () => _selectDate(context, startDateTimeController),
            ),
            SizedBox(height: 10.h),
            CustomTextField(
              controller: endDateTimeController,
              hintText: AppStrings.endDate,
              prefixIcon: Icons.calendar_today,
              obscureText: false,
              keyboardType: TextInputType.datetime,
              readOnly: true,
              onTap: () => _selectDate(context, endDateTimeController),
            ),
            SizedBox(height: 30.h),

            // Submit Button
            Obx(() => CustomButton(
                  labelText: bookingsController.isAddingBooking.value
                      ? AppStrings.pleaseWait
                      : 'Create Booking',
                  backgroundColor: bookingsController.isAddingBooking.value
                      ? Colors.grey
                      : Colors.green,
                  onPressed: bookingsController.isAddingBooking.value
                      ? null
                      : _submitBooking,
                )),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
