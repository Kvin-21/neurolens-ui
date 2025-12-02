import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/cognitive_data_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() => runApp(const NeuroLensApp());

/// Root widget for the NeuroLens caregiver dashboard.
class NeuroLensApp extends StatelessWidget {
  const NeuroLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CognitiveDataProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'NeuroLens',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            home: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return auth.isAuthenticated
                    ? const DashboardScreen()
                    : const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}