import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../models/quote.dart';
import '../services/storage_service.dart';
import '../widgets/quote_card.dart';

class QuoteProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Quote> _quotes = [];
  final CardSwiperController _controller = CardSwiperController();
  bool _isLoading = true;
  int _currentIndex = 0;
  // Cache for pre-built card widgets to avoid rebuild delays
  final Map<String, Widget> _cardCache = {};
  BuildContext? _cachedContext;
  Brightness? _cachedThemeBrightness;

  List<Quote> get quotes => _quotes;
  CardSwiperController get controller => _controller;
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

    _isLoading = false;
    notifyListeners();
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

  void _onSwipe(int previousIndex, int currentIndex, CardSwiperDirection direction) {
    _currentIndex = currentIndex;
    _saveCurrentPosition();
  }

  void _saveCurrentPosition() {
    if (_quotes.isEmpty) return;
    // Save the ID of the quote that is currently visible (or about to be)
    final currentQuote = _quotes[_currentIndex % _quotes.length];
    _storageService.saveLastViewedQuoteId(currentQuote.id);
  }

  bool onSwipe(int? previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (_quotes.isEmpty || previousIndex == null || currentIndex == null) return false;
    
    // Get the quote that was swiped
    final quoteIndex = previousIndex % _quotes.length;
    final quote = _quotes[quoteIndex];
    
    // If swiped right (like), save the quote
    if (direction == CardSwiperDirection.right) {
      _onLikeCallback?.call(quote);
    }
    
    _onSwipe(previousIndex, currentIndex, direction);
    return true; // Allow the swipe
  }

  // Callback for when a quote is liked
  Function(Quote)? _onLikeCallback;

  void setOnLikeCallback(Function(Quote) callback) {
    _onLikeCallback = callback;
  }

  void swipeToNext() {
    _controller.swipe(CardSwiperDirection.right);
  }

  void swipeToSkip() {
    _controller.swipe(CardSwiperDirection.left);
  }

  void resetSwipeCards() {
    _currentIndex = 0;
    _controller.moveTo(0);
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

    notifyListeners();
  }
}
