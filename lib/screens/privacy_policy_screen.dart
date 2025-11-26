import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Icon(
                      CupertinoIcons.back,
                      color: theme.iconTheme.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Privacy Policy',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Updated: January 2025',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildSection(
                      context,
                      '1. Introduction',
                      'Welcome to QuickQuote. We respect your privacy and are committed to protecting your personal data. This privacy policy explains how we collect, use, and safeguard information when you use our app.',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '2. Information We Collect',
                      'QuickQuote is designed with privacy in mind. We collect minimal information:\n\n'
                      '• Quotes and Content: Quotes you add or save are stored locally on your device using device storage.\n\n'
                      '• Preferences: Theme preferences (light/dark mode) are stored locally on your device.\n\n'
                      '• App Usage: We do not track your usage patterns, browsing history, or personal information.',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '3. Local Storage',
                      'All data in QuickQuote is stored locally on your device:\n\n'
                      '• Saved quotes are stored using local device storage (SharedPreferences)\n\n'
                      '• Your quotes, preferences, and settings never leave your device\n\n'
                      '• We do not use cloud storage or sync your data to external servers',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '4. Data Collection and Sharing',
                      'We do not:\n\n'
                      '• Collect personal information\n\n'
                      '• Share data with third parties\n\n'
                      '• Use analytics or tracking services\n\n'
                      '• Access your contacts, photos, or other personal data\n\n'
                      '• Use cookies or similar tracking technologies',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '5. Permissions',
                      'QuickQuote may request the following permissions:\n\n'
                      '• Storage Permission: Only used to store your saved quotes and preferences locally on your device. This data remains on your device and is never transmitted.\n\n'
                      'We do not require internet access or network permissions for core functionality.',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '6. Children\'s Privacy',
                      'QuickQuote is suitable for users of all ages. We do not knowingly collect personal information from children. Since we do not collect any personal information, children can safely use our app.',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '7. Data Security',
                      'All data stored by QuickQuote remains on your device and is protected by your device\'s built-in security features. We recommend keeping your device\'s operating system updated to ensure the best security.',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '8. Changes to This Policy',
                      'We may update this Privacy Policy from time to time. Any changes will be reflected in the app with an updated "Last Updated" date. We encourage you to review this policy periodically.',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '9. Your Rights',
                      'Since all data is stored locally on your device, you have full control:\n\n'
                      '• You can delete saved quotes at any time\n\n'
                      '• You can clear all app data through your device settings\n\n'
                      '• You can uninstall the app at any time, which will remove all locally stored data',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '10. Contact Us',
                      'If you have questions about this Privacy Policy, please contact us through the Support option in the app settings.',
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.6,
            color: isDarkMode
                ? AppColors.darkTextPrimary.withValues(alpha: 0.9)
                : AppColors.lightTextPrimary.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

