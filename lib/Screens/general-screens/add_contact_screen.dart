import 'package:flutter/material.dart';
import '../../models/contacts.dart';
import 'add_member_screen_enhanced.dart';

/// Contact Form Screen - Redirects to enhanced version
/// Maintains backwards compatibility while using the new design system
class AddContactScreen extends StatelessWidget {
  final Contact? editingContact;

  const AddContactScreen({super.key, this.editingContact});

  @override
  Widget build(BuildContext context) {
    return EnhancedAddMemberScreen(editingContact: editingContact);
  }
}