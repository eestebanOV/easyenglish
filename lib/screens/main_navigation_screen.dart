import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'quiz_setup_screen.dart';
import 'suggestions_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsProvider>().translate;
    final quiz = context.watch<QuizProvider>();
    final pendingCount = quiz.pendingSuggestions.length;

    final List<Widget> screens = [
      HomeScreen(onNavigateTab: _onTabTapped),
      const CategoriesScreen(),
      const QuizSetupScreen(),
      const SuggestionsScreen(),
      const StatsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: context.bg,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.surface,
          border: Border(
            top: BorderSide(
              color: context.border,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: context.surface,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: context.textSecondary.withValues(alpha: 0.65),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: t('nav.home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.grid_view_rounded),
              label: t('nav.categories'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.quiz_rounded),
              label: t('nav.quiz'),
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.lightbulb_rounded),
                  if (pendingCount > 0)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppTheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          pendingCount > 9 ? '9+' : '$pendingCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              label: t('nav.suggestions'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart_rounded),
              label: t('nav.progress'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_rounded),
              label: t('nav.settings'),
            ),
          ],
        ),
      ),
    );
  }
}
