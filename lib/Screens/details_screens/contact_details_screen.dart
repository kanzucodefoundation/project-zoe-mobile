import 'package:flutter/material.dart';
import 'member_details_screen_enhanced.dart';

/// Wrapper for backward compatibility - redirects to enhanced version
class ContactDetailsScreen extends StatelessWidget {
  final int contactId;

  const ContactDetailsScreen({super.key, required this.contactId});

  @override
  Widget build(BuildContext context) {
    return EnhancedMemberDetailsScreen(contactId: contactId);
  }
}
