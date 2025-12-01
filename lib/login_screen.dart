import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

/// Login screen for patient/caregiver authentication.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.isDarkMode
                ? [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF2D2D2D),
                    const Color(0xFF404040),
                  ]
                : [
                    const Color(0xFF667eea),
                    const Color(0xFF764ba2),
                    const Color(0xFF89BFFF),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: theme.toggleTheme,
                      icon: Icon(
                        theme.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      width: isMobile ? double.infinity : 450,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(isMobile),
                            const SizedBox(height: 32),
                            _buildLoginForm(),
                            const SizedBox(height: 24),
                            _buildLoginButton(),
                            const SizedBox(height: 20),
                            _buildDivider(),
                            const SizedBox(height: 20),
                            _buildSingPassButton(),
                            const SizedBox(height: 24),
                            _buildTestCredentials(isMobile),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.psychology,
            size: isMobile ? 40 : 48,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 20),
        Text(
          'NeuroLens',
          style: TextStyle(
            fontSize: isMobile ? 32 : 36,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineLarge?.color,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 12),
        Text(
          'Advanced Cognitive Assessment Platform',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _patientIdController,
            decoration: InputDecoration(
              labelText: 'Patient ID',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Please enter patient ID';
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: _hidePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Please enter password';
              return null;
            },
            onFieldSubmitted: (_) => _handleLogin(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(auth.errorMessage!),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
            auth.clearError();
          });
        }

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: auth.isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: auth.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildSingPassButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: auth.isLoading ? null : _handleSingPassLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE31837),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.verified_user, size: 24),
            label: const Text(
              'Login with SingPass',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTestCredentials(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Text(
            'Test Credentials',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Patient ID: P001\nPassword: password\nRole: caregiver',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.blue.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      await context.read<AuthProvider>().login(
        _patientIdController.text.trim(),
        _passwordController.text,
        'caregiver',
      );
    }
  }

  void _handleSingPassLogin() async {
    await context.read<AuthProvider>().singpassLogin();
  }
}