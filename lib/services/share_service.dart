import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import '../models/quote.dart';

/// Service for sharing quotes with formatted text
class ShareService {
  /// Share a quote with beautiful formatting
  /// 
  /// Formats the quote in an elegant way that works well across all platforms.
  /// Uses the native share dialog with proper formatting.
  Future<ShareResult> shareQuote(
    Quote quote, {
    BuildContext? context,
    Rect? sharePositionOrigin,
  }) async {
    // Format the quote beautifully with em dashes and quotation marks
    final formattedText = _formatQuoteText(quote);

    // Get the share position origin if context is provided and on iPad
    Rect? positionOrigin = sharePositionOrigin;
    if (context != null && positionOrigin == null) {
      try {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          positionOrigin = renderBox.localToGlobal(Offset.zero) & renderBox.size;
        }
      } catch (e) {
        // If we can't get the position, continue without it
        // This won't crash the app, just won't have optimal iPad positioning
      }
    }

    final params = ShareParams(
      text: formattedText,
      title: 'Share Quote',
      subject: 'Quote by ${quote.author}',
      sharePositionOrigin: positionOrigin,
    );

    return await SharePlus.instance.share(params);
  }

  /// Format quote text in an elegant, shareable format
  String _formatQuoteText(Quote quote) {
    // Create a beautifully formatted quote text
    // Uses em dashes and proper quotation marks for elegance
    final buffer = StringBuffer();
    
    buffer.writeln('"${quote.text}"');
    buffer.writeln();
    buffer.write('— ${quote.author}');
    buffer.writeln();
    buffer.writeln();
    buffer.write('Shared via QuickQuote');

    return buffer.toString();
  }

  /// Share a quote with custom text (for additional context)
  Future<ShareResult> shareQuoteWithMessage(
    Quote quote,
    String additionalMessage, {
    BuildContext? context,
    Rect? sharePositionOrigin,
  }) async {
    final formattedText = _formatQuoteText(quote);
    final fullText = '$formattedText\n\n$additionalMessage';

    Rect? positionOrigin = sharePositionOrigin;
    if (context != null && positionOrigin == null) {
      try {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          positionOrigin = renderBox.localToGlobal(Offset.zero) & renderBox.size;
        }
      } catch (e) {
        // Continue without position
      }
    }

    final params = ShareParams(
      text: fullText,
      title: 'Share Quote',
      subject: 'Quote by ${quote.author}',
      sharePositionOrigin: positionOrigin,
    );

    return await SharePlus.instance.share(params);
  }
}

