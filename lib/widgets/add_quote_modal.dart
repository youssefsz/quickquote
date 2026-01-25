import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quote_provider.dart';
import '../theme/app_theme.dart';

class AddQuoteModal extends StatefulWidget {
  const AddQuoteModal({super.key});

  @override
  State<AddQuoteModal> createState() => _AddQuoteModalState();
}

class _AddQuoteModalState extends State<AddQuoteModal> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _authorController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final text = _textController.text.trim();
      final author = _authorController.text.trim().isEmpty
          ? 'Unknown'
          : _authorController.text.trim();

      context.read<QuoteProvider>().addQuote(text, author);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dark Mode Fix:
    // Modal Background: Dark Gray (Surface) instead of Black (Background)
    // Input Fill: Slightly lighter gray (Tertiary) instead of Surface
    final modalBackgroundColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightBackground;

    final inputFillColor = isDark
        ? const Color(0xFF2C2C2E) // Lighter than surface for contrast
        : AppColors.lightSurface;

    final hintTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 20,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: modalBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar for better UX
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Quote',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.xmark,
                      size: 20,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _textController,
              maxLines: 4,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Type something inspiring...',
                hintStyle: TextStyle(color: hintTextColor),
                filled: true,
                fillColor: inputFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a quote';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _authorController,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Author (Optional)',
                hintStyle: TextStyle(color: hintTextColor),
                filled: true,
                fillColor: inputFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                prefixIcon: Icon(
                  CupertinoIcons.person,
                  size: 20,
                  color: hintTextColor,
                ),
              ),
            ),
            const SizedBox(height: 32),
            CupertinoButton.filled(
              onPressed: _submit,
              borderRadius: BorderRadius.circular(20),
              child: const Text(
                'Add to Collection',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
