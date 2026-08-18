import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/flashcard_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

import 'services/live_activity_service.dart';
import 'services/storage_service.dart';
import 'services/widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await StorageService().init();
    await LiveActivityService().init();
    await WidgetService().init();
    final settings = SettingsProvider();
    await settings.init();
    runApp(EasyEnglishApp(preloadedSettings: settings));
  } catch (e) {
    debugPrint('Init error: $e');
    runApp(const EasyEnglishApp());
  }
}


class EasyEnglishApp extends StatelessWidget {
  final SettingsProvider? preloadedSettings;
  const EasyEnglishApp({super.key, this.preloadedSettings});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FlashcardProvider()),
        ChangeNotifierProvider(create: (_) => preloadedSettings ?? SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'EasyEnglish',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: settings.locale,
            supportedLocales: settings.supportedLocales,
            localizationsDelegates: settings.localizationsDelegates,
            localeResolutionCallback: (locale, supported) {
              if (locale == null) return supported.first;
              for (final l in supported) {
                if (l.languageCode == locale.languageCode) return l;
              }
              return supported.first;
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
