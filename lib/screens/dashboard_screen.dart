import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prayer_model.dart';
import '../providers/prayer_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/prayer_card.dart';
import 'statistics_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerProvider>().checkAndResetDailyStats();
    });
  }

  void _showConfirmationDialog(String prayerName, PrayerProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Prayer'),
        content: Text('Did you pray $prayerName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.decreasePrayerCount(prayerName);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$prayerName logged successfully! ✓'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Color(AppTheme.successColor),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('No more $prayerName prayers remaining.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Qadaa Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen()),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return StatisticsScreen();
      case 2:
        return HistoryScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return Consumer<PrayerProvider>(
      builder: (context, provider, _) {
        if (provider.prayerCounts.isEmpty) {
          return Center(
            child: Text('Loading...'),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prayer Cards
              ...provider.prayerCounts.map((prayerCount) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: PrayerCard(
                    prayerName: prayerCount.prayerName,
                    remainingCount: prayerCount.count,
                    onPressed: () => _showConfirmationDialog(
                      prayerCount.prayerName,
                      provider,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}
