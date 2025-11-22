import 'package:circular_theme_reveal/circular_theme_reveal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/quote.dart';
import '../providers/saved_quotes_provider.dart';
import '../theme/app_theme.dart';
import 'package:light_dark_theme_toggle/light_dark_theme_toggle.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  @override
  void initState() {
    super.initState();
    // Reload saved quotes when screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedQuotesProvider>().loadSavedQuotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
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
                  Builder(
                    builder: (context) {
                      return LightDarkThemeToggle(
                        value: !isDarkMode,
                        onChanged: (_) async {
                          final overlay = CircularThemeRevealOverlay.of(
                            context,
                          );
                          final center =
                              CircularThemeRevealOverlay.getCenterFromContext(
                                context,
                              );

                          if (overlay != null) {
                            await overlay.startTransition(
                              center: center,
                              reverse: false,
                              onThemeChange: () {
                                context.read<ThemeProvider>().toggleTheme();
                              },
                            );
                          } else {
                            context.read<ThemeProvider>().toggleTheme();
                          }
                        },
                        themeIconType: ThemeIconType.classic,
                        size: 28,
                      );
                    },
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Consumer<SavedQuotesProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  if (!provider.hasSavedQuotes) {
                    return _buildEmptyState(theme);
                  }

                  return _buildSavedQuotesList(
                    context,
                    provider.savedQuotes,
                    theme,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.heart,
            size: 80,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No saved quotes yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save quotes from the home screen',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
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
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: quotes.length,
      itemBuilder: (context, index) {
        final quote = quotes[index];
        return _SavedQuoteCard(
          quote: quote,
          theme: theme,
          onDelete: () {
            context.read<SavedQuotesProvider>().removeQuote(quote);
          },
        );
      },
    );
  }
}

class _SavedQuoteCard extends StatelessWidget {
  final Quote quote;
  final ThemeData theme;
  final VoidCallback onDelete;

  const _SavedQuoteCard({
    required this.quote,
    required this.theme,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Dismissible(
          key: Key(quote.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.withOpacity(0.8), Colors.red],
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
            onPressed: () => _showQuoteDetail(context),
            pressedOpacity: 0.6,
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '— ${quote.author}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      // Use GestureDetector for the heart icon to avoid nested button issues
                      GestureDetector(
                        onTap: () async {
                          final confirm = await _showDeleteConfirmation(
                            context,
                          );
                          if (confirm == true) {
                            onDelete();
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            CupertinoIcons.heart_fill,
                            color: Colors.red.withOpacity(0.8),
                            size: 22,
                          ),
                        ),
                      ),
                    ],
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

  void _showQuoteDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuoteDetailModal(quote: quote),
    );
  }
}

class _QuoteDetailModal extends StatelessWidget {
  final Quote quote;

  const _QuoteDetailModal({required this.quote});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        // Use a slightly lighter dark color for the modal in dark mode
        color: isDarkMode
            ? const Color(0xFF1C1C1E)
            : theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Icon(
                    Icons.format_quote_rounded,
                    size: 60,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    quote.text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 24,
                      height: 1.5,
                      color: theme.textTheme.bodyLarge?.color,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '— ${quote.author}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.6,
                      ),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
