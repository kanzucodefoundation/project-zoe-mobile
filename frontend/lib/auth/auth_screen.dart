import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../components/custom_button.dart';
import '../components/custom_text_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();

  // Controllers for all fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _workPlaceController = TextEditingController();

  // Church location dropdown
  String? selectedChurchLocation;
  final List<String> churchLocations = [
    'WH Naalya',
    'WH Kisaasi',
    'WH Busega',
    'WH Gayaza',
    'WH Downtown',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _workPlaceController.dispose();
    super.dispose();
  }

  void _handleAuth() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      if (isLogin) {
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        // For signup, you can extend this with all the collected data
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            // Using your background_image.jpg from assets
            image: AssetImage('assets/images/background_image.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (isLogin)
                _buildLoginScreen(size)
              else
                _buildSignUpScreen(size),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginScreen(Size size) {
    return Expanded(
      child: Column(
        children: [
          // Top section with branding
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                // Main logo/title
                const Text(
                  'PROJECT ZOE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 80),
                const Text(
                  "Don't wait.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get lost experience now!',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),

          // Bottom section with buttons
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Login button
                  CustomButton(
                    text: 'Log in',
                    onPressed: () {
                      setState(() {
                        isLogin = true;
                      });
                      _showAuthBottomSheet();
                    },
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    borderRadius: 25,
                  ),

                  const SizedBox(height: 16),

                  // Sign up button
                  CustomButton(
                    text: "Don't have an Account? Sign Up",
                    onPressed: () {
                      setState(() {
                        isLogin = false;
                      });
                      _showAuthBottomSheet();
                    },
                    isOutlined: true,
                    textColor: Colors.white,
                    borderRadius: 25,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpScreen(Size size) {
    return _buildLoginScreen(size); // For now, same as login until bottom sheet
  }

  void _showAuthBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    Text(
                      isLogin ? 'LOG IN' : 'SIGN UP',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
              ),

              // Project Zoe branding
              const Text(
                'PROJECT ZOE',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                isLogin ? 'Welcome back!' : 'Create your own itinerary!',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              // Form
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              if (!isLogin) ...[
                                // First Name
                                CustomTextField(
                                  hintText: 'First Name',
                                  prefixIcon: Icons.person_outline,
                                  controller: _firstNameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your first name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Last Name
                                CustomTextField(
                                  hintText: 'Last Name',
                                  prefixIcon: Icons.person_outline,
                                  controller: _lastNameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your last name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Email/Username
                              CustomTextField(
                                hintText: isLogin ? 'Username' : 'Email',
                                prefixIcon: Icons.person_outline,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your ${isLogin ? 'username' : 'email'}';
                                  }
                                  if (!isLogin && !value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              if (!isLogin) ...[
                                // Phone Number
                                CustomTextField(
                                  hintText: 'Phone Number',
                                  prefixIcon: Icons.phone_outlined,
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your phone number';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Church Location Dropdown
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    initialValue: selectedChurchLocation,
                                    decoration: const InputDecoration(
                                      hintText: 'Church Location',
                                      prefixIcon: Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.grey,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                    dropdownColor: Colors.white,
                                    items: churchLocations.map((location) {
                                      return DropdownMenuItem(
                                        value: location,
                                        child: Text(
                                          location,
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedChurchLocation = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a church location';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Place of Work
                                CustomTextField(
                                  hintText: 'Place of Work',
                                  prefixIcon: Icons.work_outline,
                                  controller: _workPlaceController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your place of work';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],

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
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),

                              if (!isLogin) ...[
                                const SizedBox(height: 16),
                                // Confirm Password
                                CustomTextField(
                                  hintText: 'Confirm Password',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: true,
                                  controller: _confirmPasswordController,
                                  validator: (value) {
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                              ],

                              if (isLogin) ...[
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // Handle forgot password
                                    },
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 24),

                              // Submit button
                              if (authProvider.status ==
                                  AuthStatus.authenticating)
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                  ),
                                )
                              else
                                CustomButton(
                                  text: isLogin ? 'LOG IN' : 'SIGN UP',
                                  onPressed: _handleAuth,
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  borderRadius: 25,
                                ),

                              if (authProvider.error != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    authProvider.error!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 24),

                              // OR divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(color: Colors.grey[300]),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'or',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(color: Colors.grey[300]),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Google sign in
                              Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'G',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'oogle',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      );
                    },
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
