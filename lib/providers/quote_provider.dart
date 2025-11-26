import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../models/quote.dart';
import '../services/storage_service.dart';
import '../widgets/quote_card.dart';

class QuoteProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Quote> _quotes = [];
  final List<SwipeItem> _swipeItems = [];
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
  
  // Track the current item index in the MatchEngine
  int? _currentMatchEngineIndex;
  
  /// Get the swipe items list (for itemBuilder access)
  List<SwipeItem> getSwipeItems() {
    return _swipeItems;
  }

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

    // Create a reasonable pool of swipe items (not too many to avoid performance issues)
    // Start with a smaller pool and add more dynamically as needed
    final multiplier = _quotes.length < 10 ? 10 : 5;
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
    
    // Pre-build cards if context is already available
    // This helps prevent blank screens on initial load
    if (_cachedContext != null) {
      prebuildCards(_cachedContext!);
    }
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
    }

    // Pre-build all unique quote cards to ensure they're ready
    // This prevents blank screens when swiping
    for (var quote in _quotes) {
      if (!_cardCache.containsKey(quote.id)) {
        _cardCache[quote.id] = RepaintBoundary(
          child: QuoteCard(quote: quote),
        );
      }
    }
  }
  
  /// Pre-build cards for the next N items in the swipe stack
  /// This ensures smooth transitions without blank screens
  void prebuildNextCards(BuildContext context, int count) {
    if (_swipeItems.isEmpty || _quotes.isEmpty) return;
    
    prebuildCards(context); // Ensure all unique quotes are cached
    
    // Pre-build cards for the next several items in the stack
    // This helps when swiping quickly
    final currentIndex = _currentIndex;
    for (int i = 0; i < count && (currentIndex + i) < _swipeItems.length; i++) {
      final quote = getQuoteFromSwipeIndex(currentIndex + i);
      if (quote != null && !_cardCache.containsKey(quote.id)) {
        _cardCache[quote.id] = RepaintBoundary(
          child: QuoteCard(quote: quote),
        );
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

  /// Get the quote from a swipe item index
  /// This ensures we correctly map the index to the actual SwipeItem content
  Quote? getQuoteFromSwipeIndex(int index) {
    if (index < 0 || index >= _swipeItems.length) {
      return null;
    }
    final swipeItem = _swipeItems[index];
    return swipeItem.content as Quote?;
  }
  
  /// Update the current item being displayed (called from itemChanged callback)
  void updateCurrentItem(SwipeItem item, int index) {
    _currentMatchEngineIndex = index;
    // Find the index in our _swipeItems list
    final itemIndex = _swipeItems.indexOf(item);
    if (itemIndex != -1) {
      _currentIndex = itemIndex;
      
      // CRITICAL: Pre-build the next 3-5 cards immediately when item changes
      // This ensures they're ready before the swipe animation completes
      if (_cachedContext != null) {
        // Pre-build cards for the next items in the stack (index + 1, +2, +3, etc.)
        for (int i = 1; i <= 5 && (itemIndex + i) < _swipeItems.length; i++) {
          final nextQuote = getQuoteFromSwipeIndex(itemIndex + i);
          if (nextQuote != null && !_cardCache.containsKey(nextQuote.id)) {
            _cardCache[nextQuote.id] = RepaintBoundary(
              child: QuoteCard(quote: nextQuote),
            );
          }
        }
      }
    }
  }
  
  /// Get the current item index in the MatchEngine
  int? getCurrentItemIndex() {
    return _currentMatchEngineIndex;
  }
  
  /// Add more items to the swipe stack (public for onStackFinished)
  void addMoreItems() {
    _addMoreItems();
  }

  void _onSwipe() {
    _currentIndex++;
    _saveCurrentPosition();

    // Pre-build next cards to prevent blank screens
    if (_cachedContext != null) {
      prebuildNextCards(_cachedContext!, 10); // Pre-build next 10 cards
    }

    // Add more items earlier to ensure we always have enough
    // This prevents blank screens when the stack runs low
    if (_currentIndex >= _swipeItems.length ~/ 3) {
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
    
    // CRITICAL: Recreate MatchEngine with updated swipeItems list
    // The MatchEngine needs to know about the new items
    // Note: Recreating MatchEngine will reset to the first item, but this ensures
    // the new items are available. The user will continue from where they were
    // since we track _currentIndex separately.
    if (_matchEngine != null) {
      _matchEngine = MatchEngine(swipeItems: _swipeItems);
      notifyListeners();
    }
    
    // Pre-build cards for the newly added items if context is available
    if (_cachedContext != null) {
      for (var quote in _quotes) {
        if (!_cardCache.containsKey(quote.id)) {
          _cardCache[quote.id] = RepaintBoundary(
            child: QuoteCard(quote: quote),
          );
        }
      }
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
