import 'package:flutter/material.dart';
import '../models/report_template.dart';

/// Custom tile for MC selection dropdown
class McSelectionTile extends StatelessWidget {
  final List<Map<String, dynamic>> availableMcs;
  final String? selectedMcId;
  final bool isLoading;
  final Function(String mcId, String mcName) onMcSelected;

  const McSelectionTile({
    super.key,
    required this.availableMcs,
    required this.selectedMcId,
    required this.isLoading,
    required this.onMcSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.groups, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Select Missional Community',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Text(' *', style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Loading MCs...'),
                      ],
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedMcId,
                      hint: Text(
                        'Select MC',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      items: availableMcs.map((mc) {
                        return DropdownMenuItem<String>(
                          value: mc['id']?.toString(),
                          child: Text(
                            mc['name'] ?? 'Unknown MC',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          final selectedMc = availableMcs.firstWhere(
                            (mc) => mc['id']?.toString() == value,
                          );
                          onMcSelected(
                            value,
                            selectedMc['name'] ?? 'Unknown MC',
                          );
                        }
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Custom tile for date selection
class DateSelectionTile extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelectionTile({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.green.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'MC Gathering Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Text(' *', style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (date != null) {
                onDateSelected(date);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey.shade600),
                  const SizedBox(width: 12),
                  Text(
                    selectedDate != null
                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedDate != null
                          ? Colors.black87
                          : Colors.grey.shade600,
                      fontWeight: selectedDate != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom tile for form fields
class FormFieldTile extends StatelessWidget {
  final ReportField field;
  final String value;
  final Function(String) onChanged;

  const FormFieldTile({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getFieldIcon(),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  field.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (field.required)
                const Text(' *', style: TextStyle(color: Colors.red)),
            ],
          ),
          // Note: ReportField doesn't have description property
          // Remove description section
          const SizedBox(height: 12),
          _buildFieldInput(),
        ],
      ),
    );
  }

  Widget _getFieldIcon() {
    switch (field.type.toLowerCase()) {
      case 'number':
      case 'numeric':
        return Icon(Icons.numbers, color: Colors.blue.shade600, size: 20);
      case 'email':
        return Icon(Icons.email, color: Colors.orange.shade600, size: 20);
      case 'phone':
        return Icon(Icons.phone, color: Colors.green.shade600, size: 20);
      case 'date':
        return Icon(
          Icons.calendar_today,
          color: Colors.purple.shade600,
          size: 20,
        );
      case 'dropdown':
        return Icon(
          Icons.arrow_drop_down,
          color: Colors.indigo.shade600,
          size: 20,
        );
      default:
        return Icon(Icons.text_fields, color: Colors.grey.shade600, size: 20);
    }
  }

  Widget _buildFieldInput() {
    if (field.name == 'smallGroupName') {
      // Skip this field as it's handled by the MC dropdown
      return const SizedBox.shrink();
    }

    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      keyboardType: _getKeyboardType(),
      maxLines: field.type.toLowerCase() == 'textarea' ? 3 : 1,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: 'Enter ${field.label.toLowerCase()}',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: field.required
          ? (val) => val?.isEmpty == true ? 'This field is required' : null
          : null,
    );
  }

  TextInputType _getKeyboardType() {
    switch (field.type.toLowerCase()) {
      case 'email':
        return TextInputType.emailAddress;
      case 'phone':
        return TextInputType.phone;
      case 'number':
      case 'numeric':
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }
}

/// Custom tile for report template header
class ReportHeaderTile extends StatelessWidget {
  final ReportTemplate reportTemplate;

  const ReportHeaderTile({super.key, required this.reportTemplate});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reportTemplate.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (reportTemplate.description.isNotEmpty)
                      Text(
                        reportTemplate.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInfoChip('Type', reportTemplate.viewType),
              const SizedBox(width: 12),
              _buildInfoChip('Frequency', reportTemplate.submissionFrequency),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
