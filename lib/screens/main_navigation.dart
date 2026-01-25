import 'dart:io';

import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/exit_dialog.dart';
import 'home_screen.dart';
import 'saved_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Check if we're on Apple platform (iOS or macOS)
  bool get _isApplePlatform => Platform.isIOS || Platform.isMacOS;

  Widget _buildCurrentScreen() {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await ExitDialog.show(context);
        if (shouldExit == true && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: IndexedStack(
        index: _currentIndex,
        children: const [HomeScreen(), SavedScreen(), SettingsScreen()],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    // Check for iPad or large screens to adjust layout
    // Using shortestSide > 600 is a standard way to detect tablets
    final isIpad = MediaQuery.of(context).size.shortestSide > 600;

    // Use native Liquid Glass CNTabBar on Apple platforms
    if (_isApplePlatform) {
      return Scaffold(
        body: Stack(
          children: [
            // Main content
            _buildCurrentScreen(),
            // Native Liquid Glass Tab Bar at the bottom
            Positioned(
              left: 0,
              right: 0,
              // Add extra bottom padding on iPad for a better floating look
              // Compensate for the scale growing downwards
              bottom: MediaQuery.of(context).padding.bottom + (isIpad ? 40 : 0),
              child: Center(
                child: Transform.scale(
                  // Scale up on iPad to make it readable and touch-friendly
                  // This is the best fix to keep the specific 'Liquid Glass' design but make it usable
                  scale: isIpad ? 1.5 : 1.0,
                  child: ConstrainedBox(
                    // Constrain width on iPad so it doesn't stretch too wide
                    // Adjusted for the scale factor (visual width ≈ 525)
                    constraints: BoxConstraints(
                      maxWidth: isIpad ? 400 : double.infinity,
                    ),
                    child: CNTabBar(
                      items: const [
                        CNTabBarItem(
                          label: 'Home',
                          icon: CNSymbol('house.fill'),
                        ),
                        CNTabBarItem(
                          label: 'Saved',
                          icon: CNSymbol('heart.fill'),
                        ),
                        CNTabBarItem(
                          label: 'Settings',
                          icon: CNSymbol('gearshape.fill'),
                        ),
                      ],
                      currentIndex: _currentIndex,
                      onTap: (index) => setState(() => _currentIndex = index),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Fallback to standard Cupertino tab navigation for other platforms
    return CupertinoTabScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      tabBar: CupertinoTabBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        activeColor: Theme.of(context).colorScheme.primary,
        inactiveColor: isDarkMode
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
        iconSize: 26,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            activeIcon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart),
            activeIcon: Icon(CupertinoIcons.heart_fill),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            activeIcon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
      tabBuilder: (context, index) {
        return _buildCurrentScreen();
      },
    );
  }
}
