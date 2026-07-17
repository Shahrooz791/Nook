import 'package:get/get.dart';
import 'package:nook/view/screens/add_letter/add_letter.dart';
import 'package:nook/view/screens/home/home.dart';
import 'package:nook/view/screens/splash/splash.dart';
import 'package:nook/view/screens/vault/vault_locked/vault_locked.dart';
import 'package:nook/view/screens/vault/vault_settings/vault_settings.dart';
import 'package:nook/view/screens/vault/your_vault/your_vault.dart';
import 'package:nook/view/screens/view_letter/view_letter.dart';

/// Central place for every route name used by GetX navigation.
/// Never hardcode a route string anywhere else — always use these.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String home = '/home';
  static const String addLetter = '/add-letter';
  static const String viewLetter = '/view-letter';
  static const String vaultLocked = '/vault-locked';
  static const String yourVault = '/your-vault';
  static const String vaultSettings = '/vault-settings';
}

/// Central place for every GetPage. Add a new line here whenever a new
/// screen is created — nothing else needs to change for navigation to work.
class AppPages {
  AppPages._();

  static final List<GetPage> routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.addLetter, page: () => const AddLetterScreen()),
    GetPage(name: AppRoutes.viewLetter, page: () => const ViewLetterScreen()),
    GetPage(name: AppRoutes.vaultLocked, page: () => const VaultLockedScreen()),
    GetPage(name: AppRoutes.yourVault, page: () => const YourVaultScreen()),
    GetPage(name: AppRoutes.vaultSettings, page: () => const VaultSettingsScreen()),
  ];
}
