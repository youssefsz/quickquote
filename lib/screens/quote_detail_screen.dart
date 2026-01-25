import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quote.dart';
import '../widgets/share_quote_button.dart';

class QuoteDetailScreen extends StatelessWidget {
  final Quote quote;

  const QuoteDetailScreen({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(color: theme.scaffoldBackgroundColor),
          ),

          // Main Center Content
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    24,
                    MediaQuery.of(context).padding.top + 24,
                    24,
                    40,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight -
                          (MediaQuery.of(context).padding.top + 64),
                    ),
                    child: Center(
                      child: Hero(
                        tag: 'quote_card_${quote.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 40,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Close Button - Inside the card
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            theme.brightness == Brightness.dark
                                            ? Colors.white.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.05,
                                              ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        CupertinoIcons.xmark,
                                        size: 18,
                                        color: theme.iconTheme.color
                                            ?.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ),
                                ),
                                // Content
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    32,
                                    56,
                                    32,
                                    32,
                                  ),
                                  child: SingleChildScrollView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.format_quote_rounded,
                                          size: 60,
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.5),
                                        ),
                                        const SizedBox(height: 32),
                                        Text(
                                          quote.text,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.dmSerifDisplay(
                                            fontSize: 28,
                                            height: 1.4,
                                            color: theme
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                        const SizedBox(height: 32),
                                        Text(
                                          '— ${quote.author}',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color
                                                    ?.withValues(alpha: 0.6),
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.5,
                                                decoration: TextDecoration.none,
                                              ),
                                        ),
                                        const SizedBox(height: 48),
                                        ProminentShareButton(quote: quote),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
