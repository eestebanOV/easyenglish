import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/widget_pin_sheet.dart';
import 'flashcard_session_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Category category;

  const CategoryDetailScreen({
    super.key,
    required this.category,
  });

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
            return Container(
              height: MediaQuery.of(context).size.height * 0.78,
              decoration: const BoxDecoration(
                color: AppTheme.darkBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
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
                  Expanded(
                    child: Center(
                      child: FlashcardWidget(
                        card: card,
                        isFlipped: isFlipped,
                        onFlip: () {
                          setModalState(() {
                            isFlipped = !isFlipped;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _ttsService.speak(card.wordEn);
                          },
                          icon: const Icon(Icons.volume_up_rounded, size: 20),
                          label: const Text('Pronunciar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.2),
                            foregroundColor: AppTheme.primaryLight,
                            minimumSize: const Size(0, 48),
                            side: BorderSide(color: AppTheme.primaryLight.withValues(alpha: 0.3)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            WidgetPinSheet.show(context, card);
                          },
                          icon: const Icon(Icons.push_pin_rounded, size: 20),
                          label: const Text('Fijar en Widget'),
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final flashcardProvider = context.watch<FlashcardProvider>();
    final allCategoryCards = flashcardProvider.allCards
        .where((c) => c.categoryId == widget.category.id)
        .toList();

    final filteredCards = allCategoryCards.where((card) {
      final matchesSearch = card.wordEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          card.wordEs.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (card.present?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (card.past?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (card.participle?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

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

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(widget.category.nameEs),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_filled_rounded),
            tooltip: 'Repasar Flashcards',
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
              color: AppTheme.darkCard,
              border: Border(bottom: BorderSide(color: AppTheme.darkBorder)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.category.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Text(
                        widget.category.icon,
                        style: const TextStyle(fontSize: 30),
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
                                '${allCategoryCards.length} elementos',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
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
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: mastery / 100,
                              backgroundColor: AppTheme.darkBorder,
                              valueColor: AlwaysStoppedAnimation<Color>(widget.category.color),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
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
                  icon: const Icon(Icons.style_rounded, size: 20),
                  label: const Text('Iniciar Sesión de Flashcards'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.category.color,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search and Filters Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar en la lista...',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.darkCard,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: BorderSide(color: AppTheme.darkBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: BorderSide(color: AppTheme.darkBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildFilterChip('Todos (${allCategoryCards.length})', 'all'),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredCards.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final card = filteredCards[index];
                      final progress = flashcardProvider.getProgressForCard(card.id);
                      final isLearned = progress.repetitions >= 1;

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
                                      if (card.isVerbWithForms) ...[
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: [
                                            _buildVerbBadge('PRES', card.present!, AppTheme.accent),
                                            _buildVerbBadge('PAST', card.past!, AppTheme.primaryLight),
                                            _buildVerbBadge('PART', card.participle!, AppTheme.accentOrange),
                                          ],
                                        ),
                                      ] else ...[
                                        Text(
                                          card.wordEn,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Text(
                                        card.wordEs,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.push_pin_outlined, size: 20),
                                  color: AppTheme.accent,
                                  tooltip: 'Fijar en Widget',
                                  onPressed: () {
                                    WidgetPinSheet.show(context, card);
                                  },
                                ),
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
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerbBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
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
          color: isSelected ? Colors.black87 : Colors.white70,
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
