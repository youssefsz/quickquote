import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../services/storage_service.dart';

/// Provider for managing saved/favorited quotes
class SavedQuotesProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Quote> _savedQuotes = [];
  bool _isLoading = true;

  List<Quote> get savedQuotes => _savedQuotes;
  bool get isLoading => _isLoading;
  bool get hasSavedQuotes => _savedQuotes.isNotEmpty;
  int get savedCount => _savedQuotes.length;

  SavedQuotesProvider() {
    loadSavedQuotes();
  }

  /// Load all saved quotes from storage
  Future<void> loadSavedQuotes() async {
    _isLoading = true;
    notifyListeners();

    _savedQuotes = await _storageService.getSavedQuotes();

    _isLoading = false;
    notifyListeners();
  }

  /// Save a quote to favorites
  Future<void> saveQuote(Quote quote) async {
    // Check if already saved
    if (_savedQuotes.any((q) => q.id == quote.id)) {
      return;
    }

    await _storageService.saveQuoteToFavorites(quote);

    // Update local list immediately
    _savedQuotes.insert(0, quote); // Add to beginning for newest first
    notifyListeners();
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
}
