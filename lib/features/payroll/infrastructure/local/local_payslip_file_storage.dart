import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flowboard/features/payroll/domain/repository/payslip_file_storage.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payroll_system_file.dart';

/// Temporary storage of the payslip PDFs, the same as the Android app: the file is copied to the
/// private folder of the app and its `file://` URL is returned.
///
/// Replace it with the real storage once the team defines it.
class LocalPayslipFileStorage implements PayslipFileStorage {
  /// Creates the storage.
  const LocalPayslipFileStorage();

  static const String _directory = 'payslips';

  @override
  Future<String> store(PayrollSystemFile file) async {
    final Directory folder = await _folder();
    final File target = File(
      '${folder.path}${Platform.pathSeparator}${DateTime.now().millisecondsSinceEpoch}_${_sanitized(file.fileName)}',
    );
    try {
      final File source = File(file.sourcePath);
      if (!source.existsSync()) throw StateError('No se pudo leer ${file.fileName}.');
      await source.copy(target.path);
      final int written = await target.length();
      if (written <= 0) throw StateError('${file.fileName} está vacío.');
      if (written > PayrollSystemFile.maxSizeInBytes) throw StateError('${file.fileName} supera los 5 MB.');
    } catch (_) {
      if (target.existsSync()) target.deleteSync();
      rethrow;
    }
    return Uri.file(target.path).toString();
  }

  @override
  Future<void> delete(String storageUrl) async {
    try {
      final File stored = File(Uri.parse(storageUrl).toFilePath());
      final Directory folder = await _folder();
      if (stored.parent.path == folder.path && stored.existsSync()) stored.deleteSync();
    } catch (_) {
      // A file that does not exist is not an error.
    }
  }

  Future<Directory> _folder() async {
    final Directory base = await getApplicationDocumentsDirectory();
    final Directory folder = Directory('${base.path}${Platform.pathSeparator}$_directory');
    if (!folder.existsSync()) folder.createSync(recursive: true);
    return folder;
  }

  static String _sanitized(String name) => name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
}
