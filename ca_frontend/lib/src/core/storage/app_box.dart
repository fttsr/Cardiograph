import 'package:hive/hive.dart';

class AppBox {
  final Box _box;
  AppBox(this._box);

  //
  // Сессия
  //
  String? get userId => _box.get('user_id') as String?;
  String? get role => _box.get('role') as String?;

  Future<void> saveSession({
    required String userId,
    required String role,
  }) async {
    await _box.put('user_id', userId);
    await _box.put('role', role);
  }

  Future<void> clearSession() async {
    await _box.delete('user_id');
    await _box.delete('role');
  }

  //
  // История ЭКГ и пдф
  //
  DateTime? get lastEcgTime => _readIsoDate('lastEcgTime');
  DateTime? get lastPdfOpenTime =>
      _readIsoDate('lastPdfOpenTime');

  Future<void> setLastEcgTime() =>
      _box.put('lastEcgTime', DateTime.now().toIso8601String());
  Future<void> setLastPdfOpenTime() => _box.put(
    'lastPdfOpenTime',
    DateTime.now().toIso8601String(),
  );

  //
  // Пдф файлы
  //
  List<String> get pdfFiles => List<String>.from(
    _box.get('pdfFiles', defaultValue: <String>[] as List),
  );

  Future<void> setPdfFiles(List<String> files) =>
      _box.put('pdfFiles', files);

  Future<void> addPdfFile(String path) async {
    final files = pdfFiles;
    if (!files.contains(path)) {
      files.add(path);
      await setPdfFiles(files);
    }
  }

  Future<void> removePdfFiles(String path) async {
    final files = pdfFiles;
    files.remove(path);
    await setPdfFiles(files);
  }

  DateTime? _readIsoDate(String key) {
    final v = _box.get(key);
    if (v == null) return null;
    if (v is DateTime) return v.toLocal();
    if (v is String) return DateTime.tryParse(v)?.toLocal();
    return null;
  }
}
