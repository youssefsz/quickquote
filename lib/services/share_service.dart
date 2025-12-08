import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/quote.dart';
import '../widgets/shareable_quote_card.dart';

/// Service for sharing quotes with formatted text and beautiful images.
///
/// This service provides clean, maintainable methods for:
/// - Capturing quote widgets as high-quality images
/// - Sharing quotes with both text and image
/// - Proper cleanup of temporary files
class ShareService {
  /// Share a quote with a beautiful image and formatted text.
  ///
  /// This method creates a shareable image card, captures it as PNG,
  /// and shares it along with the quote text.
  Future<ShareResult> shareQuote(
    Quote quote, {
    required BuildContext context,
    Rect? sharePositionOrigin,
  }) async {
    // Determine if dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Capture the quote as an image using overlay method
    final imageFile = await _captureQuoteWithOverlay(
      context,
      quote,
      isDarkMode,
    );

    // Format the quote text
    final formattedText = _formatQuoteText(quote);

    // Get share position for iPad support
    final positionOrigin = sharePositionOrigin ?? _getSharePosition(context);

    try {
      // Create share parameters with image file
      final params = ShareParams(
        text: formattedText,
        title: 'Share Quote',
        subject: 'Quote by ${quote.author}',
        files: [XFile(imageFile.path)],
        sharePositionOrigin: positionOrigin,
      );

      final result = await SharePlus.instance.share(params);

      // Clean up temporary file after sharing
      await _cleanupTempFile(imageFile);

      return result;
    } catch (e) {
      // Clean up on error
      await _cleanupTempFile(imageFile);
      rethrow;
    }
  }

  /// Capture quote using overlay method.
  ///
  /// This approach temporarily adds a widget to an overlay,
  /// captures it, and then removes it. More reliable than
  /// pure offscreen rendering.
  Future<File> _captureQuoteWithOverlay(
    BuildContext context,
    Quote quote,
    bool isDarkMode,
  ) async {
    final repaintBoundaryKey = GlobalKey();

    // Create the overlay entry
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // Position off-screen to the left
        left: -1000,
        top: 0,
        child: RepaintBoundary(
          key: repaintBoundaryKey,
          child: ShareableQuoteCard(quote: quote, isDarkMode: isDarkMode),
        ),
      ),
    );

    // Insert overlay
    Overlay.of(context).insert(overlayEntry);

    // Wait for the widget to be rendered
    await Future.delayed(const Duration(milliseconds: 150));

    try {
      // Capture the image
      final boundary =
          repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Failed to find render boundary for quote capture');
      }

      // Capture with high pixel ratio for quality
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save to file
      final file = await _saveTempImage(pngBytes, quote);

      // Clean up
      image.dispose();
      overlayEntry.remove();

      return file;
    } catch (e) {
      overlayEntry.remove();
      rethrow;
    }
  }

  /// Save image bytes to a temporary file with unique name.
  Future<File> _saveTempImage(Uint8List bytes, Quote quote) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeAuthor = quote.author
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(' ', '_')
        .toLowerCase();
    final fileName = 'quickquote_${safeAuthor}_$timestamp.png';
    final file = File('${tempDir.path}/$fileName');

    await file.writeAsBytes(bytes);
    return file;
  }

  /// Clean up temporary image file.
  Future<void> _cleanupTempFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Silently fail cleanup - not critical
      debugPrint('Failed to cleanup temp file: $e');
    }
  }

  /// Get share position from render context for iPad support.
  Rect? _getSharePosition(BuildContext context) {
    try {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        return renderBox.localToGlobal(Offset.zero) & renderBox.size;
      }
    } catch (e) {
      // Silently fail - position is optional
    }
    return null;
  }

  /// Format quote text in an elegant, shareable format.
  String _formatQuoteText(Quote quote) {
    final buffer = StringBuffer();

    buffer.writeln('"${quote.text}"');
    buffer.writeln();
    buffer.write('— ${quote.author}');
    buffer.writeln();
    buffer.writeln();
    buffer.write('Shared via QuickQuote');

    return buffer.toString();
  }

  /// Share a quote with custom additional message.
  Future<ShareResult> shareQuoteWithMessage(
    Quote quote,
    String additionalMessage, {
    required BuildContext context,
    Rect? sharePositionOrigin,
  }) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final imageFile = await _captureQuoteWithOverlay(
      context,
      quote,
      isDarkMode,
    );

    final formattedText = _formatQuoteText(quote);
    final fullText = '$formattedText\n\n$additionalMessage';

    final positionOrigin = sharePositionOrigin ?? _getSharePosition(context);

    try {
      final params = ShareParams(
        text: fullText,
        title: 'Share Quote',
        subject: 'Quote by ${quote.author}',
        files: [XFile(imageFile.path)],
        sharePositionOrigin: positionOrigin,
      );

      final result = await SharePlus.instance.share(params);
      await _cleanupTempFile(imageFile);
      return result;
    } catch (e) {
      await _cleanupTempFile(imageFile);
      rethrow;
    }
  }

  /// Share just text without image (fallback method).
  Future<ShareResult> shareQuoteTextOnly(
    Quote quote, {
    BuildContext? context,
    Rect? sharePositionOrigin,
  }) async {
    final formattedText = _formatQuoteText(quote);

    final positionOrigin =
        sharePositionOrigin ??
        (context != null ? _getSharePosition(context) : null);

    final params = ShareParams(
      text: formattedText,
      title: 'Share Quote',
      subject: 'Quote by ${quote.author}',
      sharePositionOrigin: positionOrigin,
    );

    return await SharePlus.instance.share(params);
  }
}
