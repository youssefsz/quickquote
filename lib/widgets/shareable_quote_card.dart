import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quote.dart';

/// A beautiful, shareable quote card widget designed specifically for image sharing.
///
/// This widget creates a visually stunning card with:
/// - Elegant typography
/// - App branding
/// - Optimized dimensions for social media sharing
/// - Theme-aware design
class ShareableQuoteCard extends StatelessWidget {
  final Quote quote;
  final bool isDarkMode;

  const ShareableQuoteCard({
    super.key,
    required this.quote,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // Define colors based on theme
    final backgroundColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1C1C1E);
    final secondaryTextColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF1C1C1E).withValues(alpha: 0.6);
    final accentColor = isDarkMode
        ? const Color(0xFF6C5CE7)
        : const Color(0xFF5B4FCF);
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quote icon at top
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.format_quote_rounded,
                size: 32,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 32),

            // Quote text
            Text(
              quote.text,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 24,
                height: 1.5,
                color: textColor,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 32),

            // Divider
            Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.3),
                    accentColor,
                    accentColor.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Author
            Text(
              '— ${quote.author}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: secondaryTextColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 40),

            // App branding
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: accentColor.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'QuickQuote',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: accentColor.withValues(alpha: 0.6),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
