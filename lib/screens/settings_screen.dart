import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/review_service.dart';
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

  Future<void> _openStoreListing() async {
    final success = await ReviewService().openStoreListing();
    if (!success && mounted) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Unable to Open Store'),
          content: const Text(
            'Could not open the app store. Please try again later.',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24.0,
            16.0,
            24.0,
            100.0 + MediaQuery.paddingOf(context).bottom,
          ),
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

              // Preferences Section
              _buildSection(
                title: 'PREFERENCES',
                children: [
                  _buildTile(
                    icon: isDarkMode
                        ? CupertinoIcons.moon_fill
                        : CupertinoIcons.sun_max_fill,
                    title: 'Dark Mode',
                    subtitle: 'Change the app appearance',
                    trailing: CupertinoSwitch(
                      value: isDarkMode,
                      activeTrackColor: AppColors.darkAccent,
                      onChanged: (value) {
                        context.read<ThemeProvider>().toggleTheme();
                      },
                    ),
                  ),
                ],
              ),

              // Support Section
              _buildSection(
                title: 'SUPPORT & FEEDBACK',
                children: [
                  _buildTile(
                    icon: CupertinoIcons.chat_bubble_text_fill,
                    title: 'Support',
                    subtitle: 'Get help and contact us',
                    onTap: _launchSupportEmail,
                  ),
                  if (Platform.isIOS || Platform.isAndroid || Platform.isMacOS)
                    _buildTile(
                      icon: CupertinoIcons.star_fill,
                      title: 'Rate the App',
                      subtitle: 'Leave us a review on the store',
                      onTap: _openStoreListing,
                    ),
                ],
              ),

              // Legal Section
              _buildSection(
                title: 'LEGAL',
                children: [
                  _buildTile(
                    icon: CupertinoIcons.doc_text_fill,
                    title: 'Terms of Service',
                    subtitle: 'Read our terms and conditions',
                    onTap: _navigateToTermsOfService,
                  ),
                  _buildTile(
                    icon: CupertinoIcons.lock_shield_fill,
                    title: 'Privacy Policy',
                    subtitle: 'How we protect your privacy',
                    onTap: _navigateToPrivacyPolicy,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // App Info/Version
              // About Section
              _buildSection(
                title: 'ABOUT',
                children: [
                  _buildTile(
                    icon: CupertinoIcons.info_circle_fill,
                    title: 'Version',
                    trailing: _isLoadingVersion
                        ? const CupertinoActivityIndicator(radius: 8)
                        : Text(
                            '${_packageInfo?.version ?? "1.0.0"} (${_packageInfo?.buildNumber ?? "1"})',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : Colors.black.withValues(alpha: 0.5),
                              fontSize: 17,
                            ),
                          ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              letterSpacing: -0.08,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              final isLast = index == children.length - 1;

              return Column(
                children: [
                  child,
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.only(left: 54),
                      child: Divider(
                        height: 0.5,
                        thickness: 0.5,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon
              Icon(
                icon,
                size: 22,
                color: isDestructive
                    ? CupertinoColors.destructiveRed
                    : theme.iconTheme.color,
              ),
              const SizedBox(width: 16),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: isDestructive
                            ? CupertinoColors.destructiveRed
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Trailing
              if (trailing != null)
                trailing
              else
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
