import 'storage_service.dart';

class AdminProfileService {
  static String displayName = 'عرفان';

  static Future<void> initialize() async {
    displayName = await StorageService.loadAdminDisplayName();
  }

  static Future<void> setDisplayName(String name) async {
    final clean = name.trim();
    if (clean.isEmpty) return;
    displayName = clean;
    await StorageService.saveAdminDisplayName(clean);
  }
}
