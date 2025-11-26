import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? _packageInfo;
  bool _isLoadingVersion = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = packageInfo;
        _isLoadingVersion = false;
      });
    }
  }

  Future<void> _launchSupportEmail() async {
    const String email = 'support@quickquote.app';
    const String subject = 'QuickQuote Support Request';
    const String body = 'Please describe your issue or question here...';

    // Create mailto URI with properly encoded query parameters
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters(<String, String>{
        'subject': subject,
        'body': body,
      }),
    );

    try {
      // Try to launch the email URL directly
      // For mailto links, platformDefault should work better than externalApplication
      final launched = await launchUrl(
        emailUri,
        mode: LaunchMode.platformDefault,
      );

      if (!launched && mounted) {
        // If launch failed, show error dialog
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Unable to Send Email'),
            content: const Text(
              'Please ensure you have an email app installed on your device.',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Handle any errors that occur during launch
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(
              'Could not launch email. Please ensure you have an email app installed.\n\nError: $e',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  void _navigateToPrivacyPolicy() {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => const PrivacyPolicyScreen()),
    );
  }

  void _navigateToTermsOfService() {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => const TermsOfServiceScreen()),
    );
  }

  Widget _buildSettingsButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        onPressed: onTap,
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor ?? theme.iconTheme.color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 20,
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Settings',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 32),

              // Theme Toggle
              Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Row(
                  children: [
                    Icon(
                      isDarkMode
                          ? CupertinoIcons.moon_fill
                          : CupertinoIcons.sun_max_fill,
                      size: 24,
                      color: theme.iconTheme.color,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appearance',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isDarkMode ? 'Dark Mode' : 'Light Mode',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    CupertinoSwitch(
                      value: isDarkMode,
                      activeTrackColor: AppColors.darkAccent,
                      onChanged: (value) {
                        context.read<ThemeProvider>().toggleTheme();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Support Section
              Text(
                'Support',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              _buildSettingsButton(
                icon: CupertinoIcons.chat_bubble_text,
                title: 'Support',
                subtitle: 'Get help and contact us',
                onTap: _launchSupportEmail,
                iconColor: AppColors.darkAccent,
              ),

              const SizedBox(height: 32),

              // Legal Section
              Text(
                'Legal',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              _buildSettingsButton(
                icon: CupertinoIcons.doc_text,
                title: 'Terms of Service',
                subtitle: 'Read our terms and conditions',
                onTap: _navigateToTermsOfService,
              ),

              _buildSettingsButton(
                icon: CupertinoIcons.lock_shield,
                title: 'Privacy Policy',
                subtitle: 'How we protect your privacy',
                onTap: _navigateToPrivacyPolicy,
              ),

              const SizedBox(height: 32),

              // App Info
              Center(
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.quote_bubble,
                      size: 48,
                      color: theme.iconTheme.color?.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'QuickQuote',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_isLoadingVersion)
                      const CupertinoActivityIndicator(radius: 8)
                    else
                      Text(
                        'Version ${_packageInfo?.version ?? "1.0.0"} (${_packageInfo?.buildNumber ?? "1"})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
