import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../models/category.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/flashcard_widget.dart';
import 'flashcard_session_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Category category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TtsService _ttsService = TtsService();
  String _searchQuery = '';
  String _filter = 'all'; // 'all', 'learned', 'new'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showPinNotificationDialog(BuildContext context, Flashcard card, SettingsProvider settings) {
    TimeOfDay selectedStart = const TimeOfDay(
      hour: AppConstants.notificationDefaultStartHour,
      minute: AppConstants.notificationDefaultStartMinute,
    );
    int selectedInterval = settings.itemNotificationConfig?.intervalMinutes ??
        AppConstants.defaultNotificationInterval;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final count = NotificationService.generateTimeSlots(
              startTime: selectedStart,
              intervalMinutes: selectedInterval,
            ).length;

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(dialogContext).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: context.border),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: context.textSecondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.push_pin_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.wordEn,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: context.textPrimary,
                                ),
                              ),
                              Text(
                                card.wordEs,
                                style: TextStyle(fontSize: 13, color: context.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (card.hasStructure) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.architecture_rounded, size: 16, color: AppTheme.accentPurple),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Fórmula: ${card.structure}',
                                style: TextStyle(fontSize: 12, color: context.textPrimary, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Text(
                      'HORA DE INICIO DEL DÍA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: dialogContext,
                          initialTime: selectedStart,
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedStart = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: context.cardSecondary,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: context.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedStart.format(context),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            const Icon(Icons.access_time_rounded, color: AppTheme.primary, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'INTERVALO DE REPETICIÓN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: AppConstants.notificationIntervalOptions.map((interval) {
                        final isSel = selectedInterval == interval;
                        final label = interval >= 60 ? '${interval ~/ 60} h' : '$interval min';
                        return ChoiceChip(
                          label: Text(label),
                          selected: isSel,
                          selectedColor: AppTheme.primary,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : context.textSecondary,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: context.cardSecondary,
                          side: BorderSide(color: isSel ? AppTheme.primary : context.border),
                          onSelected: (sel) {
                            if (sel) {
                              setDialogState(() {
                                selectedInterval = interval;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.bolt_rounded, size: 16, color: AppTheme.accentAmber),
                        const SizedBox(width: 6),
                        Text(
                          'Se programarán $count notificaciones rotativas al día.',
                          style: TextStyle(fontSize: 12, color: context.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await settings.setItemForNotifications(
                            card,
                            startTime: selectedStart,
                            intervalMinutes: selectedInterval,
                          );
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '"${card.wordEn}" programada: $count avisos cada $selectedInterval min',
                                ),
                                backgroundColor: AppTheme.primary,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Guardar y Activar Horarios',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openCardModal(Flashcard card) {
    bool isFlipped = false;
    final settings = context.read<SettingsProvider>();
    final isEs = settings.languageCode == 'es';
    final isPinned = settings.itemNotificationConfig?.cardId == card.id &&
        (settings.itemNotificationConfig?.isEnabled ?? false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: context.bg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: context.border),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: context.textSecondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEs ? widget.category.nameEs : widget.category.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: widget.category.color,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FlashcardWidget(
                        card: card,
                        isFlipped: isFlipped,
                        onFlip: () {
                          setModalState(() {
                            isFlipped = !isFlipped;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Pin for Notifications button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showPinNotificationDialog(context, card, settings);
                          },
                          icon: Icon(
                            isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                            size: 18,
                          ),
                          label: Text(
                            isPinned
                                ? 'Configurar Notificaciones (Fijada)'
                                : 'Fijar para Notificaciones',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPinned
                                ? AppTheme.primary.withValues(alpha: 0.15)
                                : AppTheme.primary,
                            foregroundColor: isPinned ? AppTheme.primary : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: AppTheme.primary.withValues(alpha: isPinned ? 0.4 : 1.0),
                              ),
                            ),
                            elevation: isPinned ? 0 : 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final flashcardProvider = context.watch<FlashcardProvider>();
    final settings = context.watch<SettingsProvider>();
    final t = settings.translate;
    final isEs = settings.languageCode == 'es';

    final allCategoryCards = flashcardProvider.allCards
        .where((c) => c.categoryId == widget.category.id)
        .toList();

    final filteredCards = allCategoryCards.where((card) {
      final matchesSearch =
          card.wordEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          card.wordEs.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (card.present?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false) ||
          (card.past?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false) ||
          (card.participle?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);

      if (!matchesSearch) return false;

      final progress = flashcardProvider.getProgressForCard(card.id);
      if (_filter == 'learned') {
        return progress.repetitions >= 1;
      } else if (_filter == 'new') {
        return progress.isNew;
      }
      return true;
    }).toList();

    final mastery = flashcardProvider.getCategoryMastery(widget.category.id);
    final isIrregularVerbs = widget.category.id == 'irregular_verbs';

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(isEs ? widget.category.nameEs : widget.category.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_filled_rounded),
            tooltip: t('home.studyNow'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FlashcardSessionScreen(
                    categoryId: widget.category.id,
                    title: isEs ? widget.category.nameEs : widget.category.name,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Hero Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: widget.category.color.withValues(alpha: context.isDark ? 0.24 : 0.16),
              border: Border(
                bottom: BorderSide(
                  color: widget.category.color.withValues(alpha: context.isDark ? 0.35 : 0.22),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.category.color.withValues(alpha: context.isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(
                      color: widget.category.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    widget.category.vectorIcon,
                    size: 26,
                    color: widget.category.color,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${allCategoryCards.length} ${widget.category.id == 'daily_phrases' ? t('catcount.phrases') : t('catcount.words')}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: widget.category.color,
                            ),
                          ),
                          Text(
                            '${mastery.toInt()}% ${t('home.dominio')}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: mastery / 100,
                          backgroundColor: context.isDark ? Colors.white12 : Colors.black12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.category.color,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search and Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(color: context.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: t('cat.search'),
                    hintStyle: TextStyle(
                      color: context.textSecondary.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: context.textSecondary,
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: context.cardBg,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: BorderSide(color: context.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: BorderSide(color: context.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: BorderSide(color: AppTheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFilterChip(
                      'Todas (${allCategoryCards.length})',
                      'all',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(t('home.learned'), 'learned'),
                    const SizedBox(width: 8),
                    _buildFilterChip(t('stats.legendNew'), 'new'),
                  ],
                ),
              ],
            ),
          ),

          // Word List View
          Expanded(
            child: filteredCards.isEmpty
                ? Center(
                    child: Text(
                      'No se encontraron resultados',
                      style: TextStyle(color: context.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredCards.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final card = filteredCards[index];
                      final progress = flashcardProvider.getProgressForCard(
                        card.id,
                      );
                      final isLearned = progress.repetitions >= 1;

                      if (isIrregularVerbs && card.isVerbWithForms) {
                        return _buildLargeIrregularVerbCard(
                          card,
                          index,
                          isLearned,
                        );
                      }

                      return _buildStandardWordCard(card, index, isLearned);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// TARJETA PARA VERBOS IRREGULARES
  Widget _buildLargeIrregularVerbCard(
    Flashcard card,
    int index,
    bool isLearned,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openCardModal(card),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.category.color.withValues(alpha: context.isDark ? 0.24 : 0.16),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: isLearned
                  ? AppTheme.accent.withValues(alpha: 0.5)
                  : widget.category.color.withValues(alpha: context.isDark ? 0.45 : 0.28),
              width: 1.2,
            ),
            boxShadow: context.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: widget.category.color.withValues(alpha: context.isDark ? 0.30 : 0.20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.category.color.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: context.isDark ? Colors.white : widget.category.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      card.wordEs,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                    color: AppTheme.primary,
                    onPressed: () => _ttsService.speak(card.wordEn),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.category.color.withValues(alpha: context.isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: widget.category.color.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildLargeTenseColumn(
                        label: 'INFINITIVO',
                        verb: card.present!,
                        color: AppTheme.accent,
                      ),
                    ),
                    Container(width: 1, height: 32, color: context.border),
                    Expanded(
                      child: _buildLargeTenseColumn(
                        label: 'PASADO',
                        verb: card.past!,
                        color: AppTheme.primary,
                      ),
                    ),
                    Container(width: 1, height: 32, color: context.border),
                    Expanded(
                      child: _buildLargeTenseColumn(
                        label: 'PARTICIPIO',
                        verb: card.participle!,
                        color: AppTheme.accentAmber,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.record_voice_over_rounded,
                    size: 13,
                    color: context.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      card.pronunciation,
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: context.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeTenseColumn({
    required String label,
    required String verb,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: color,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          verb,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: context.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  /// TARJETA ESTÁNDAR PARA FRASES Y VOCABULARIO
  Widget _buildStandardWordCard(Flashcard card, int index, bool isLearned) {
    final isVerbTenses = widget.category.id == 'verb_tenses';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openCardModal(card),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.category.color.withValues(alpha: context.isDark ? 0.24 : 0.16),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: isLearned
                  ? AppTheme.accent.withValues(alpha: 0.5)
                  : widget.category.color.withValues(alpha: context.isDark ? 0.45 : 0.28),
              width: 1.2,
            ),
            boxShadow: context.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.category.color.withValues(alpha: context.isDark ? 0.30 : 0.20),
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.category.color.withValues(alpha: 0.35)),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: context.isDark ? Colors.white : widget.category.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.wordEn,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    if (!isVerbTenses) ...[
                      const SizedBox(height: 3),
                      Text(
                        card.wordEs,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isVerbTenses)
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, size: 20),
                  color: AppTheme.primary,
                  onPressed: () {
                    _ttsService.speak(card.wordEn);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : context.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
            _filter = value;
          });
        }
      },
    );
  }
}
