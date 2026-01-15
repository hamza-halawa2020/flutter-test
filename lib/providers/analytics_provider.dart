import 'package:flutter/material.dart';
import '../models/prayer_model.dart';
import '../services/analytics_service.dart';

class AnalyticsProvider with ChangeNotifier {
  final AnalyticsService _analyticsService;

  Map<String, dynamic> _totalStats = {};
  Map<String, dynamic> _weeklySummary = {};
  Map<String, dynamic> _monthlySummary = {};
  Map<String, dynamic> _smartInsights = {};
  double _completionRate = 0.0;
  Map<String, dynamic> _comparisonData = {};

  AnalyticsProvider(this._analyticsService);

  // Getters
  Map<String, dynamic> get totalStats => _totalStats;
  Map<String, dynamic> get weeklySummary => _weeklySummary;
  Map<String, dynamic> get monthlySummary => _monthlySummary;
  Map<String, dynamic> get smartInsights => _smartInsights;
  double get completionRate => _completionRate;
  Map<String, dynamic> get comparisonData => _comparisonData;

  // Feature 2: Initialize analytics
  Future<void> initialize() async {
    await refreshAnalytics();
  }

  // Feature 2: Refresh all analytics
  Future<void> refreshAnalytics() async {
    _totalStats = await _analyticsService.getTotalStats();
    _weeklySummary = await _analyticsService.getWeeklySummary();
    _monthlySummary = await _analyticsService.getMonthlySummary();
    _smartInsights = await _analyticsService.getSmartInsights();
    _completionRate = await _analyticsService.getCompletionRate();
    _comparisonData = await _analyticsService.getComparisonData();
    notifyListeners();
  }

  // Feature 2: Get weekly summary
  Future<Map<String, dynamic>> getWeeklyData() async {
    return await _analyticsService.getWeeklySummary();
  }

  // Feature 2: Get monthly summary
  Future<Map<String, dynamic>> getMonthlyData({int? month, int? year}) async {
    return await _analyticsService.getMonthlySummary(month: month, year: year);
  }

  // Feature 7: Get smart insights
  Future<Map<String, dynamic>> getInsights() async {
    return await _analyticsService.getSmartInsights();
  }

  // Feature 2: Get prayer progress
  Future<Map<String, dynamic>> getPrayerProgress(String prayerName) async {
    return await _analyticsService.getPrayerProgress(prayerName);
  }
}
