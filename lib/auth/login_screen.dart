import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../components/text_field.dart';
import '../components/long_button.dart';
import '../services/connectivity_service.dart';
import '../widgets/offline_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _churchController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _churchController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Check internet connectivity before login attempt
      final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
      if (connectivityService.isOffline) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection. Please check your connection and try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Clear any previous errors
      final authProvider = context.read<AuthProvider>();
      authProvider.clearError();

      // Let AuthProvider handle all errors and loading state
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
        churchName: _churchController.text.trim().isEmpty
            ? null
            : _churchController.text.trim(),
      );

      // Navigation is handled by AppWrapper automatically
      // when AuthProvider status changes to authenticated
      // Errors are displayed via Consumer<AuthProvider> widget below
    }
  }

  void _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.forgotPassword(email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reset email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // If authenticated, pop this screen to let AppWrapper handle navigation
        if (authProvider.status == AuthStatus.authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Header
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to your account',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),

                    const SizedBox(height: 50),

                    // Church Location
                    CustomTextField(
                      hintText: 'Church Location',
                      prefixIcon: Icons.location_on_outlined,
                      controller: _churchController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter church location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Username
                    CustomTextField(
                      hintText: 'Username',
                      prefixIcon: Icons.person_outline,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password
                    CustomTextField(
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _handleForgotPassword,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Login Button
                    (authProvider.status == AuthStatus.authenticating)
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          )
                        : LongButton(text: 'LOGIN', onPressed: _handleLogin),

                    // Error Display
                    if (authProvider.error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[700],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                authProvider.error!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Sign up link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                '/register',
                              );
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
