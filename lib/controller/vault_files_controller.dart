import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import 'package:nook/local_data/vault_local_data.dart';
import 'package:nook/model/vault_models.dart';

class VaultFilesController extends GetxController {
  final RxList<VaultFile> files = <VaultFile>[].obs;
  final RxBool isImporting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFiles();
  }

  Future<void> loadFiles() async {
    final result = await VaultLocalData.instance.getAllFiles();
    files.assignAll(result);
  }

  Future<void> importFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.single.bytes == null) return;
    final pf = result.files.single;
    isImporting.value = true;
    await VaultLocalData.instance.insertFile(
      pf.bytes!,
      originalName: pf.name,
    );

    // Attempt to hide
    if (pf.path != null) {
      try {
        final f = File(pf.path!);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }

    await loadFiles();
    isImporting.value = false;
  }

  Future<void> deleteFile(int id) async {
    await VaultLocalData.instance.deleteFile(id);
    await loadFiles();
  }

  Future<void> restoreFile(VaultFile file) async {
    final bytes = await VaultLocalData.instance.decryptFile(file);
    
    final restoreDir = Directory('/storage/emulated/0/Download/NookRestored');
    if (!await restoreDir.exists()) {
      await restoreDir.create(recursive: true);
    }
    
    final restorePath = '${restoreDir.path}/${file.originalName}';
    await File(restorePath).writeAsBytes(bytes);

    await VaultLocalData.instance.deleteFile(file.id!);
    await loadFiles();
  }
}
