import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote.dart';

class StorageService {
  static const String _quotesKey = 'quotes_list';
  static const String _savedQuotesKey = 'saved_quotes';

  // ==================== MAIN QUOTES ====================

  Future<List<Quote>> getQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? quotesString = prefs.getString(_quotesKey);

    if (quotesString == null) {
      // First run, load from JSON file
      final defaultQuotes = await _loadQuotesFromAssets();
      await saveQuotes(defaultQuotes);
      return defaultQuotes;
    }

    try {
      final List<dynamic> jsonList = jsonDecode(quotesString);
      return jsonList.map((json) => Quote.fromJson(json)).toList();
    } catch (e) {
      // If there's an error, load defaults
      return await _loadQuotesFromAssets();
    }
  }

  Future<List<Quote>> _loadQuotesFromAssets() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/quotes/quotes.json',
      );
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final List<dynamic> quotesJson = jsonData['quotes'];

      return quotesJson.map((json) {
        return Quote(
          text: json['quote'] ?? '',
          author: json['author'] ?? 'Unknown',
        );
      }).toList();
    } catch (e) {
      // Fallback to a single default quote if JSON loading fails
      return [
        Quote(
          text: "The only way to do great work is to love what you do.",
          author: "Steve Jobs",
        ),
      ];
    }
  }

  Future<void> saveQuotes(List<Quote> quotes) async {
    final prefs = await SharedPreferences.getInstance();
    final String quotesString = jsonEncode(
      quotes.map((q) => q.toJson()).toList(),
    );
    await prefs.setString(_quotesKey, quotesString);
  }

  Future<void> addQuote(Quote quote) async {
    final quotes = await getQuotes();
    quotes.add(quote);
    await saveQuotes(quotes);
  }

  // ==================== SAVED QUOTES ====================

  /// Get all saved quotes
  Future<List<Quote>> getSavedQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedQuotesString = prefs.getString(_savedQuotesKey);

    if (savedQuotesString == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(savedQuotesString);
      return jsonList.map((json) => Quote.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Save a quote to saved quotes
  Future<void> saveQuoteToFavorites(Quote quote) async {
    final savedQuotes = await getSavedQuotes();

    // Check if quote is already saved (using equality operator)
    if (!savedQuotes.contains(quote)) {
      savedQuotes.add(quote);
      await _saveSavedQuotes(savedQuotes);
    }
  }

  /// Remove a quote from saved quotes
  Future<void> removeQuoteFromFavorites(Quote quote) async {
    final savedQuotes = await getSavedQuotes();
    savedQuotes.removeWhere((q) => q.id == quote.id);
    await _saveSavedQuotes(savedQuotes);
  }

  /// Check if a quote is saved
  Future<bool> isQuoteSaved(Quote quote) async {
    final savedQuotes = await getSavedQuotes();
    return savedQuotes.any((q) => q.id == quote.id);
  }

  /// Save the list of saved quotes to SharedPreferences
  Future<void> _saveSavedQuotes(List<Quote> quotes) async {
    final prefs = await SharedPreferences.getInstance();
    final String quotesString = jsonEncode(
      quotes.map((q) => q.toJson()).toList(),
    );
    await prefs.setString(_savedQuotesKey, quotesString);
  }

  // ==================== LAST VIEWED QUOTE ====================

  static const String _lastViewedQuoteIdKey = 'last_viewed_quote_id';

  Future<String?> getLastViewedQuoteId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastViewedQuoteIdKey);
  }

  Future<void> saveLastViewedQuoteId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastViewedQuoteIdKey, id);
  }
}
