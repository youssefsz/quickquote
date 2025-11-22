import 'package:circular_theme_reveal/circular_theme_reveal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QuickQuote',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your daily dose of inspiration',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation Items
              _DrawerItem(
                icon: CupertinoIcons.home,
                title: 'Home',
                isSelected: true, // Will be dynamic based on current page
                onTap: () {
                  // TODO: Navigate to home
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _DrawerItem(
                icon: CupertinoIcons.heart_fill,
                title: 'Saved',
                isSelected: false,
                onTap: () {
                  // TODO: Navigate to saved page
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _DrawerItem(
                icon: CupertinoIcons.settings,
                title: 'Settings',
                isSelected: false,
                onTap: () {
                  // TODO: Navigate to settings page
                  Navigator.pop(context);
                },
              ),

              const Spacer(),

              // Theme Toggle at Bottom
              Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    Icon(
                      isDarkMode
                          ? CupertinoIcons.moon_fill
                          : CupertinoIcons.sun_max_fill,
                      size: 20,
                      color: theme.iconTheme.color,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isDarkMode ? 'Dark Mode' : 'Light Mode',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Builder(
                      builder: (context) {
                        return CupertinoSwitch(
                          value: isDarkMode,
                          activeColor: AppColors.darkAccent,
                          onChanged: (value) async {
                            final overlay = CircularThemeRevealOverlay.of(
                              context,
                            );
                            final center =
                                CircularThemeRevealOverlay.getCenterFromContext(
                                  context,
                                );

                            if (overlay != null) {
                              await overlay.startTransition(
                                center: center,
                                reverse: false,
                                onThemeChange: () {
                                  context.read<ThemeProvider>().toggleTheme();
                                },
                              );
                            } else {
                              context.read<ThemeProvider>().toggleTheme();
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // App Version
              Center(
                child: Text(
                  'Version 1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? (isDarkMode
                      ? AppColors.darkAccent.withOpacity(0.15)
                      : AppColors.lightAccent.withOpacity(0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(
                    color: isDarkMode
                        ? AppColors.darkAccent.withOpacity(0.3)
                        : AppColors.lightAccent.withOpacity(0.2),
                    width: 1,
                  )
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? (isDarkMode
                          ? AppColors.darkAccent
                          : AppColors.lightAccent)
                    : theme.iconTheme.color,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? (isDarkMode
                            ? AppColors.darkAccent
                            : AppColors.lightAccent)
                      : theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
