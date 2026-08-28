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

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.psychology_rounded,
      'titleKey': 'onb.page1.title',
      'subKey': 'onb.page1.sub',
    },
    {
      'icon': Icons.style_rounded,
      'titleKey': 'onb.page2.title',
      'subKey': 'onb.page2.sub',
    },
    {
      'icon': Icons.track_changes_rounded,
      'titleKey': 'onb.page3.title',
      'subKey': 'onb.page3.sub',
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
    final settings = context.watch<SettingsProvider>();
    final t = settings.translate;

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  t('onb.skip'),
                  style: TextStyle(color: context.textSecondary, fontSize: 14),
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
                  final IconData icon = page['icon'] as IconData;
                  final String title = t(page['titleKey'] as String);
                  final String sub = t(page['subKey'] as String);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: context.isDark ? 0.15 : 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 1.5),
                          ),
                          child: Center(
                            child: Icon(
                              icon,
                              size: 48,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          sub,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: context.textSecondary,
                          ),
                        ),
                        if (index == 2) ...[
                          const SizedBox(height: 28),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: AppConstants.dailyGoalOptions.map((goal) {
                              final isSelected = goal == _selectedDailyGoal;
                              return ChoiceChip(
                                label: Text(
                                  '$goal ${t('settings.dailyGoal.subtitle')}',
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.white : context.textSecondary,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: AppTheme.primary,
                                backgroundColor: context.cardBg,
                                side: BorderSide(
                                  color: isSelected ? AppTheme.primary : context.border,
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
                              ? AppTheme.primary
                              : context.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? t('onb.finish') : t('onb.next'),
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
