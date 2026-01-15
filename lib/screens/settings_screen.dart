import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../services/backup_service.dart';
import '../services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Section
            Text(
              'Display',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 18),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(themeProvider.isDarkMode
                                ? Icons.dark_mode
                                : Icons.light_mode),
                            SizedBox(width: 16),
                            Text(
                              'Dark Mode',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (value) => themeProvider.toggleTheme(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 24),

            // Language Section
            Text(
              'Language',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 18),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Consumer<LanguageProvider>(
                  builder: (context, langProvider, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.language),
                            SizedBox(width: 16),
                            Text(
                              langProvider.isArabic ? 'العربية' : 'English',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        Switch(
                          value: langProvider.isArabic,
                          onChanged: (value) => langProvider.toggleLanguage(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 24),

            // Backup & Restore Section
            Text(
              'Backup & Restore',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 18),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _exportBackup(),
                icon: Icon(Icons.cloud_download),
                label: Text('Export Backup'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _importBackup(),
                icon: Icon(Icons.cloud_upload),
                label: Text('Import Backup'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Data Section
            Text(
              'Data',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 18),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _showClearDataDialog(),
                icon: Icon(Icons.delete_forever),
                label: Text('Clear All Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportBackup() async {
    setState(() => _isLoading = true);
    try {
      final backupService = BackupService(DatabaseService());
      final success = await backupService.exportBackup();
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup exported successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export backup')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _importBackup() async {
    setState(() => _isLoading = true);
    try {
      final backupService = BackupService(DatabaseService());
      final success = await backupService.importBackup();
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup imported successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import backup')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Data'),
        content: Text(
          'Are you sure you want to delete all data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseService().clearAllData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('All data cleared')),
              );
            },
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
