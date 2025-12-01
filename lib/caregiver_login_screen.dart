import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Caregiver login screen (standalone version).
class CaregiverLoginScreen extends StatefulWidget {
  const CaregiverLoginScreen({super.key});

  @override
  State<CaregiverLoginScreen> createState() => _CaregiverLoginScreenState();
}

class _CaregiverLoginScreenState extends State<CaregiverLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _useSingpass = false;

  @override
  void dispose() {
    _patientIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF4776E6),
              Color(0xFF8E54E9),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
            child: Container(
              constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 400),
              child: Card(
                elevation: 24,
                shadowColor: Colors.black.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.95),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 28.0 : 36.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.medical_services, size: 60, color: Color(0xFF2196F3)),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'NeuroLens',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                      ),
                      const SizedBox(height: 8),
                      const Text('Caregiver Dashboard', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 40),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _patientIdController,
                              decoration: const InputDecoration(
                                labelText: 'Patient ID',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) => value?.isEmpty == true ? 'Please enter patient ID' : null,
                              onFieldSubmitted: (_) => _handleLogin(),
                            ),
                            const SizedBox(height: 20),
                            if (!_useSingpass) ...[
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                obscureText: _obscurePassword,
                                validator: (value) => value?.isEmpty == true ? 'Please enter password' : null,
                                onFieldSubmitted: (_) => _handleLogin(),
                              ),
                              const SizedBox(height: 20),
                            ],
                            Row(
                              children: [
                                Checkbox(
                                  value: _useSingpass,
                                  onChanged: (value) => setState(() => _useSingpass = value ?? false),
                                ),
                                const Expanded(child: Text('Use Singpass for secure login')),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Consumer<AuthProvider>(
                              builder: (context, auth, child) {
                                return Column(
                                  children: [
                                    if (auth.errorMessage != null)
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.red.shade200),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.error, color: Colors.red.shade700),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                auth.errorMessage!,
                                                style: TextStyle(color: Colors.red.shade700),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    Container(
                                      width: double.infinity,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            const Color(0xFF2196F3),
                                            const Color(0xFF1976D2),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF2196F3).withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: auth.isLoading ? null : _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 0,
                                        ),
                                        child: auth.isLoading
                                            ? const CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              )
                                            : Text(
                                                _useSingpass ? 'Login with Singpass' : 'Login',
                                                style: const TextStyle(
                                                  fontSize: 16, 
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AuthProvider>();
      final success = await auth.login(
        _patientIdController.text.trim(),
        _passwordController.text,
        useSingpass: _useSingpass,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!'), backgroundColor: Colors.green),
        );
      }
    }
  }
}