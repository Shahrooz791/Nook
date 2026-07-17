import 'package:get/get.dart';

import 'package:nook/local_data/vault_local_data.dart';
import 'package:nook/model/vault_models.dart';

/// Decrypted note content carrier — lives only in memory, never persisted plain.
class DecryptedNote {
  final VaultNote raw;
  final String title;
  final String body;
  const DecryptedNote({required this.raw, required this.title, required this.body});
}

class VaultNotesController extends GetxController {
  final RxList<DecryptedNote> notes = <DecryptedNote>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  Future<void> loadNotes() async {
    isLoading.value = true;
    final rawNotes = await VaultLocalData.instance.getAllNotes();
    final decrypted = await Future.wait(
      rawNotes.map((n) async {
        final title = await VaultLocalData.instance.decryptNoteTitle(n);
        final body = await VaultLocalData.instance.decryptNoteBody(n);
        return DecryptedNote(raw: n, title: title, body: body);
      }),
    );
    notes.assignAll(decrypted);
    isLoading.value = false;
  }

  Future<void> saveNote({
    int? id,
    required String title,
    required String body,
  }) async {
    if (id == null) {
      await VaultLocalData.instance.insertNote(
        titlePlain: title.isEmpty ? 'Untitled' : title,
        bodyPlain: body,
      );
    } else {
      await VaultLocalData.instance.updateNote(
        id: id,
        titlePlain: title.isEmpty ? 'Untitled' : title,
        bodyPlain: body,
      );
    }
    await loadNotes();
  }

  Future<void> deleteNote(int id) async {
    await VaultLocalData.instance.deleteNote(id);
    await loadNotes();
  }
}
