import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'services/database_service.dart';
import 'utils/theme_data.dart';
import 'screens/initial_setup_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final dbService = DatabaseService();
  await dbService.database;
  
  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseService>(create: (_) => dbService),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(
          create: (_) => PrayerProvider(dbService),
        ),
      ],
      child: const QadaaPrayerTrackerApp(),
    ),
  );
}

class QadaaPrayerTrackerApp extends StatefulWidget {
  const QadaaPrayerTrackerApp({Key? key}) : super(key: key);

  @override
  State<QadaaPrayerTrackerApp> createState() => _QadaaPrayerTrackerAppState();
}

class _QadaaPrayerTrackerAppState extends State<QadaaPrayerTrackerApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, langProvider, _) {
        return MaterialApp(
          title: 'Qadaa Prayer Tracker',
          theme: AppThemeData.getLightTheme(),
          darkTheme: AppThemeData.getDarkTheme(),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          locale: Locale(langProvider.isArabic ? 'ar' : 'en'),
          debugShowCheckedModeBanner: false,
          home: const _HomeRouter(),
          routes: {
            '/dashboard': (_) => DashboardScreen(),
          },
        );
      },
    );
  }
}

class _HomeRouter extends StatelessWidget {
  const _HomeRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: Future.delayed(Duration.zero).then((_) async {
        final provider = context.read<PrayerProvider>();
        await provider.initialize();
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mosque, size: 80, color: Colors.amber),
                  SizedBox(height: 16),
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing...'),
                ],
              ),
            ),
          );
        }

        return Consumer<PrayerProvider>(
          builder: (context, provider, _) {
            // Check if this is first time setup
            final hasCounts = provider.prayerCounts.any((p) => p.count > 0 || 
                provider.prayerCounts.any((x) => x.prayerName == p.prayerName));
            
            // Navigate to initial setup if no data
            if (provider.prayerCounts.isEmpty || 
                provider.prayerCounts.every((p) => p.count == 0)) {
              return InitialSetupScreen();
            }
            
            return DashboardScreen();
          },
        );
      },
    );
  }
}
