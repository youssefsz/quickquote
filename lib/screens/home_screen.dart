import 'package:circular_theme_reveal/circular_theme_reveal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../providers/quote_provider.dart';
import '../providers/saved_quotes_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/quote_card.dart';
import '../widgets/add_quote_modal.dart';
import 'package:light_dark_theme_toggle/light_dark_theme_toggle.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Set up the callback to save quotes when liked
    // Using addPostFrameCallback to access context safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quoteProvider = context.read<QuoteProvider>();
      final savedQuotesProvider = context.read<SavedQuotesProvider>();

      quoteProvider.setOnLikeCallback((quote) {
        // Fire-and-forget: save asynchronously without blocking the UI
        // This ensures the swipe animation remains smooth and instant
        // ignore: unawaited_futures
        savedQuotesProvider.saveQuote(quote);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QuickQuote',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      Builder(
                        builder: (context) {
                          return LightDarkThemeToggle(
                            value: !context.watch<ThemeProvider>().isDarkMode,
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
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const AddQuoteModal(),
                          );
                        },
                        icon: const Icon(CupertinoIcons.add, size: 26),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Main Content - Swipe Cards with fixed height
              Consumer<QuoteProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const SizedBox(
                      height: 500,
                      child: Center(child: CupertinoActivityIndicator()),
                    );
                  }

                  if (provider.matchEngine == null || provider.quotes.isEmpty) {
                    return SizedBox(
                      height: 500,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.quote_bubble,
                              size: 80,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color?.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No quotes available.",
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.5),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Add one to get started!",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.4),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 500,
                    child: SwipeCards(
                      matchEngine: provider.matchEngine!,
                      itemBuilder: (BuildContext context, int index) {
                        // Use modulo to create infinite loop effect
                        final quoteIndex = index % provider.quotes.length;
                        final quote = provider.quotes[quoteIndex];
                        return QuoteCard(quote: quote);
                      },
                      onStackFinished: () {
                        // This should rarely happen with our large pool
                        // But just in case, reset
                        provider.resetSwipeCards();
                      },
                      itemChanged: (SwipeItem item, int index) {
                        // Optional: Track which quote is being viewed
                      },
                      upSwipeAllowed: false,
                      fillSpace: false,
                      likeTag: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'SAVED',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      nopeTag: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'SKIP',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),

              // Bottom Buttons
              Row(
                children: [
                  // Skip Button (Red - exact match to nopeTag)
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          context
                              .read<QuoteProvider>()
                              .matchEngine
                              ?.currentItem
                              ?.nope();
                        },
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.red.withOpacity(0.9),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Save Button (Green - exact match to likeTag)
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          context
                              .read<QuoteProvider>()
                              .matchEngine
                              ?.currentItem
                              ?.like();
                        },
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.green.withOpacity(0.9),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
