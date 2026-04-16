import 'package:get/get.dart';
import '../../core/enums/user_role.dart';
import '../../core/services/auth_service.dart';
import 'app_routes.dart';

class RoleBasedRouter {
  /// Route user berdasarkan role DAN state mereka setelah login sukses
  /// 
  /// State-aware routing:
  /// - Profile tidak lengkap? → CompleteProfilePage
  /// - Mechanic belum join workshop? → ExploreWorkshopPage
  /// 
  /// Role-based routing (dengan profile lengkap):
  /// - Admin → WorkshopDashboard (manajemen penuh)
  /// - WorkshopOwner → WorkshopDashboard (manajemen cabang)
  /// - Manager → WorkshopDashboard (monitoring)
  /// - Mechanic → MechanicDashboard (operasional)
  /// - Customer → BookingsList (pemesanan)
  static Future<void> redirectUser() async {
    try {
      final authService = Get.find<AuthService>();
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        // Fallback ke login jika tidak ada user
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      final role = currentUser.role;
      final profileComplete = currentUser.profileComplete;

      // 🔥 STATE CHECK 1: Profile belum lengkap?
      if (!profileComplete && role == UserRole.mechanic) {
        await Get.offAllNamed(AppRoutes.completeProfile);
        return;
      }

      // 🔥 ROLE-BASED ROUTING (setelah profile lengkap)
      switch (role) {
        case UserRole.admin:
          await Get.offAllNamed(AppRoutes.workshopDashboard);
          break;

        case UserRole.workshopOwner:
          await Get.offAllNamed(AppRoutes.workshopDashboard);
          break;

        case UserRole.manager:
          await Get.offAllNamed(AppRoutes.workshopDashboard);
          break;

        case UserRole.mechanic:
          // Jika profile lengkap, bisa ke dashboard atau workshop selection
          await Get.offAllNamed(AppRoutes.mechanicDashboard);
          break;

        case UserRole.customer:
          await Get.offAllNamed(AppRoutes.bookings);
          break;
      }
    } catch (e) {
      // Fallback ke bookings jika ada error
      Get.offAllNamed(AppRoutes.bookings);
    }
  }

  /// Check apakah user role sama dengan role yang diizinkan
  static bool hasRole(UserRole requiredRole) {
    try {
      final authService = Get.find<AuthService>();
      return authService.currentUser?.role == requiredRole;
    } catch (e) {
      return false;
    }
  }

  /// Check apakah user punya salah satu dari multiple roles
  static bool hasAnyRole(List<UserRole> roles) {
    try {
      final authService = Get.find<AuthService>();
      final userRole = authService.currentUser?.role;
      return userRole != null && roles.contains(userRole);
    } catch (e) {
      return false;
    }
  }

  /// Get display name untuk role (untuk UI)
  static String getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.workshopOwner:
        return 'Workshop Owner';
      case UserRole.manager:
        return 'Manager';
      case UserRole.mechanic:
        return 'Technician';
      case UserRole.customer:
        return 'Customer';
    }
  }
}
