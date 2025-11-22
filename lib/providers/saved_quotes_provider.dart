import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../services/storage_service.dart';

enum SortOrder { newestFirst, oldestFirst }

/// Provider for managing saved/favorited quotes
class SavedQuotesProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Quote> _savedQuotes = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _searchQuery = '';
  SortOrder _sortOrder = SortOrder.newestFirst;
  Set<String> _selectedQuoteIds = {};
  final int _itemsPerPage = 10;
  int _currentDisplayCount = 10;

  List<Quote> get savedQuotes => _savedQuotes;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasSavedQuotes => _savedQuotes.isNotEmpty;
  int get savedCount => _savedQuotes.length;
  String get searchQuery => _searchQuery;
  SortOrder get sortOrder => _sortOrder;
  Set<String> get selectedQuoteIds => _selectedQuoteIds;
  bool get isSelectionMode => _selectedQuoteIds.isNotEmpty;
  int get selectedCount => _selectedQuoteIds.length;

  SavedQuotesProvider() {
    loadSavedQuotes();
  }

  /// Load all saved quotes from storage
  Future<void> loadSavedQuotes() async {
    _isLoading = true;
    _currentDisplayCount = _itemsPerPage; // Reset pagination
    notifyListeners();

    _savedQuotes = await _storageService.getSavedQuotes();

    _isLoading = false;
    notifyListeners();
  }

  /// Get all filtered and sorted quotes (for search/filter operations)
  List<Quote> get _allFilteredQuotes {
    List<Quote> filtered = _savedQuotes;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((quote) {
        return quote.text.toLowerCase().contains(query) ||
            quote.author.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sort order
    filtered = List.from(filtered);
    filtered.sort((a, b) {
      final dateA = a.savedDate ?? DateTime(1970);
      final dateB = b.savedDate ?? DateTime(1970);
      
      if (_sortOrder == SortOrder.newestFirst) {
        return dateB.compareTo(dateA);
      } else {
        return dateA.compareTo(dateB);
      }
    });

    return filtered;
  }

  /// Get paginated filtered and sorted quotes
  List<Quote> get filteredQuotes {
    final allFiltered = _allFilteredQuotes;
    // Return only the items up to current display count
    return allFiltered.take(_currentDisplayCount).toList();
  }

  /// Check if there are more quotes to load
  bool get hasMoreQuotes {
    return _currentDisplayCount < _allFilteredQuotes.length;
  }

  /// Load more quotes (pagination)
  Future<void> loadMoreQuotes() async {
    if (_isLoadingMore || !hasMoreQuotes) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    // Simulate a small delay for smooth loading (optional, can be removed)
    await Future.delayed(const Duration(milliseconds: 300));

    _currentDisplayCount += _itemsPerPage;
    
    _isLoadingMore = false;
    notifyListeners();
  }

  /// Reset pagination (called when search or sort changes)
  void resetPagination() {
    _currentDisplayCount = _itemsPerPage;
    notifyListeners();
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    resetPagination(); // Reset pagination when search changes
    notifyListeners();
  }

  /// Set sort order
  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    resetPagination(); // Reset pagination when sort changes
    notifyListeners();
  }

  /// Toggle selection of a quote
  void toggleQuoteSelection(String quoteId) {
    if (_selectedQuoteIds.contains(quoteId)) {
      _selectedQuoteIds.remove(quoteId);
    } else {
      _selectedQuoteIds.add(quoteId);
    }
    notifyListeners();
  }

  /// Select all quotes (all filtered, not just displayed)
  void selectAllQuotes() {
    _selectedQuoteIds = _allFilteredQuotes.map((q) => q.id).toSet();
    notifyListeners();
  }

  /// Clear all selections
  void clearSelection() {
    _selectedQuoteIds.clear();
    notifyListeners();
  }

  /// Save a quote to favorites
  Future<void> saveQuote(Quote quote) async {
    // Check if already saved
    if (_savedQuotes.any((q) => q.id == quote.id)) {
      return;
    }

    await _storageService.saveQuoteToFavorites(quote);

    // Reload to get the quote with timestamp
    await loadSavedQuotes();
  }

  /// Remove a quote from favorites
  Future<void> removeQuote(Quote quote) async {
    await _storageService.removeQuoteFromFavorites(quote);

    // Update local list
    _savedQuotes.removeWhere((q) => q.id == quote.id);
    notifyListeners();
  }

  /// Check if a quote is saved
  bool isQuoteSaved(Quote quote) {
    return _savedQuotes.any((q) => q.id == quote.id);
  }

  /// Toggle save status of a quote
  Future<void> toggleSaveQuote(Quote quote) async {
    if (isQuoteSaved(quote)) {
      await removeQuote(quote);
    } else {
      await saveQuote(quote);
    }
  }

  /// Remove multiple quotes by their IDs
  Future<void> removeSelectedQuotes() async {
    final quotesToRemove = _savedQuotes
        .where((q) => _selectedQuoteIds.contains(q.id))
        .toList();
    
    for (final quote in quotesToRemove) {
      await _storageService.removeQuoteFromFavorites(quote);
    }

    // Update local list
    _savedQuotes.removeWhere((q) => _selectedQuoteIds.contains(q.id));
    _selectedQuoteIds.clear();
    notifyListeners();
  }

  /// Clear all saved quotes
  Future<void> clearAllQuotes() async {
    for (final quote in _savedQuotes) {
      await _storageService.removeQuoteFromFavorites(quote);
    }

    _savedQuotes.clear();
    _selectedQuoteIds.clear();
    notifyListeners();
  }
}
