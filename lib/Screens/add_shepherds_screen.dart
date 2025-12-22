import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:project_zoe/models/people.dart';
import 'package:provider/provider.dart';

import '../components/custom_text_field.dart';
import '../components/long_button.dart';
import '../providers/shepherds_provider.dart';

class AddShepherdsScreen extends StatefulWidget {
  final People? shepherd; // If provided, screen is in edit mode

  const AddShepherdsScreen({super.key, this.shepherd});

  @override
  State<AddShepherdsScreen> createState() => _AddShepherdsScreenState();
}

class _AddShepherdsScreenState extends State<AddShepherdsScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Get the existing provider from context after the widget builds
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShepherdsProvider>(
      builder: (context, prov, _) {
        // Initialize for edit if needed
        if (!_isInitialized && widget.shepherd != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            prov.loadShepherdForEdit(widget.shepherd!);
          });
          _isInitialized = true;
        } else if (!_isInitialized && widget.shepherd == null) {
          // Ensure we're in add mode when no shepherd is provided
          WidgetsBinding.instance.addPostFrameCallback((_) {
            prov.clear();
          });
          _isInitialized = true;
        }

        final isEditMode = prov.isEditMode;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              isEditMode ? 'Edit Shepherd' : 'Add Shepherd',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: prov.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  const Text(
                    'Shepherd Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEditMode
                        ? 'Update the shepherd details below'
                        : 'Please fill in the details below to add a new shepherd',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name Field
                  const Text(
                    'Full Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: "Enter shepherd's full name",
                    prefixIcon: Icons.person_outline,
                    controller: prov.firstNameController,
                    validator: prov.validateName,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  const Text(
                    'Email Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'Enter email address',
                    prefixIcon: Icons.email_outlined,
                    controller: prov.lastNameController,
                    validator: prov.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  // Phone Field
                  const Text(
                    'Phone Number',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'Enter Age Group',
                    prefixIcon: Icons.phone_outlined,
                    controller: prov.ageGroupController,
                    validator: prov.validatePhone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),

                  // Address Field
                  const Text(
                    'Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'Enter address (optional)',
                    prefixIcon: Icons.location_on_outlined,
                    controller: prov.placeOfWorkController,
                    keyboardType: TextInputType.streetAddress,
                  ),
                  const SizedBox(height: 20),

                  // Church Location Field
                  const Text(
                    'Church Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'Enter Salutation',
                    prefixIcon: Icons.church_outlined,
                    controller: prov.salutationController,
                    validator: prov.validateChurchLocation,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 20),

                  // Position Field
                  const Text(
                    'Position/Role',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Department Field
                  const Text(
                    'Department',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Years of Service Field
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'Enter date of birth',
                    prefixIcon: Icons.calendar_today_outlined,
                    controller: prov.dateOfBirthController,
                    validator: prov.validateYearsOfService,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Emergency Contact Section Header
                  const Text(
                    'Emergency Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Emergency Contact Phone
                  const Text(
                    'Emergency Contact Phone',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // CustomTextField(
                  //   hintText: 'Enter emergency contact phone',
                  //   prefixIcon: Icons.phone_in_talk_outlined,
                  //   controller: prov.emergencyPhoneController,
                  //   validator: prov.validateEmergencyPhone,
                  //   keyboardType: TextInputType.phone,
                  // ),
                  // const SizedBox(height: 40),

                  // Submit Button
                  LongButton(
                    text: isEditMode ? 'Update Shepherd' : 'Add Shepherd',
                    onPressed: () async {
                      final ok = await prov.submit();
                      if (ok) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditMode
                                    ? 'Shepherd updated successfully!'
                                    : 'Shepherd added successfully!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Navigate back to previous screen
                          Navigator.pop(context, true);
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please fix the errors in the form',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    isLoading: prov.isLoading,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
