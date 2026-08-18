import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _selectedDailyGoal = AppConstants.defaultDailyGoal;

  final List<Map<String, String>> _pages = [
    {
      'emoji': '🧠',
      'title': 'Aprende con Ciencia',
      'subtitle': 'Usamos repetición espaciada (SRS) para que recuerdes el vocabulario a largo plazo sin esfuerzo.',
    },
    {
      'emoji': '⚡',
      'title': 'Tarjetas Interactivas',
      'subtitle': 'Voltea las flashcards para ver significados, ejemplos prácticos y escucha la pronunciación nativa.',
    },
    {
      'emoji': '🎯',
      'title': 'Tu Meta Diaria',
      'subtitle': 'Elige cuántas palabras nuevas deseas dominar cada día.',
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final settings = context.read<SettingsProvider>();
    await settings.setDailyGoal(_selectedDailyGoal);
    await settings.completeOnboarding();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: const Text(
                  'Omitir',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              page['emoji']!,
                              style: const TextStyle(fontSize: 54),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['subtitle']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        if (index == 2) ...[
                          const SizedBox(height: 32),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: AppConstants.dailyGoalOptions.map((goal) {
                              final isSelected = goal == _selectedDailyGoal;
                              return ChoiceChip(
                                label: Text(
                                  '$goal palabras/día',
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.white : Colors.white70,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: AppTheme.accent,
                                backgroundColor: AppTheme.darkCard,
                                side: BorderSide(
                                  color: isSelected ? AppTheme.accent : AppTheme.darkBorder,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedDailyGoal = goal;
                                    });
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.accent
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: AppTheme.darkBg,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? '¡Comenzar!' : 'Siguiente',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
