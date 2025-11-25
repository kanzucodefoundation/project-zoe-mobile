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
  late GlobalKey<FormState> _formKey;

  // Controllers for all fields - nullable for safe disposal
  TextEditingController? _emailController;
  TextEditingController? _passwordController;
  TextEditingController? _confirmPasswordController;
  TextEditingController? _firstNameController;
  TextEditingController? _lastNameController;
  TextEditingController? _phoneController;
  TextEditingController? _workPlaceController;
  TextEditingController? _churchController;

  // Additional fields for API
  TextEditingController? _dateOfBirthController;
  String? selectedGender;
  String? selectedCivilStatus;

  // Gender options
  final List<String> genders = ['Male', 'Female', 'Other'];

  // Civil status options
  final List<String> civilStatuses = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
  ];

  // Church location text field

  // Add cancellation tracking
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _workPlaceController = TextEditingController();
    _churchController = TextEditingController();
    _dateOfBirthController = TextEditingController();
  }

  @override
  void dispose() {
    _isDisposed = true;
    try {
      _emailController?.dispose();
      _passwordController?.dispose();
      _confirmPasswordController?.dispose();
      _firstNameController?.dispose();
      _lastNameController?.dispose();
      _phoneController?.dispose();
      _workPlaceController?.dispose();
      _churchController?.dispose();
      _dateOfBirthController?.dispose();
    } catch (e) {
      // Controllers might already be disposed, ignore errors
      debugPrint('Controller disposal error (safe to ignore): $e');
    }
    // Set controllers to null to prevent further access
    _emailController = null;
    _passwordController = null;
    _confirmPasswordController = null;
    _firstNameController = null;
    _lastNameController = null;
    _phoneController = null;
    _workPlaceController = null;
    _churchController = null;
    _dateOfBirthController = null;
    super.dispose();
  }

  void _handleAuth() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      try {
        if (isLogin) {
          // Capture values before async operation to avoid disposal issues
          final email = _emailController?.text.trim() ?? '';
          final password = _passwordController?.text ?? '';
          final churchName = _churchController?.text.trim() ?? 'demo';

          if (_isDisposed || !mounted || email.isEmpty || password.isEmpty)
            return;

          // Login with church name from dropdown
          await authProvider.login(email, password, churchName: churchName);

          if (_isDisposed || !mounted || !context.mounted) return;

          // Check if login was successful and widget is still mounted
          if (authProvider.status == AuthStatus.authenticated &&
              context.mounted) {
            // Login successful - Close the bottom sheet
            if (!_isDisposed && mounted) {
              Navigator.pop(context);
            }
            // AppWrapper will automatically navigate to MainScaffold
          } else if (authProvider.error != null && context.mounted) {
            // Login failed - Show error message and keep bottom sheet open
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authProvider.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // Capture values before async operation to avoid disposal issues
          final firstName = _firstNameController?.text.trim() ?? '';
          final lastName = _lastNameController?.text.trim() ?? '';
          final email = _emailController?.text.trim() ?? '';
          final phone = _phoneController?.text.trim() ?? '';
          final gender = selectedGender ?? 'Other';
          final civilStatus = selectedCivilStatus ?? 'Single';
          final dateOfBirth = _dateOfBirthController?.text.trim() ?? '';
          final churchName = _churchController?.text.trim() ?? 'demo';

          if (_isDisposed || !mounted || email.isEmpty) return;
          await authProvider.signup(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            gender: gender,
            civilStatus: civilStatus,
            dateOfBirth: dateOfBirth,
            churchName: churchName,
          );

          if (_isDisposed || !mounted || !context.mounted) return;

          // Show success message and switch to login
          if (mounted && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful! Please log in.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            if (!_isDisposed && mounted) {
              setState(() {
                isLogin = true;
              });
            }
          }
        }
      } catch (e) {
        if (!_isDisposed && mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _handleForgotPassword() async {
    if (_isDisposed || !mounted) return;

    // Capture email value before async operation
    final email = _emailController?.text.trim() ?? '';

    if (_isDisposed || !mounted || email.isEmpty) return;

    if (email.isEmpty) {
      if (!_isDisposed && mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your email first'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      if (_isDisposed || !mounted) return;

      final authProvider = context.read<AuthProvider>();
      await authProvider.forgotPassword(email);

      if (!_isDisposed && mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!_isDisposed && mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reset email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    if (_isDisposed || !mounted) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 18 * 365)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );

    if (picked != null && !_isDisposed && mounted) {
      setState(() {
        _dateOfBirthController?.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _resetFormKey() {
    _formKey = GlobalKey<FormState>();
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
                      _resetFormKey();
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
                      _resetFormKey();
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLogin ? 'LOG IN' : 'SIGN UP',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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
                      // Authentication state is handled by AppWrapper, no need for manual navigation
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

                              // Church Location (first for login)
                              if (isLogin) ...[
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

                                // Gender Dropdown
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
                                    initialValue: selectedGender,
                                    decoration: const InputDecoration(
                                      hintText: 'Gender',
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                        color: Colors.grey,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                    dropdownColor: Colors.white,
                                    items: genders.map((gender) {
                                      return DropdownMenuItem(
                                        value: gender,
                                        child: Text(
                                          gender,
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedGender = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select your gender';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Civil Status Dropdown
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
                                    initialValue: selectedCivilStatus,
                                    decoration: const InputDecoration(
                                      hintText: 'Civil Status',
                                      prefixIcon: Icon(
                                        Icons.favorite_outline,
                                        color: Colors.grey,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                    dropdownColor: Colors.white,
                                    items: civilStatuses.map((status) {
                                      return DropdownMenuItem(
                                        value: status,
                                        child: Text(
                                          status,
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCivilStatus = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select your civil status';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Date of Birth
                                GestureDetector(
                                  onTap: _selectDate,
                                  child: AbsorbPointer(
                                    child: CustomTextField(
                                      hintText: 'Date of Birth',
                                      prefixIcon: Icons.calendar_today_outlined,
                                      controller: _dateOfBirthController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select your date of birth';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
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
                                    if (value !=
                                        (_passwordController?.text ?? '')) {
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
                                      _handleForgotPassword();
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
