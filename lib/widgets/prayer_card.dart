import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';

class PrayerCard extends StatelessWidget {
  final String prayerName;
  final int remainingCount;
  final VoidCallback onPressed;
  final bool isEnabled;

  const PrayerCard({
    required this.prayerName,
    required this.remainingCount,
    required this.onPressed,
    this.isEnabled = true,
  });

  Color _getPrayerColor() {
    switch (prayerName) {
      case 'Fajr':
        return Color(AppTheme.fajrColor);
      case 'Dhuhr':
        return Color(AppTheme.dhuhrColor);
      case 'Asr':
        return Color(AppTheme.asrColor);
      case 'Maghrib':
        return Color(AppTheme.maghribColor);
      case 'Isha':
        return Color(AppTheme.ishaColor);
      default:
        return Color(AppTheme.accentColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getPrayerColor().withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getPrayerColor().withOpacity(0.1),
              _getPrayerColor().withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prayer Name and Count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prayerName,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 24,
                          color: _getPrayerColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Remaining',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  // Count Circle
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getPrayerColor().withOpacity(0.2),
                      border: Border.all(
                        color: _getPrayerColor(),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$remainingCount',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _getPrayerColor(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isEnabled && remainingCount > 0 ? onPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getPrayerColor(),
                    disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'I prayed this prayer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: remainingCount > 0 ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
