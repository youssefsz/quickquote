import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/quote.dart';
import '../providers/saved_quotes_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/share_quote_button.dart';
import 'package:light_dark_theme_toggle/light_dark_theme_toggle.dart';
import 'quote_detail_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    // Reload saved quotes when screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SavedQuotesProvider>();
      provider.loadSavedQuotes();
      // Sync search controller with provider's search query
      if (provider.searchQuery.isNotEmpty) {
        _searchController.text = provider.searchQuery;
        _isSearchActive = true;
      }
    });

    // Listen to scroll events for pagination
    _scrollController.addListener(_onScroll);

    // Listen to search focus changes
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus &&
          _searchController.text.isEmpty &&
          _isSearchActive) {
        setState(() {
          _isSearchActive = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (_isSearchActive) {
        // Focus the search field when activating
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus();
        });
      } else {
        // Clear search when deactivating
        _searchController.clear();
        context.read<SavedQuotesProvider>().setSearchQuery('');
        _searchFocusNode.unfocus();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when user is 200px from bottom
      final provider = context.read<SavedQuotesProvider>();
      if (provider.hasMoreQuotes && !provider.isLoadingMore) {
        provider.loadMoreQuotes();
      }
    }
  }

  void _showFilterOptions(BuildContext context) {
    final provider = context.read<SavedQuotesProvider>();

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Sort Quotes'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              provider.setSortOrder(SortOrder.newestFirst);
              Navigator.pop(context);
              // Reset scroll position when sort changes
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Newest First'),
                if (provider.sortOrder == SortOrder.newestFirst)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(CupertinoIcons.check_mark, size: 18),
                  ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              provider.setSortOrder(SortOrder.oldestFirst);
              Navigator.pop(context);
              // Reset scroll position when sort changes
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Oldest First'),
                if (provider.sortOrder == SortOrder.oldestFirst)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(CupertinoIcons.check_mark, size: 18),
                  ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              // Small delay to ensure action sheet is fully dismissed
              await Future.delayed(const Duration(milliseconds: 100));
              if (mounted) {
                _showClearAllConfirmation(context);
              }
            },
            child: const Text('Clear All Quotes'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _showClearAllConfirmation(BuildContext context) async {
    // Get provider reference before async operation
    final provider = context.read<SavedQuotesProvider>();

    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear All Quotes'),
        content: const Text(
          'Are you sure you want to delete all saved quotes? This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            isDestructiveAction: true,
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    // Check if widget is still mounted before accessing context
    if (confirm == true && mounted) {
      await provider.clearAllQuotes();
    }
  }

  Widget _buildHeader(ThemeData theme, bool isDarkMode) {
    return SizedBox(
      key: const ValueKey('header'),
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Saved Quotes',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              // Theme toggle
              Builder(
                builder: (context) {
                  return LightDarkThemeToggle(
                    value: Theme.of(context).brightness != Brightness.dark,
                    onChanged: (_) {
                      context.read<ThemeProvider>().toggleTheme();
                    },
                    themeIconType: ThemeIconType.classic,
                    size: 28,
                  );
                },
              ),
              const SizedBox(width: 16),
              // Search button
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: _toggleSearch,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    CupertinoIcons.search,
                    size: 24,
                    color: theme.iconTheme.color,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Filter button
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: () => _showFilterOptions(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    CupertinoIcons.sort_down,
                    size: 24,
                    color: theme.iconTheme.color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    ThemeData theme,
    bool isDarkMode,
    SavedQuotesProvider provider,
  ) {
    return SizedBox(
      key: const ValueKey('search'),
      height: 44,
      child: Row(
        children: [
          // Search input field
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
              child: CupertinoTextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                placeholder: 'Search quotes or authors...',
                placeholderStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.4,
                  ),
                ),
                style: theme.textTheme.bodyMedium,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(),
                onChanged: (value) {
                  provider.setSearchQuery(value);
                  // Reset scroll position when search changes
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                },
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(
                    CupertinoIcons.search,
                    size: 20,
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Cancel button
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: _toggleSearch,
            child: Text(
              'Cancel',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionHeader(
    ThemeData theme,
    SavedQuotesProvider provider,
  ) {
    final isAllSelected = provider.isAllSelected;

    return SizedBox(
      key: const ValueKey('selection_header'),
      height: 44,
      child: Row(
        children: [
          // Cancel Button
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () => provider.clearSelection(),
            child: Text(
              'Cancel',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          Expanded(
            child: Text(
              '${provider.selectedCount} Selected',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Select/Deselect All Button
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: () {
                  if (isAllSelected) {
                    provider.clearSelection();
                  } else {
                    provider.selectAllQuotes();
                  }
                },
                child: Text(
                  isAllSelected ? 'Deselect All' : 'Select All',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Delete Button
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: provider.selectedCount > 0
                    ? () async {
                        final confirm = await _showDeleteSelectedConfirmation(
                          context,
                          provider.selectedCount,
                        );
                        if (confirm == true) {
                          await provider.removeSelectedQuotes();
                        }
                      }
                    : null,
                child: Icon(
                  CupertinoIcons.trash,
                  color: provider.selectedCount > 0 
                      ? Colors.red.withValues(alpha: 0.8)
                      : theme.disabledColor,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final theme = Theme.of(context);
    final provider = context.watch<SavedQuotesProvider>();

    // Determine which header to show
    Widget headerWidget;
    if (provider.isSelectionMode) {
      headerWidget = _buildSelectionHeader(theme, provider);
    } else if (_isSearchActive) {
      headerWidget = _buildSearchBar(theme, isDarkMode, provider);
    } else {
      headerWidget = _buildHeader(theme, isDarkMode);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with animated search/selection
            Padding(
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 16.0,
                bottom: 8.0,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
                child: headerWidget,
              ),
            ),

            // Content
            Expanded(
              child: Consumer<SavedQuotesProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  final filteredQuotes = provider.filteredQuotes;

                  if (!provider.hasSavedQuotes) {
                    return _buildEmptyState(theme, false);
                  }

                  if (filteredQuotes.isEmpty) {
                    return _buildEmptyState(theme, true);
                  }

                  return _buildSavedQuotesList(
                    context,
                    filteredQuotes,
                    theme,
                    provider,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteSelectedConfirmation(
    BuildContext context,
    int count,
  ) async {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Selected Quotes'),
        content: Text(
          'Are you sure you want to delete $count selected quote${count > 1 ? 's' : ''}?',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            isDestructiveAction: true,
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isSearchEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearchEmpty ? CupertinoIcons.search : CupertinoIcons.heart,
            size: 80,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            isSearchEmpty ? 'No quotes found' : 'No saved quotes yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearchEmpty
                ? 'Try a different search term'
                : 'Save quotes from the home screen',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedQuotesList(
    BuildContext context,
    List<Quote> quotes,
    ThemeData theme,
    SavedQuotesProvider provider,
  ) {
    return ListView.builder(
      controller: _scrollController,
      // Extra bottom padding for Liquid Glass tab bar on Apple platforms
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: (Platform.isIOS || Platform.isMacOS) ? 80 : 8,
      ),
      itemCount: quotes.length + (provider.hasMoreQuotes ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the bottom
        if (index == quotes.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: provider.isLoadingMore
                  ? const CupertinoActivityIndicator()
                  : const SizedBox.shrink(),
            ),
          );
        }

        final quote = quotes[index];
        final isSelected = provider.selectedQuoteIds.contains(quote.id);
        return _SavedQuoteCard(
          quote: quote,
          theme: theme,
          isSelected: isSelected,
          isSelectionMode: provider.isSelectionMode,
          onDelete: () {
            provider.removeQuote(quote);
          },
          onLongPress: () {
            provider.toggleQuoteSelection(quote.id);
          },
          onTap: () {
            if (provider.isSelectionMode) {
              provider.toggleQuoteSelection(quote.id);
            } else {
              _showQuoteDetail(context, quote);
            }
          },
        );
      },
    );
  }

  void _showQuoteDetail(BuildContext context, Quote quote) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: QuoteDetailScreen(quote: quote),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}



class _SavedQuoteCard extends StatelessWidget {
  final Quote quote;
  final ThemeData theme;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onDelete;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  const _SavedQuoteCard({
    required this.quote,
    required this.theme,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onDelete,
    required this.onLongPress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Hero(
        tag: 'quote_card_${quote.id}',
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: theme.brightness == Brightness.light
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
              border: isSelected
                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Main content
                  Dismissible(
                    key: Key(quote.id),
                    direction: isSelectionMode
                        ? DismissDirection.none
                        : DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.withValues(alpha: 0.8),
                            Colors.red,
                          ],
                        ),
                      ),
                      child: const Icon(
                        CupertinoIcons.delete,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await _showDeleteConfirmation(context);
                    },
                    onDismissed: (direction) {
                      onDelete();
                    },
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: onTap,
                      pressedOpacity: 0.6,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Checkbox in selection mode
                            if (isSelectionMode) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 12,
                                  top: 2,
                                ),
                                child: Icon(
                                  isSelected
                                      ? CupertinoIcons.check_mark_circled_solid
                                      : CupertinoIcons.circle,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.textTheme.bodyMedium?.color
                                            ?.withValues(alpha: 0.3),
                                  size: 24,
                                ),
                              ),
                            ],
                            // Quote content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Quote text
                                  Text(
                                    quote.text,
                                    style: GoogleFonts.dmSerifDisplay(
                                      fontSize: 18,
                                      height: 1.4,
                                      color: theme.textTheme.bodyLarge?.color,
                                      decoration: TextDecoration.none,
                                    ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),

                                  // Author and delete button row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '— ${quote.author}',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color
                                                    ?.withValues(alpha: 0.6),
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.3,
                                                decoration: TextDecoration.none,
                                              ),
                                        ),
                                      ),
                                      // Share and Delete buttons (only when not in selection mode)
                                      if (!isSelectionMode)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CompactShareButton(
                                              quote: quote,
                                              iconColor: theme
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color
                                                  ?.withValues(alpha: 0.7),
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                final confirm =
                                                    await _showDeleteConfirmation(
                                                      context,
                                                    );
                                                if (confirm == true) {
                                                  onDelete();
                                                }
                                              },
                                              behavior: HitTestBehavior.opaque,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                child: Icon(
                                                  CupertinoIcons.heart_fill,
                                                  color: Colors.red.withValues(
                                                    alpha: 0.8,
                                                  ),
                                                  size: 22,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showCupertinoDialog<bool>(
      barrierDismissible: true,
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Remove Quote'),
        content: const Text(
          'Are you sure you want to remove this quote from your saved collection?',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            isDestructiveAction: true,
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
