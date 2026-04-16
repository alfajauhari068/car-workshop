import 'package:car_workshop/features/auth/presentation/screens/register_screen.dart';
import 'package:car_workshop/features/auth/presentation/screens/complete_profile_screen.dart';
import 'package:car_workshop/features/auth/presentation/screens/mechanic_dashboard_screen.dart';
import 'package:car_workshop/features/bookings/presentation/screens/add_booking_screen.dart';
import 'package:car_workshop/features/bookings/presentation/screens/bookig_list_screen.dart';
import 'package:car_workshop/features/workshop/presentation/screens/workshop_dashboard_screen.dart';
import 'package:car_workshop/features/workshop/presentation/screens/staff_list_screen.dart';
import 'package:car_workshop/features/workshop/presentation/screens/add_staff_screen.dart';
import 'package:car_workshop/features/branch/presentation/screens/branch_list_screen.dart';
import 'package:car_workshop/features/branch/presentation/screens/add_branch_screen.dart';
import 'package:car_workshop/features/service/presentation/screens/service_list_screen.dart';
import 'package:car_workshop/features/service/presentation/screens/add_service_screen.dart';
import 'package:get/get.dart';

import '../../features/auth/presentation/screens/home_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/bookings/presentation/screens/booking_details_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String completeProfile = '/completeProfile';
  static const String mechanicDashboard = '/mechanicDashboard';
  static const String bookings = '/bookings';
  static const String addBooking = '/addBooking';
  static const String bookingDetails = '/bookingDetails';
  static const String profile = '/profile';
  static const String workshopSetup = '/workshopSetup';
  static const String workshopDashboard = '/workshopDashboard';
  static const String staffList = '/staffList';
  static const String addStaff = '/add_staff';
  static const String branchList = '/branchList';
  static const String addBranch = '/addBranch';
  static const String serviceList = '/serviceList';
  static const String addService = '/addService';

  static List<GetPage> routes = [
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(name: completeProfile, page: () => const CompleteProfileScreen()),
    GetPage(name: mechanicDashboard, page: () => const MechanicDashboardScreen()),
    GetPage(name: bookings, page: () => BookingsListScreen()),
    GetPage(name: addBooking, page: () => const AddBookingScreen()),
    GetPage(
        name: bookingDetails,
        page: () => BookingDetailsScreen(booking: Get.arguments)),
    GetPage(name: profile, page: () => ProfileScreen()),
    GetPage(name: workshopDashboard, page: () => const WorkshopDashboardScreen()),
    GetPage(
        name: staffList,
        page: () => StaffListScreen(
          workshopId: Get.arguments['workshopId'] ?? '',
          workshopName: Get.arguments['workshopName'] ?? '',
        )),
    GetPage(
        name: addStaff,
        page: () => AddStaffScreen(
          workshopId: Get.arguments['workshopId'] ?? '',
          workshopName: Get.arguments['workshopName'] ?? '',
        )),
    GetPage(name: branchList, page: () => BranchListScreen(workshopId: Get.arguments['workshopId'] ?? '')),
    GetPage(name: addBranch, page: () => const AddBranchScreen()),
    GetPage(name: serviceList, page: () => ServiceListScreen(workshopId: Get.arguments['workshopId'] ?? '')),
    GetPage(name: addService, page: () => const AddServiceScreen()),
  ];
}
