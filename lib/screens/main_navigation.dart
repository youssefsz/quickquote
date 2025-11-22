import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/exit_dialog.dart';
import 'home_screen.dart';
import 'saved_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  // Create static keys to ensure screens maintain their state
  static final GlobalKey<NavigatorState> _homeKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _savedKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _settingsKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    // Use Theme.of(context) to inherit MaterialApp's theme animation
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final shouldExit = await ExitDialog.show(context);
        if (shouldExit == true && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: CupertinoTabScaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
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
        ),
        tabBuilder: (context, index) {
          // Use CupertinoTabView with unique keys for each tab to prevent layout chaos
          switch (index) {
            case 0:
              return CupertinoTabView(
                key: _homeKey,
                builder: (context) => const HomeScreen(),
              );
            case 1:
              return CupertinoTabView(
                key: _savedKey,
                builder: (context) => const SavedScreen(),
              );
            case 2:
              return CupertinoTabView(
                key: _settingsKey,
                builder: (context) => const SettingsScreen(),
              );
            default:
              return CupertinoTabView(
                key: _homeKey,
                builder: (context) => const HomeScreen(),
              );
          }
        },
      ),
    );
  }
}
