import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/prayer_model.dart';
import 'database_service.dart';

class ExportService {
  final DatabaseService databaseService;

  ExportService(this.databaseService);

  // Feature 9: Export prayer logs to CSV
  Future<String> exportToCSV() async {
    try {
      final logs = await databaseService.getPrayerLogs();
      final counts = await databaseService.getPrayerCounts();

      // Prepare CSV data
      List<List<dynamic>> csvData = [
        ['Prayer Log Export', DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())],
        [],
        ['Prayer Logs'],
        ['Date', 'Prayer Name', 'Time', 'Notes', 'Edited'],
      ];

      for (var log in logs) {
        csvData.add([
          DateFormat('yyyy-MM-dd').format(log.dateLogged),
          log.prayerName,
          log.timeOfDay ?? 'Not specified',
          log.notes ?? '',
          log.isEdited ?? false ? 'Yes' : 'No',
        ]);
      }

      csvData.add([]);
      csvData.add(['Prayer Counts Summary']);
      csvData.add(['Prayer', 'Total Count']);

      for (var count in counts) {
        csvData.add([count.prayerName, count.count]);
      }

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(csvData);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final file = File('${directory.path}/prayer_logs_$timestamp.csv');

      await file.writeAsString(csv);
      return file.path;
    } catch (e) {
      print('Error exporting to CSV: $e');
      throw Exception('Failed to export to CSV: $e');
    }
  }

  // Feature 9: Export prayer logs to PDF
  Future<String> exportToPDF() async {
    try {
      final logs = await databaseService.getPrayerLogs();
      final counts = await databaseService.getPrayerCounts();
      final dailyStats = <DailyStatistics>[];

      // Group logs by date for statistics
      final logsByDate = <String, List<PrayerLog>>{};
      for (var log in logs) {
        final dateKey = DateFormat('yyyy-MM-dd').format(log.dateLogged);
        logsByDate.putIfAbsent(dateKey, () => []).add(log);
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Prayer Logs Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary Section
            pw.Text(
              'Summary Statistics',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Total Prayers Logged',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          logs.length.toString(),
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Unique Days Tracked',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          logsByDate.length.toString(),
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Prayer Counts
            pw.Text(
              'Prayer Summary',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Prayer',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Count',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...counts.map(
                  (count) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(count.prayerName),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(count.count.toString()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Recent Logs
            pw.Text(
              'Recent Prayer Logs (Last 30 entries)',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Date',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Prayer',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Time',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Notes',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...logs.take(30).map(
                  (log) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          DateFormat('yyyy-MM-dd').format(log.dateLogged),
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          log.prayerName,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          log.timeOfDay ?? '-',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          log.notes ?? '-',
                          style: const pw.TextStyle(fontSize: 10),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final file = File('${directory.path}/prayer_logs_$timestamp.pdf');

      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (e) {
      print('Error exporting to PDF: $e');
      throw Exception('Failed to export to PDF: $e');
    }
  }

  // Feature 9: Generate text report
  Future<String> generateTextReport() async {
    try {
      final logs = await databaseService.getPrayerLogs();
      final counts = await databaseService.getPrayerCounts();

      final buffer = StringBuffer();
      buffer.writeln('PRAYER LOGS REPORT');
      buffer.writeln('Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
      buffer.writeln('');

      buffer.writeln('SUMMARY');
      buffer.writeln('Total Prayers: ${logs.length}');
      buffer.writeln('');

      buffer.writeln('PRAYER BREAKDOWN');
      for (var count in counts) {
        buffer.writeln('${count.prayerName}: ${count.count}');
      }
      buffer.writeln('');

      buffer.writeln('RECENT ENTRIES');
      for (var log in logs.take(50)) {
        buffer.writeln(
          '${DateFormat('yyyy-MM-dd').format(log.dateLogged)} - ${log.prayerName} (${log.timeOfDay ?? 'N/A'})',
        );
      }

      return buffer.toString();
    } catch (e) {
      print('Error generating report: $e');
      throw Exception('Failed to generate report: $e');
    }
  }

  // Feature 9: Get export directory
  Future<Directory> getExportDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }
}
