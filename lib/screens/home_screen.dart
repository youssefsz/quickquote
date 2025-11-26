import 'package:circular_theme_reveal/circular_theme_reveal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../providers/quote_provider.dart';
import '../providers/saved_quotes_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/add_quote_modal.dart';
import '../models/quote.dart';
import 'package:light_dark_theme_toggle/light_dark_theme_toggle.dart';
import 'package:onboarding_overlay/onboarding_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<OnboardingState> onboardingKey = GlobalKey<OnboardingState>();
  late List<FocusNode> focusNodes;
  // Set to true to test onboarding on every restart
  final bool _alwaysShowOnboarding = true;

  @override
  void initState() {
    super.initState();

    focusNodes = List<FocusNode>.generate(
      3,
      (int i) => FocusNode(debugLabel: i.toString()),
      growable: false,
    );

    // Set up the callback to save quotes when liked
    // Using addPostFrameCallback to access context safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowOnboarding();

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

  Future<void> _checkAndShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!hasSeenOnboarding || _alwaysShowOnboarding) {
      // Small delay to ensure UI is ready
      await Future.delayed(const Duration(milliseconds: 500));
      if (onboardingKey.currentState != null) {
        onboardingKey.currentState!.show();
        if (!_alwaysShowOnboarding) {
          await prefs.setBool('hasSeenOnboarding', true);
        }
      }
    }
  }

  @override
  void dispose() {
    for (final node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final steps = [
      OnboardingStep(
        focusNode: focusNodes[0],
        titleText: "Swipe to Explore",
        titleTextColor: colorScheme.onSurface,
        bodyText: "Swipe Right to Save a quote.\nSwipe Left to Skip it.",
        bodyTextColor: colorScheme.onSurface.withOpacity(0.8),
        labelBoxPadding: const EdgeInsets.all(16.0),
        labelBoxDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.primary, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        arrowPosition: ArrowPosition.autoVertical,
        hasArrow: true,
        hasLabelBox: true,
        fullscreen: true,
        overlayColor: Colors.black.withOpacity(0.8),
        overlayBehavior: HitTestBehavior.opaque,
      ),
      OnboardingStep(
        focusNode: focusNodes[1],
        titleText: "Skip Button",
        titleTextColor: colorScheme.onSurface,
        bodyText: "Tap here to skip the current quote.",
        bodyTextColor: colorScheme.onSurface.withOpacity(0.8),
        labelBoxPadding: const EdgeInsets.all(16.0),
        labelBoxDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          color: colorScheme.surface,
          border: Border.all(color: Colors.red, width: 2.0),
        ),
        arrowPosition: ArrowPosition.autoVertical,
        hasArrow: true,
        hasLabelBox: true,
        fullscreen: true,
        overlayColor: Colors.black.withOpacity(0.8),
      ),
      OnboardingStep(
        focusNode: focusNodes[2],
        titleText: "Save Button",
        titleTextColor: colorScheme.onSurface,
        bodyText: "Tap here to save the quote to your collection.",
        bodyTextColor: colorScheme.onSurface.withOpacity(0.8),
        labelBoxPadding: const EdgeInsets.all(16.0),
        labelBoxDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          color: colorScheme.surface,
          border: Border.all(color: Colors.green, width: 2.0),
        ),
        arrowPosition: ArrowPosition.autoVertical,
        hasArrow: true,
        hasLabelBox: true,
        fullscreen: true,
        overlayColor: Colors.black.withOpacity(0.8),
      ),
    ];

    return Onboarding(
      key: onboardingKey,
      steps: steps,
      onChanged: (int index) {
        debugPrint('Onboarding step: $index');
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
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
                                      context
                                          .read<ThemeProvider>()
                                          .toggleTheme();
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

                    if (provider.matchEngine == null ||
                        provider.quotes.isEmpty) {
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

                    // Pre-build cards synchronously before rendering SwipeCards
                    // This ensures cards are ready when the widget tree builds
                    provider.prebuildCards(context);

                    return SizedBox(
                      height: 500,
                      child: Stack(
                        children: [
                          SwipeCards(
                            matchEngine: provider.matchEngine!,
                            itemBuilder: (BuildContext context, int index) {
                              // According to swipe_cards documentation, index maps directly to _swipeItems[index]
                              // The index represents the position in the swipeItems list
                              final swipeItems = provider.getSwipeItems();
                              
                              // Safety check: ensure index is within bounds
                              if (index < 0 || index >= swipeItems.length) {
                                // If index is out of bounds, return a placeholder
                                return Container(
                                  width: double.infinity,
                                  height: 500,
                                  color: Theme.of(context).cardTheme.color,
                                  child: Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                );
                              }
                              
                              // Get the SwipeItem at this index
                              final swipeItem = swipeItems[index];
                              final quote = swipeItem.content as Quote?;
                              
                              // If quote is null, return placeholder
                              if (quote == null) {
                                return Container(
                                  width: double.infinity,
                                  height: 500,
                                  color: Theme.of(context).cardTheme.color,
                                );
                              }
                              
                              // CRITICAL: Pre-build the next 2-3 cards synchronously while building current card
                              // This ensures they're ready before the swipe animation starts
                              // We build them here to ensure they're in the cache immediately
                              for (int offset = 1; offset <= 3 && (index + offset) < swipeItems.length; offset++) {
                                final nextSwipeItem = swipeItems[index + offset];
                                final nextQuote = nextSwipeItem.content as Quote?;
                                if (nextQuote != null) {
                                  // Synchronously ensure next cards are cached
                                  // This is safe because getCachedCard checks cache first
                                  provider.getCachedCard(nextQuote, context);
                                }
                              }
                              
                              // Use cached card to avoid rebuild delays and prevent blank screens
                              return provider.getCachedCard(quote, context);
                            },
                            onStackFinished: () {
                              // When stack is finished, add more items and reset
                              provider.addMoreItems();
                              provider.resetSwipeCards();
                            },
                            itemChanged: (SwipeItem item, int index) {
                              // Track the current item and pre-build next cards
                              // This is called when a card becomes the top card, so we build the next ones
                              provider.updateCurrentItem(item, index);
                              
                              // Force a microtask to ensure next cards are built
                              // This helps prevent blank screens during fast swiping
                              Future.microtask(() {
                                if (provider.matchEngine?.currentItem != null) {
                                  // Trigger a rebuild to ensure next cards are ready
                                  // The itemBuilder will be called for the next cards in the stack
                                }
                              });
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
                          // Invisible focus target for onboarding (half height)
                          Center(
                            child: Focus(
                              focusNode: focusNodes[0],
                              child: IgnorePointer(
                                child: Container(
                                  height: 250, // Half of 500
                                  width: double.infinity,
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ],
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
                      child: Focus(
                        focusNode: focusNodes[1],
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
                    ),
                    const SizedBox(width: 12),
                    // Save Button (Green - exact match to likeTag)
                    Expanded(
                      child: Focus(
                        focusNode: focusNodes[2],
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
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
