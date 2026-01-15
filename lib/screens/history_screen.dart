import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prayer_model.dart';
import '../providers/prayer_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/prayer_log_item.dart';

class HistoryScreen extends StatefulWidget {
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? _selectedPrayer;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

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
  void initState() {
    super.initState();
    _loadLogs();
  }

  void _loadLogs() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerProvider>().loadPrayerLogs(
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        prayerName: _selectedPrayer,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filters
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prayer Filter
              Text(
                'Filter by Prayer',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: Text('All'),
                      selected: _selectedPrayer == null,
                      onSelected: (_) {
                        setState(() => _selectedPrayer = null);
                        _loadLogs();
                      },
                    ),
                    SizedBox(width: 8),
                    ...['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'].map((prayer) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(prayer),
                          selected: _selectedPrayer == prayer,
                          onSelected: (_) {
                            setState(() => _selectedPrayer = prayer);
                            _loadLogs();
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Date Range Filter
              Text(
                'Filter by Date',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedStartDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(Duration(days: 365)),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _selectedStartDate = picked);
                          _loadLogs();
                        }
                      },
                      icon: Icon(Icons.date_range),
                      label: Text(_selectedStartDate == null
                          ? 'Start'
                          : _selectedStartDate.toString().split(' ')[0]),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedEndDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(Duration(days: 365)),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _selectedEndDate = picked);
                          _loadLogs();
                        }
                      },
                      icon: Icon(Icons.date_range),
                      label: Text(_selectedEndDate == null
                          ? 'End'
                          : _selectedEndDate.toString().split(' ')[0]),
                    ),
                  ),
                ],
              ),
              if (_selectedStartDate != null || _selectedEndDate != null)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedStartDate = null;
                        _selectedEndDate = null;
                      });
                      _loadLogs();
                    },
                    child: Text('Clear Dates'),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 8),

        // Prayer Logs
        Expanded(
          child: Consumer<PrayerProvider>(
            builder: (context, provider, _) {
              if (provider.prayerLogs.isEmpty) {
                return Center(
                  child: Text('No prayer logs found'),
                );
              }

              return ListView.builder(
                itemCount: provider.prayerLogs.length,
                itemBuilder: (context, index) {
                  final log = provider.prayerLogs[index];
                  return PrayerLogItem(
                    log: log,
                    prayerColor: _getPrayerColor(log.prayerName),
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Delete Log'),
                          content: Text('Are you sure you want to delete this log?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                provider.deletePrayerLog(log.id!);
                              },
                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
