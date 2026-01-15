import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prayer_model.dart';
import '../providers/prayer_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/statistic_card.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  Color _getPrayerColor(String prayerName) {
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Picker
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(Duration(days: 365)),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selected Date', style: Theme.of(context).textTheme.bodyMedium),
                        SizedBox(height: 4),
                        Text(
                          _selectedDate.toString().split(' ')[0],
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 24),

          // Statistics
          Text(
            'Prayers Completed',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 20),
          ),
          SizedBox(height: 16),

          FutureBuilder<DailyStatistics>(
            future: context.read<PrayerProvider>().getStatistics(_selectedDate),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final stats = snapshot.data!;

              return Column(
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      StatisticCard(
                        prayerName: 'Fajr',
                        count: stats.fajrCount,
                        color: _getPrayerColor('Fajr'),
                      ),
                      StatisticCard(
                        prayerName: 'Dhuhr',
                        count: stats.dhuhrCount,
                        color: _getPrayerColor('Dhuhr'),
                      ),
                      StatisticCard(
                        prayerName: 'Asr',
                        count: stats.asrCount,
                        color: _getPrayerColor('Asr'),
                      ),
                      StatisticCard(
                        prayerName: 'Maghrib',
                        count: stats.maghribCount,
                        color: _getPrayerColor('Maghrib'),
                      ),
                      StatisticCard(
                        prayerName: 'Isha',
                        count: stats.ishaCount,
                        color: _getPrayerColor('Isha'),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            Color(AppTheme.accentColor).withOpacity(0.2),
                            Color(AppTheme.accentColor).withOpacity(0.05),
                          ],
                        ),
                      ),
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            'Total Prayers Completed',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          SizedBox(height: 12),
                          Text(
                            '${stats.totalCount}',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(AppTheme.accentColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
