import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

/// Demo screen showcasing all Project Zoe design system components
/// Use this to verify the design system is working correctly
class DesignSystemDemo extends StatefulWidget {
  const DesignSystemDemo({super.key});

  @override
  State<DesignSystemDemo> createState() => _DesignSystemDemoState();
}

class _DesignSystemDemoState extends State<DesignSystemDemo> {
  final TextEditingController _searchController = TextEditingController();
  String _searchValue = '';
  String? _dropdownValue = 'Option 1';
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Design System Demo', style: AppTextStyles.h3),
        backgroundColor: AppColors.scaffoldBackground,
      ),
      backgroundColor: AppColors.scaffoldBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Typography Section
            _buildSection(
              'Typography',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Display Text', style: AppTextStyles.display),
                  const SizedBox(height: AppSpacing.sm),
                  Text('H1 Heading', style: AppTextStyles.h1),
                  const SizedBox(height: AppSpacing.sm),
                  Text('H2 Heading', style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.sm),
                  Text('H3 Heading', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Body Large Text', style: AppTextStyles.bodyLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Body Text', style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Label Text', style: AppTextStyles.label),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Caption Text', style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Small Text', style: AppTextStyles.small),
                  const SizedBox(height: AppSpacing.sm),
                  Text('2', style: AppTextStyles.statsNumber),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Salvations This Week', style: AppTextStyles.sacredMomentText),
                ],
              ),
            ),

            // Colors Section
            _buildSection(
              'Colors',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildColorSwatch('Primary Green', AppColors.primaryGreen),
                  _buildColorSwatch('Zoe Deep', AppColors.zoeDeep),
                  _buildColorSwatch('Growth Tint', AppColors.growthTint),
                  _buildColorSwatch('Harvest Gold', AppColors.harvestGold),
                  _buildColorSwatch('Soft Sage', AppColors.softSage),
                  _buildColorSwatch('Pure White', AppColors.pureWhite),
                  _buildColorSwatch('Slate Gray', AppColors.slateGray),
                  _buildColorSwatch('Soft Borders', AppColors.softBorders),
                ],
              ),
            ),

            // Buttons Section
            _buildSection(
              'Buttons',
              Column(
                children: [
                  ZoeButton.primary(
                    label: 'Primary Button',
                    onPressed: () => _showSnackBar('Primary button pressed'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ZoeButton.secondary(
                    label: 'Secondary Button',
                    onPressed: () => _showSnackBar('Secondary button pressed'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ZoeButton.text(
                    label: 'Text Button',
                    onPressed: () => _showSnackBar('Text button pressed'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ZoeButton.primary(
                    label: 'Loading Button',
                    isLoading: _isLoading,
                    onPressed: () {
                      setState(() => _isLoading = true);
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) setState(() => _isLoading = false);
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const ZoeButton.primary(
                    label: 'Disabled Button',
                    onPressed: null,
                    enabled: false,
                  ),
                ],
              ),
            ),

            // Cards Section
            _buildSection(
              'Cards',
              Column(
                children: [
                  ZoeCard(
                    child: Text(
                      'This is a basic Zoe card with default styling. '
                      'It has a white background, subtle border, and rounded corners.',
                      style: AppTextStyles.body,
                    ),
                  ),
                  ZoeCard(
                    onTap: () => _showSnackBar('Card tapped'),
                    child: Row(
                      children: [
                        const Icon(Icons.touch_app, color: AppColors.primaryGreen),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'This card is tappable. Try tapping it!',
                            style: AppTextStyles.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stat Cards Section
            _buildSection(
              'Stat Cards',
              Row(
                children: [
                  Expanded(
                    child: ZoeStatCard(
                      value: '45',
                      label: 'Members',
                      icon: Icons.people,
                      onTap: () => _showSnackBar('Members stat tapped'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.statCardSpacing),
                  Expanded(
                    child: ZoeStatCard(
                      value: '38',
                      label: 'Last Sunday',
                      icon: Icons.event,
                      onTap: () => _showSnackBar('Attendance stat tapped'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.statCardSpacing),
                  Expanded(
                    child: ZoeStatCard(
                      value: '2',
                      label: 'New This Month',
                      icon: Icons.person_add,
                      valueColor: AppColors.harvestGold,
                      onTap: () => _showSnackBar('New members stat tapped'),
                    ),
                  ),
                ],
              ),
            ),

            // Input Fields Section
            _buildSection(
              'Input Fields',
              Column(
                children: [
                  ZoeInput(
                    label: 'Name',
                    hint: 'Enter your full name',
                    prefixIcon: const Icon(Icons.person),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ZoeInput(
                    label: 'Email',
                    hint: 'Enter your email address',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Email is required';
                      if (!value!.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ZoeInput(
                    label: 'Password',
                    hint: 'Enter your password',
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: const Icon(Icons.visibility_off),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ZoeInput(
                    label: 'Bio',
                    hint: 'Tell us about yourself',
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ZoeSearchInput(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchValue = value),
                    hint: 'Search members...',
                  ),
                  if (_searchValue.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text('Searching for: $_searchValue', style: AppTextStyles.caption),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  ZoeDropdown<String>(
                    label: 'Select Option',
                    value: _dropdownValue,
                    hint: 'Choose an option',
                    items: const [
                      DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
                      DropdownMenuItem(value: 'Option 2', child: Text('Option 2')),
                      DropdownMenuItem(value: 'Option 3', child: Text('Option 3')),
                    ],
                    onChanged: (value) => setState(() => _dropdownValue = value),
                  ),
                ],
              ),
            ),

            // Status Messages Section
            _buildSection(
              'Status Messages',
              Column(
                children: [
                  ZoeButton.secondary(
                    label: 'Show Success Message',
                    onPressed: () => _showSnackBar('Success! Operation completed successfully.'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ZoeButton.secondary(
                    label: 'Show Error Dialog',
                    onPressed: () => _showErrorDialog(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ZoeButton.secondary(
                    label: 'Show Info Dialog',
                    onPressed: () => _showInfoDialog(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.lg),
        content,
        const SizedBox(height: AppSpacing.sectionSpacing),
      ],
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppSpacing.xs),
              border: Border.all(color: AppColors.softBorders),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.label),
                Text(
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(
          'This is an example error dialog using the Project Zoe design system.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Information'),
        content: Text(
          'This dialog demonstrates how the design system components '
          'work together to create a consistent user experience.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ZoeButton.primary(
            label: 'Confirm',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}