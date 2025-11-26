import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
                    'Terms of Service',
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
                      '1. Agreement to Terms',
                      'By downloading, installing, or using QuickQuote ("the App"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '2. Description of Service',
                      'QuickQuote is a mobile application that allows users to:\n\n'
                      '• Browse and view inspirational quotes\n\n'
                      '• Save favorite quotes to a personal collection\n\n'
                      '• Add custom quotes\n\n'
                      '• Switch between light and dark themes\n\n'
                      'All functionality operates entirely on your device without requiring an internet connection.',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '3. User Content',
                      'You may add custom quotes to the App:\n\n'
                      '• You retain ownership of any quotes you create\n\n'
                      '• You are responsible for ensuring your content does not violate any laws or infringe on others\' rights\n\n'
                      '• You agree not to post offensive, harmful, or inappropriate content\n\n'
                      '• All content is stored locally on your device and is not shared or distributed by us',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '4. Acceptable Use',
                      'You agree to use QuickQuote only for lawful purposes. You agree not to:\n\n'
                      '• Use the App in any way that violates applicable laws\n\n'
                      '• Attempt to reverse engineer, decompile, or disassemble the App\n\n'
                      '• Interfere with or disrupt the App\'s functionality\n\n'
                      '• Use automated systems to access the App',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '5. Intellectual Property',
                      'The QuickQuote app, including its design, features, and functionality, is the property of its developers. The quotes displayed in the App are provided for personal, non-commercial use only. Some quotes may be subject to copyright protection by their original authors.',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '6. Data Storage and Privacy',
                      '• All data (saved quotes, preferences) is stored locally on your device\n\n'
                      '• We do not collect, transmit, or store your personal information\n\n'
                      '• You are responsible for backing up your data if desired\n\n'
                      '• Uninstalling the app will delete all locally stored data',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '7. Disclaimer of Warranties',
                      'QuickQuote is provided "as is" and "as available" without warranties of any kind, either express or implied. We do not warrant that:\n\n'
                      '• The App will meet your specific requirements\n\n'
                      '• The App will be uninterrupted, secure, or error-free\n\n'
                      '• Any defects will be corrected',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '8. Limitation of Liability',
                      'To the fullest extent permitted by law, we shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use or inability to use QuickQuote.',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '9. Changes to Terms',
                      'We reserve the right to modify these Terms of Service at any time. Changes will be effective immediately upon posting in the App. Your continued use of the App after changes are posted constitutes acceptance of the modified terms.',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '10. Termination',
                      'We reserve the right to terminate or suspend your access to the App at any time, without prior notice, for any violation of these Terms of Service.',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '11. Governing Law',
                      'These Terms of Service shall be governed by and construed in accordance with applicable laws, without regard to its conflict of law provisions.',
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      context,
                      '12. Contact Information',
                      'If you have any questions about these Terms of Service, please contact us through the Support option in the app settings.',
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

