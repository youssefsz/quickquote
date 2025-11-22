import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../models/quote.dart';
import '../services/storage_service.dart';
import '../widgets/quote_card.dart';

class QuoteProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Quote> _quotes = [];
  List<SwipeItem> _swipeItems = [];
  MatchEngine? _matchEngine;
  bool _isLoading = true;
  int _currentIndex = 0;
  // Cache for pre-built card widgets to avoid rebuild delays
  final Map<String, Widget> _cardCache = {};
  BuildContext? _cachedContext;
  Brightness? _cachedThemeBrightness;

  List<Quote> get quotes => _quotes;
  MatchEngine? get matchEngine => _matchEngine;
  bool get isLoading => _isLoading;

  QuoteProvider() {
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    _isLoading = true;
    notifyListeners();

    _quotes = await _storageService.getQuotes();

    // Restore last viewed position
    final lastViewedId = await _storageService.getLastViewedQuoteId();
    if (lastViewedId != null && _quotes.isNotEmpty) {
      final index = _quotes.indexWhere((q) => q.id == lastViewedId);
      if (index != -1 && index > 0) {
        // Rotate the list so the last viewed quote is first
        _quotes = [..._quotes.sublist(index), ..._quotes.sublist(0, index)];
      }
    }

    _initializeSwipeItems();

    _isLoading = false;
    notifyListeners();
  }

  void _initializeSwipeItems() {
    if (_quotes.isEmpty) return;

    // Create a large pool of swipe items for infinite effect
    // We'll create 3x the quotes to ensure smooth infinite scrolling
    final multiplier = _quotes.length < 10 ? 50 : 20;
    _swipeItems.clear();
    _cardCache.clear(); // Clear cache when reinitializing

    for (int i = 0; i < multiplier; i++) {
      for (var quote in _quotes) {
        _swipeItems.add(
          SwipeItem(
            content: quote,
            likeAction: () {
              _onSwipeLike(quote);
            },
            nopeAction: () {
              _onSwipe();
            },
            superlikeAction: () {
              _onSwipeLike(quote);
            },
          ),
        );
      }
    }

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  /// Pre-build and cache card widgets for a given context
  /// This eliminates the delay when swiping fast
  void prebuildCards(BuildContext context) {
    if (_quotes.isEmpty) return;
    
    final currentBrightness = Theme.of(context).brightness;
    // Rebuild cache if context or theme changed
    if (_cachedContext != context || _cachedThemeBrightness != currentBrightness) {
      _cachedContext = context;
      _cachedThemeBrightness = currentBrightness;
      _cardCache.clear();

      // Pre-build all unique quote cards
      for (var quote in _quotes) {
        if (!_cardCache.containsKey(quote.id)) {
          _cardCache[quote.id] = RepaintBoundary(
            child: QuoteCard(quote: quote),
          );
        }
      }
    }
  }

  /// Get a cached card widget for a quote, or build it if not cached
  Widget getCachedCard(Quote quote, BuildContext context) {
    // Update cache if context or theme changed
    final currentBrightness = Theme.of(context).brightness;
    if (_cachedContext != context || _cachedThemeBrightness != currentBrightness) {
      prebuildCards(context);
    }

    // Return cached widget if available
    if (_cardCache.containsKey(quote.id)) {
      return _cardCache[quote.id]!;
    }

    // Fallback: build on demand if not cached
    return RepaintBoundary(
      child: QuoteCard(quote: quote),
    );
  }

  void _onSwipe() {
    _currentIndex++;
    _saveCurrentPosition();

    // When we're halfway through, seamlessly add more items
    if (_currentIndex >= _swipeItems.length ~/ 2) {
      _addMoreItems();
    }
  }

  void _saveCurrentPosition() {
    if (_quotes.isEmpty) return;
    // Save the ID of the quote that is currently visible (or about to be)
    final currentQuote = _quotes[_currentIndex % _quotes.length];
    _storageService.saveLastViewedQuoteId(currentQuote.id);
  }

  void _onSwipeLike(Quote quote) {
    // Notify that a quote was liked (will be handled by SavedQuotesProvider)
    _onLikeCallback?.call(quote);
    _onSwipe();
  }

  // Callback for when a quote is liked
  Function(Quote)? _onLikeCallback;

  void setOnLikeCallback(Function(Quote) callback) {
    _onLikeCallback = callback;
  }

  void _addMoreItems() {
    if (_quotes.isEmpty) return;

    // Add another batch of quotes to the end
    for (var quote in _quotes) {
      _swipeItems.add(
        SwipeItem(
          content: quote,
          likeAction: () {
            _onSwipeLike(quote);
          },
          nopeAction: () {
            _onSwipe();
          },
          superlikeAction: () {
            _onSwipeLike(quote);
          },
        ),
      );
    }
  }

  void swipeToNext() {
    if (_matchEngine?.currentItem != null) {
      _matchEngine!.currentItem!.like();
    }
  }

  void resetSwipeCards() {
    _currentIndex = 0;
    // Note: We don't reset the rotation here, just the swipe engine
    // If the user wants to "reset" completely, they might expect to go back to start
    // But for now, "reset" usually means "reload" or "start over".
    // If we want to start over from the VERY beginning (ignoring saved state),
    // we would need to reload quotes without rotation.
    // But typically resetSwipeCards is internal.
    // Let's just re-init.
    _initializeSwipeItems();
    notifyListeners();
  }

  Future<void> addQuote(String text, String author) async {
    final newQuote = Quote(text: text, author: author);
    await _storageService.addQuote(newQuote);
    _quotes.add(newQuote);

    // Pre-build and cache the new card if context is available
    if (_cachedContext != null) {
      _cardCache[newQuote.id] = RepaintBoundary(
        child: QuoteCard(quote: newQuote),
      );
    }

    // Add to swipe items
    final newSwipeItem = SwipeItem(
      content: newQuote,
      likeAction: () {
        _onSwipeLike(newQuote);
      },
      nopeAction: () {
        _onSwipe();
      },
      superlikeAction: () {
        _onSwipeLike(newQuote);
      },
    );
    _swipeItems.add(newSwipeItem);

    notifyListeners();
  }
}
