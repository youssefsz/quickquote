import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../services/share_service.dart';

/// A beautiful, Apple-style share button widget
///
/// Features:
/// - Smooth hover/tap animations
/// - Apple design aesthetics
/// - Proper iPad support with share position origin
/// - Visual feedback on interaction
class ShareQuoteButton extends StatefulWidget {
  final Quote quote;
  final ShareService shareService;
  final EdgeInsets? padding;
  final double? size;
  final Color? iconColor;
  final bool showLabel;

  ShareQuoteButton({
    super.key,
    required this.quote,
    ShareService? shareService,
    this.padding,
    this.size,
    this.iconColor,
    this.showLabel = false,
  }) : shareService = shareService ?? ShareService();

  @override
  State<ShareQuoteButton> createState() => _ShareQuoteButtonState();
}

class _ShareQuoteButtonState extends State<ShareQuoteButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleShare() async {
    // Get the position of this widget for iPad support
    final renderBox = context.findRenderObject() as RenderBox?;
    Rect? sharePositionOrigin;

    if (renderBox != null) {
      sharePositionOrigin =
          renderBox.localToGlobal(Offset.zero) & renderBox.size;
    }

    try {
      await widget.shareService.shareQuote(
        widget.quote,
        context: context,
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      // Handle error silently or show a toast
      if (mounted) {
        debugPrint('Error sharing quote: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final iconSize = widget.size ?? 24.0;
    final buttonPadding = widget.padding ?? const EdgeInsets.all(8.0);

    final defaultIconColor =
        widget.iconColor ??
        (isDarkMode
            ? theme.iconTheme.color?.withValues(alpha: 0.9)
            : theme.iconTheme.color?.withValues(alpha: 0.8));

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
        _handleShare();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: buttonPadding,
          decoration: BoxDecoration(
            color: _isPressed
                ? (isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: widget.showLabel
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.share,
                      size: iconSize,
                      color: defaultIconColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Share',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: defaultIconColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : Icon(
                  CupertinoIcons.share,
                  size: iconSize,
                  color: defaultIconColor,
                ),
        ),
      ),
    );
  }
}

/// A compact share button for use in action bars or lists
class CompactShareButton extends StatelessWidget {
  final Quote quote;
  final ShareService? shareService;
  final Color? iconColor;

  const CompactShareButton({
    super.key,
    required this.quote,
    this.shareService,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ShareQuoteButton(
      quote: quote,
      shareService: shareService,
      size: 22,
      padding: const EdgeInsets.all(10),
      iconColor: iconColor,
    );
  }
}

/// A prominent share button with label, perfect for detail screens
class ProminentShareButton extends StatelessWidget {
  final Quote quote;
  final ShareService? shareService;

  const ProminentShareButton({
    super.key,
    required this.quote,
    this.shareService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Builder(
      builder: (context) {
        return CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          borderRadius: BorderRadius.circular(14),
          color: theme.colorScheme.primary,
          onPressed: () async {
            final renderBox = context.findRenderObject() as RenderBox?;
            Rect? sharePositionOrigin;

            if (renderBox != null) {
              sharePositionOrigin =
                  renderBox.localToGlobal(Offset.zero) & renderBox.size;
            }

            final shareService = this.shareService ?? ShareService();
            await shareService.shareQuote(
              quote,
              context: context,
              sharePositionOrigin: sharePositionOrigin,
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.share, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Share Quote',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
