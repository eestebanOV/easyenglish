import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';
import '../providers/settings_provider.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/live_activity_pin_sheet.dart';
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

  void _openCardModal(Flashcard card) {
    bool isFlipped = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.darkBg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.category.nameEs,
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
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                LiveActivityPinSheet.show(context, card);
                              },
                              icon: const Icon(
                                Icons.notifications_active_rounded,
                                size: 22,
                              ),
                              label: const Text('Notificaciones del Día'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accent,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 48),
                              ),
                            ),
                          ),
                        ],
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
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
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
                    title: widget.category.nameEs,
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
              gradient: LinearGradient(
                colors: [
                  widget.category.color.withValues(alpha: 0.12),
                  AppTheme.darkCard,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(
                bottom: BorderSide(
                  color: widget.category.color.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.category.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(
                          color: widget.category.color.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(
                        widget.category.vectorIcon,
                        size: 28,
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
                                '${allCategoryCards.length} elementos en total',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: widget.category.color,
                                ),
                              ),
                              Text(
                                '${mastery.toInt()}% Dominio',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: mastery / 100,
                              backgroundColor: Colors.white12,
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
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: isIrregularVerbs
                        ? 'Buscar por infinitivo, pasado o español...'
                        : 'Buscar palabra o traducción...',
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Colors.white38,
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
                    fillColor: AppTheme.darkCard,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      borderSide: const BorderSide(color: AppTheme.darkBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      borderSide: const BorderSide(color: AppTheme.darkBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      borderSide: BorderSide(color: widget.category.color),
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
                    _buildFilterChip('Aprendidas', 'learned'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Nuevas', 'new'),
                  ],
                ),
              ],
            ),
          ),

          // Word List View
          Expanded(
            child: filteredCards.isEmpty
                ? const Center(
                    child: Text(
                      'No se encontraron resultados',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredCards.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
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

  /// TARJETA GRANDE Y DESTACADA PARA VERBOS IRREGULARES
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
            gradient: LinearGradient(
              colors: [const Color(0xFF1E283A), AppTheme.darkCard],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: isLearned
                  ? AppTheme.accent.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowSoft,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior con Número, Significado en español y Acciones
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.accentOrange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentOrange,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      card.wordEs,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_active_rounded,
                      size: 22,
                    ),
                    color: AppTheme.accent,
                    tooltip: 'Notificaciones del Día',
                    onPressed: () => LiveActivityPinSheet.show(context, card),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, size: 22),
                    color: AppTheme.primaryLight,
                    onPressed: () => _ttsService.speak(card.wordEn),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Bloque GRANDE de 3 tiempos verbales (Present, Past, Participle)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: Colors.white10),
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
                    Container(width: 1, height: 38, color: Colors.white12),
                    Expanded(
                      child: _buildLargeTenseColumn(
                        label: 'PASADO',
                        verb: card.past!,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                    Container(width: 1, height: 38, color: Colors.white12),
                    Expanded(
                      child: _buildLargeTenseColumn(
                        label: 'PARTICIPIO',
                        verb: card.participle!,
                        color: AppTheme.accentOrange,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              // Pronunciación fonética
              Row(
                children: [
                  const Icon(
                    Icons.record_voice_over_rounded,
                    size: 14,
                    color: Colors.white38,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      card.pronunciation,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withValues(alpha: 0.55),
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
            color: color.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          verb,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
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
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: isLearned
                  ? AppTheme.accent.withValues(alpha: 0.3)
                  : AppTheme.darkBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (!isVerbTenses) ...[
                      const SizedBox(height: 4),
                      Text(
                        card.wordEs,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_active_rounded, size: 22),
                color: AppTheme.accent,
                tooltip: 'Live Activity del Día',
                onPressed: () {
                  LiveActivityPinSheet.show(context, card);
                },
              ),
              if (!isVerbTenses)
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, size: 22),
                  color: AppTheme.primaryLight,
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
          color: isSelected ? AppTheme.darkBg : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
            _filter = value;
          });
        }
      },
    );
  }
}
