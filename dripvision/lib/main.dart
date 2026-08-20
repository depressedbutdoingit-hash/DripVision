import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'services/purchase_service.dart';
import 'services/push_notification_service.dart';
import 'services/crashlytics_service.dart';
import 'views/screens/generator_screen.dart';
import 'views/screens/explore_drip_screen.dart';
import 'views/screens/settings_screen.dart';
import 'views/widgets/galaxy_background.dart';
import 'views/widgets/cosmic_stats_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  await CrashlyticsService.init();
  await PurchaseService.init();
  await PushNotificationService.init();
  runApp(const ProviderScope(child: DripVisionApp()));
}

class DripVisionApp extends StatelessWidget {
  const DripVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DripVision',
      debugShowCheckedModeBanner: false,
      theme: DripTheme.theme,
      home: const GalaxyBackground(child: MainShell()),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _screens = const [
    DripVisionStudioScreen(),
    ExploreDripScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_index],
          const CosmicStatsOverlay(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: DripTheme.surface.withOpacity(0.85),
          border: const Border(top: BorderSide(color: Colors.white10)),
          boxShadow: [
            BoxShadow(
              color: DripTheme.cosmicTeal.withOpacity(0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: DripTheme.cosmicTeal,
          unselectedItemColor: Colors.white30,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 1,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_fix_high),
              label: 'STUDIO',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'EXPLORE',
            ),
          ],
        ),
      ),
    );
  }
}
