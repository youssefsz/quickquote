import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../providers/quote_provider.dart';
import '../providers/saved_quotes_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/add_quote_modal.dart';
import '../widgets/share_quote_button.dart';
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
  void dispose() {
    super.dispose();
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
                            value:
                                Theme.of(context).brightness != Brightness.dark,
                            onChanged: (_) {
                              context.read<ThemeProvider>().toggleTheme();
                            },
                            themeIconType: ThemeIconType.classic,
                            size: 28,
                          );
                        },
                      ),
                      // Share button - only show if there's a current quote
                      Consumer<QuoteProvider>(
                        builder: (context, quoteProvider, child) {
                          final currentQuote = quoteProvider.currentQuote;
                          if (currentQuote == null) {
                            return const SizedBox.shrink();
                          }
                          return ShareQuoteButton(
                            quote: currentQuote,
                            size: 26,
                            padding: const EdgeInsets.all(8),
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

                  if (provider.quotes.isEmpty) {
                    return SizedBox(
                      height: 500,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.quote_bubble,
                              size: 80,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.3),
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
                                        ?.withValues(alpha: 0.5),
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
                                        ?.withValues(alpha: 0.4),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Pre-build cards to eliminate delay when swiping fast
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    provider.prebuildCards(context);
                  });

                  return SizedBox(
                    height: 500,
                    child: Stack(
                      children: [
                        CardSwiper(
                          controller: provider.controller,
                          cardsCount: provider.quotes.isEmpty
                              ? 0
                              : provider.quotes.length *
                                    100, // Large number for infinite effect
                          cardBuilder:
                              (
                                context,
                                index,
                                percentThresholdX,
                                percentThresholdY,
                              ) {
                                // Use modulo to create infinite loop effect
                                final quoteIndex =
                                    index % provider.quotes.length;
                                final quote = provider.quotes[quoteIndex];
                                // Get cached card
                                final card = provider.getCachedCard(
                                  quote,
                                  context,
                                );

                                // Show tags only for the top card (index 0 relative to current)
                                // percentThresholdX > 0 means swiping right, < 0 means swiping left
                                final showTag = percentThresholdX.abs() > 0.1;
                                final isRight = percentThresholdX > 0;
                                final opacity =
                                    (percentThresholdX.abs() * 100.0)
                                        .clamp(0.0, 1.0)
                                        .toDouble();

                                return Stack(
                                  children: [
                                    card,
                                    if (showTag)
                                      Positioned(
                                        top: 16,
                                        left: isRight ? 16 : null,
                                        right: isRight ? null : 16,
                                        child: IgnorePointer(
                                          child: AnimatedOpacity(
                                            opacity: opacity,
                                            duration: const Duration(
                                              milliseconds: 50,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isRight
                                                    ? Colors.green.withValues(
                                                        alpha: 0.9,
                                                      )
                                                    : Colors.red.withValues(
                                                        alpha: 0.9,
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                isRight ? 'SAVED' : 'SKIP',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                          onSwipe: (previousIndex, currentIndex, direction) {
                            return provider.onSwipe(
                              previousIndex,
                              currentIndex,
                              direction,
                            );
                          },
                          onEnd: () {
                            // Reset to beginning for infinite loop
                            provider.resetSwipeCards();
                          },
                          allowedSwipeDirection:
                              const AllowedSwipeDirection.only(
                                left: true,
                                right: true,
                              ),
                          isLoop: true,
                          threshold: 50,
                          maxAngle: 30,
                          scale: 0.9,
                          numberOfCardsDisplayed: 2,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Spacer(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
