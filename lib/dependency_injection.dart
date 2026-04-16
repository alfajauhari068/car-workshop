import 'package:car_workshop/features/bookings/domain/usecases/delete_booking_use_case.dart';
import 'package:car_workshop/features/workshop/data/repositories/workshop_repository.dart';
import 'package:car_workshop/features/workshop/data/repositories/workshop_staff_repository.dart';
import 'package:car_workshop/features/workshop/presentation/controllers/workshop_controller.dart';
import 'package:car_workshop/features/workshop/presentation/controllers/workshop_staff_controller.dart';
import 'package:car_workshop/features/branch/data/repositories/branch_repository.dart';
import 'package:car_workshop/features/branch/presentation/controllers/branch_controller.dart';
import 'package:car_workshop/features/service/data/repositories/service_repository.dart';
import 'package:car_workshop/features/service/presentation/controllers/service_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/services/auth_service.dart';
import 'core/services/workshop_staff_service.dart';
import 'features/auth/data/datasources/firebase_auth_data_source.dart';
import 'features/auth/data/datasources/user_remote_datasource.dart';
import 'features/auth/data/repositories/user_repository_impl.dart';
import 'features/auth/domain/repositories/user_repository.dart';
import 'features/auth/domain/usecases/create_user_use_case.dart';
import 'features/auth/domain/usecases/get_all_mechanics_use_case.dart';
import 'features/auth/domain/usecases/login_use_case.dart';
import 'features/auth/domain/usecases/logout_use_case.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/update_profile_use_case.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/controllers/profile_controller.dart';
import 'features/bookings/data/datasources/booking_remote_data_source.dart';
import 'features/bookings/data/datasources/firebase_booking_data_source.dart';
import 'features/bookings/data/repositories/booking_repository_impl.dart';
import 'features/bookings/domain/repositories/booking_repository.dart';
import 'features/bookings/domain/usecases/add_booking_use_case.dart';
import 'features/bookings/domain/usecases/fetch_daily_bookings_use_case.dart';
import 'features/bookings/domain/usecases/fetch_monthly_bookings_use_case.dart';
import 'features/bookings/domain/usecases/fetch_weekly_bookings_use_case.dart';
import 'features/bookings/presentation/controllers/booking_controller.dart';

class DependencyInjection {
  static void initDependencies() {
    // Core Firebase & Storage
    Get.put<FirebaseAuth>(FirebaseAuth.instance);
    Get.put<FirebaseFirestore>(FirebaseFirestore.instance);
    Get.put<GetStorage>(GetStorage());
    
    // Core Services (PHASE 0)
    Get.put<AuthService>(AuthService(Get.find<GetStorage>()));
    Get.put<WorkshopStaffService>(
      WorkshopStaffService(Get.find<FirebaseFirestore>()),
    );

    Get.put<UserRemoteDataSource>(FirebaseAuthDataSource(
      Get.find<FirebaseAuth>(),
      Get.find<FirebaseFirestore>(),
      Get.find<AuthService>(),
    ));
    Get.put<BookingRemoteDataSource>(FirebaseBookingDataSource(
      Get.find<FirebaseFirestore>(),
    ));

    Get.put<UserRepository>(
        UserRepositoryImpl(Get.find<UserRemoteDataSource>()));
    Get.put<BookingRepository>(
        BookingRepositoryImpl(
          Get.find<BookingRemoteDataSource>(),
          Get.find<FirebaseFirestore>(),
        ));

    Get.put<CreateUserUseCase>(CreateUserUseCase(Get.find<UserRepository>()));
    Get.put<RegisterUserUseCase>(RegisterUserUseCase(
      Get.find<UserRepository>(),
      Get.find<CreateUserUseCase>(),
    ));
    Get.put<LoginUserUseCase>(
      LoginUserUseCase(
        Get.find<UserRepository>(),
      ),
    );
    Get.put<LogoutUserUseCase>(
      LogoutUserUseCase(
        Get.find<UserRepository>(),
      ),
    );
    Get.put<GetAllMechanicsUseCase>(GetAllMechanicsUseCase(
        Get.find<UserRepository>(), Get.find<GetStorage>()));

    Get.put<UpdateProfileUseCase>(
      UpdateProfileUseCase(Get.find<UserRepository>()),
    );

    Get.put<FetchDailyBookingsUseCase>(
      FetchDailyBookingsUseCase(
        Get.find<BookingRepository>(),
      ),
    );
    Get.put<FetchWeeklyBookingsUseCase>(
      FetchWeeklyBookingsUseCase(
        Get.find<BookingRepository>(),
      ),
    );
    Get.put<FetchMonthlyBookingsUseCase>(
      FetchMonthlyBookingsUseCase(
        Get.find<BookingRepository>(),
      ),
    );
    Get.put<AddBookingUseCase>(
        AddBookingUseCase(Get.find<BookingRepository>()));

    Get.put<DeleteBookingUseCase>(
        DeleteBookingUseCase(Get.find<BookingRepository>()));
    Get.put<AuthController>(AuthController(
      Get.find<RegisterUserUseCase>(),
      Get.find<LoginUserUseCase>(),
      Get.find<LogoutUserUseCase>(),
    ));

    Get.put<ProfileController>(ProfileController(
      Get.find<UpdateProfileUseCase>(),
      Get.find<AuthService>(),
    ));

    Get.put<BookingsController>(BookingsController(
      Get.find<FetchDailyBookingsUseCase>(),
      Get.find<FetchWeeklyBookingsUseCase>(),
      Get.find<FetchMonthlyBookingsUseCase>(),
      Get.find<AddBookingUseCase>(),
      Get.find<GetAllMechanicsUseCase>(),
      Get.find<DeleteBookingUseCase>(),
    ));

    // Workshop (PHASE 1)
    Get.put<WorkshopRepository>(
        WorkshopRepository(Get.find<FirebaseFirestore>()));
    Get.put<WorkshopController>(WorkshopController(
      Get.find<WorkshopRepository>(),
      Get.find<AuthService>(),
    ));

    // Workshop Staff (PHASE 5)
    Get.put<WorkshopStaffRepository>(
        WorkshopStaffRepository(Get.find<FirebaseFirestore>()));
    Get.put<WorkshopStaffController>(
        WorkshopStaffController(Get.find<WorkshopStaffRepository>()));

    // Branch (PHASE 2)
    Get.put<BranchRepository>(
        BranchRepository(Get.find<FirebaseFirestore>()));
    Get.put<BranchController>(
        BranchController(Get.find<BranchRepository>()));

    // Service (PHASE 3)
    Get.put<ServiceRepository>(
        ServiceRepository(Get.find<FirebaseFirestore>()));
    Get.put<ServiceController>(
        ServiceController(Get.find<ServiceRepository>()));
  }
}
