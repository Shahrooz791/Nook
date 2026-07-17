import 'package:get/get.dart';
import 'package:nook/view/screens/add_letter/add_letter.dart';
import 'package:nook/view/screens/home/home.dart';
import 'package:nook/view/screens/splash/splash.dart';
import 'package:nook/view/screens/vault/vault_locked/vault_locked.dart';
import 'package:nook/view/screens/vault/your_vault/your_vault.dart';
import 'package:nook/view/screens/vault/vault_photos/vault_photos.dart';
import 'package:nook/view/screens/vault/vault_videos/vault_videos.dart';
import 'package:nook/view/screens/vault/vault_files/vault_files.dart';
import 'package:nook/view/screens/vault/vault_notes/vault_notes.dart';
import 'package:nook/view/screens/vault/vault_passwords/vault_passwords.dart';
import 'package:nook/view/screens/view_letter/view_letter.dart';
import 'package:nook/view/screens/edit_letter/edit_letter.dart';

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
  static const String vaultPhotos = '/vault-photos';
  static const String vaultVideos = '/vault-videos';
  static const String vaultFiles = '/vault-files';
  static const String vaultNotes = '/vault-notes';
  static const String vaultPasswords = '/vault-passwords';
  static const String editLetter = '/edit-letter';
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
    GetPage(name: AppRoutes.vaultPhotos, page: () => const VaultPhotosScreen()),
    GetPage(name: AppRoutes.vaultVideos, page: () => const VaultVideosScreen()),
    GetPage(name: AppRoutes.vaultFiles, page: () => const VaultFilesScreen()),
    GetPage(name: AppRoutes.vaultNotes, page: () => const VaultNotesScreen()),
    GetPage(name: AppRoutes.vaultPasswords, page: () => const VaultPasswordsScreen()),
    GetPage(name: AppRoutes.editLetter, page: () => const EditLetterScreen()),
  ];
}
