import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling in-app reviews and store listing operations.
///
/// This service manages:
/// - Tracking the number of saved quotes to trigger review prompts
/// - Requesting native in-app reviews (with quota awareness)
/// - Opening store listings for direct review access
class ReviewService {
  static const String _savedQuotesCountKey = 'total_saved_quotes_count';
  static const String _hasRequestedReviewKey = 'has_requested_review';
  static const int _reviewTriggerThreshold = 3;

  // App Store ID for iOS
  static const String _appStoreId = '6755724502';

  final InAppReview _inAppReview = InAppReview.instance;

  /// Singleton instance
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  /// Increments the saved quotes count and triggers review if threshold is reached.
  ///
  /// Call this method every time a quote is saved (swipe right).
  /// The in-app review will only be requested once, after the 3rd saved quote.
  Future<void> onQuoteSaved() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we've already requested a review
    final hasRequestedReview = prefs.getBool(_hasRequestedReviewKey) ?? false;
    if (hasRequestedReview) {
      return; // Already requested, don't track or request again
    }

    // Increment the saved quotes count
    final currentCount = prefs.getInt(_savedQuotesCountKey) ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt(_savedQuotesCountKey, newCount);

    debugPrint('ReviewService: Quote saved. Total count: $newCount');

    // Check if we've reached the threshold
    if (newCount == _reviewTriggerThreshold) {
      await _requestInAppReview();
      // Mark that we've requested a review (only do this once)
      await prefs.setBool(_hasRequestedReviewKey, true);
    }
  }

  /// Requests the native in-app review dialog.
  ///
  /// Note: The actual display of the review dialog is controlled by the
  /// platform (iOS/Android) and may not always appear due to quota limits.
  Future<void> _requestInAppReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        debugPrint('ReviewService: Requesting in-app review...');
        await _inAppReview.requestReview();
        debugPrint('ReviewService: In-app review requested successfully');
      } else {
        debugPrint('ReviewService: In-app review not available');
      }
    } catch (e) {
      debugPrint('ReviewService: Error requesting in-app review: $e');
    }
  }

  /// Opens the app's store listing for users to leave a review.
  ///
  /// This is reliable and not subject to quotas, making it suitable
  /// for a "Rate the App" button in settings.
  Future<bool> openStoreListing() async {
    try {
      debugPrint('ReviewService: Opening store listing...');
      await _inAppReview.openStoreListing(appStoreId: _appStoreId);
      debugPrint('ReviewService: Store listing opened successfully');
      return true;
    } catch (e) {
      debugPrint('ReviewService: Error opening store listing: $e');
      return false;
    }
  }

  /// Checks if the current platform supports store listings.
  bool get isStoreListingSupported {
    // openStoreListing() works on Android, iOS, macOS, and Windows
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  /// Resets the review tracking (useful for testing).
  @visibleForTesting
  Future<void> resetReviewTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedQuotesCountKey);
    await prefs.remove(_hasRequestedReviewKey);
    debugPrint('ReviewService: Review tracking reset');
  }

  /// Gets the current saved quotes count (useful for debugging).
  Future<int> getSavedQuotesCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_savedQuotesCountKey) ?? 0;
  }

  /// Checks if a review has already been requested.
  Future<bool> hasRequestedReview() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasRequestedReviewKey) ?? false;
  }
}
