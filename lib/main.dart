import 'package:circular_theme_reveal/circular_theme_reveal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/quote_provider.dart';
import 'providers/saved_quotes_provider.dart';
import 'screens/main_navigation.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => QuoteProvider()),
        ChangeNotifierProvider(create: (_) => SavedQuotesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Add lifecycle observer to handle app resume events
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove lifecycle observer to prevent memory leaks
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When the app is resumed from inactive/paused state, force a rebuild
    // This ensures the UI is properly re-rendered and prevents layout chaos
    if (state == AppLifecycleState.resumed) {
      // Force a rebuild by calling setState
      if (mounted) {
        setState(() {
          // This empty setState will trigger a rebuild of the widget tree
          // ensuring all layouts are recalculated properly
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'QuickQuote',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          themeAnimationDuration: Duration.zero,
          builder: (context, child) {
            return CircularThemeRevealOverlay(
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const MainNavigation(),
        );
      },
    );
  }
}
