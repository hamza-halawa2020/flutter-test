import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'database_service.dart';

class BackupService {
  final DatabaseService databaseService;

  BackupService(this.databaseService);

  Future<bool> exportBackup() async {
    try {
      final data = await databaseService.getAllData();
      final jsonString = jsonEncode(data);
      
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'qadaa_backup_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonString);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Qadaa Prayer Tracker Backup',
      );
      
      return true;
    } catch (e) {
      print('Error exporting backup: $e');
      return false;
    }
  }

  Future<bool> importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final jsonString = await file.readAsString();
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        
        return await databaseService.restoreData(data);
      }
      return false;
    } catch (e) {
      print('Error importing backup: $e');
      return false;
    }
  }

  Future<String> getBackupPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
