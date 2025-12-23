import 'package:flutter/material.dart';

class CustomDatePicker extends StatefulWidget {
  final String hintText;
  final IconData? prefixIcon;
  final DateTime? selectedDate;
  final void Function(DateTime?)? onDateSelected;
  final String? Function(DateTime?)? validator;

  const CustomDatePicker({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.selectedDate,
    this.onDateSelected,
    this.validator,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      validator: widget.validator,
      initialValue: widget.selectedDate,
      builder: (FormFieldState<DateTime> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _selectDate(context, state),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: state.hasError
                        ? Colors.red
                        : const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (widget.prefixIcon != null) ...[
                      Icon(
                        widget.prefixIcon,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        widget.selectedDate != null
                            ? _formatDate(widget.selectedDate!)
                            : widget.hintText,
                        style: TextStyle(
                          color: widget.selectedDate != null
                              ? Colors.black
                              : Colors.grey[500],
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: Colors.grey[500],
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (state.hasError) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    FormFieldState<DateTime> state,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != widget.selectedDate) {
      state.didChange(picked);
      if (widget.onDateSelected != null) {
        widget.onDateSelected!(picked);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
