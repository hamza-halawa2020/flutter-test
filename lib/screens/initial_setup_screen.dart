import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prayer_model.dart';
import '../providers/prayer_provider.dart';
import 'dashboard_screen.dart';

class InitialSetupScreen extends StatefulWidget {
  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  final Map<String, TextEditingController> controllers = {
    'Fajr': TextEditingController(),
    'Dhuhr': TextEditingController(),
    'Asr': TextEditingController(),
    'Maghrib': TextEditingController(),
    'Isha': TextEditingController(),
  };

  bool _isLoading = false;

  @override
  void dispose() {
    controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _saveInitialCounts() async {
    final counts = <String, int>{};
    bool isValid = true;

    for (final entry in controllers.entries) {
      if (entry.value.text.isEmpty) {
        isValid = false;
        break;
      }
      final count = int.tryParse(entry.value.text);
      if (count == null || count < 0) {
        isValid = false;
        break;
      }
      counts[entry.key] = count;
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid numbers for all prayers')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<PrayerProvider>().setupInitialCounts(counts);
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Initial Setup'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Icon(Icons.mosque, size: 80, color: Colors.amber),
                  SizedBox(height: 16),
                  Text(
                    'Qadaa Prayer Tracker',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 28,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enter your missed prayers count',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Input Fields
            ...prayerNames.map((prayer) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prayer,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: controllers[prayer],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter number of missed $prayer prayers',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveInitialCounts,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Start Tracking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
