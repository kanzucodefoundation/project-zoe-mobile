import 'package:flutter/material.dart';

class Dropdown extends StatefulWidget {
  final String hintText;
  final IconData? prefixIcon;
  final List<Map<String, dynamic>> items;
  final String Function(Map<String, dynamic>) getDisplayText;
  final Map<String, dynamic>? value;
  final void Function(Map<String, dynamic>?)? onChanged;
  final String? Function(Map<String, dynamic>?)? validator;
  final bool isLoading;

  const Dropdown({
    super.key,
    required this.hintText,
    required this.items,
    required this.getDisplayText,
    this.prefixIcon,
    this.value,
    this.onChanged,
    this.validator,
    this.isLoading = false,
  });

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Map<String, dynamic>>(
      value: widget.value,
      onChanged: widget.isLoading ? null : widget.onChanged,
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),

        // Prefix icon
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: Colors.grey[500], size: 20)
            : null,

        // Suffix icon for loading state
        suffixIcon: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,

        // Border styling
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),

        // Padding
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),

      // Style the dropdown
      style: const TextStyle(color: Colors.black, fontSize: 16),
      dropdownColor: Colors.white,

      // Items
      items: widget.isLoading
          ? []
          : widget.items
                .map(
                  (item) => DropdownMenuItem<Map<String, dynamic>>(
                    value: item,
                    child: Text(
                      widget.getDisplayText(item),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                )
                .toList(),
    );
  }
}
