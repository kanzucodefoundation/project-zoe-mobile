import 'package:flutter/material.dart';
import 'package:project_zoe/models/report.dart';
import 'package:project_zoe/models/reports_model.dart';
import 'package:project_zoe/services/reports_service.dart';
import 'package:project_zoe/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../components/text_field.dart';
import '../../components/submit_button.dart';
import '../../components/dropdown.dart';
import '../../components/custom_date_picker.dart';
import '../../widgets/custom_toast.dart';

/// MC Attendance Report Screen - Shows MC report template and submissions
class McAttendanceReportScreen extends StatefulWidget {
  final int? reportId;
  const McAttendanceReportScreen({super.key, this.reportId});

  @override
  State<McAttendanceReportScreen> createState() =>
      _McAttendanceReportScreenState();
}

class _McAttendanceReportScreenState extends State<McAttendanceReportScreen> {
  Report? _reportTemplate;
  List<Map<String, dynamic>> _availableMcs = [];
  final Map<int, List<Map<String, dynamic>>> _mcReports = {};
  bool _isLoading = true;
  String? _error;

  // Form related
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _dynamicSelections = {}; // Store dynamic field selections
  Map<String, dynamic>? _selectedMc;
  DateTime? _selectedDate;
  String? _selectedStreamOption;
  bool _isSubmitting = false;
  bool _isLoadingMcs = false;
  bool _hasInitialized = false; // 🔥 ADD THIS FLAG

  @override
  void initState() {
    super.initState();
    _loadMcData();
  }

  @override
  void dispose() {
    // Dispose all text controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Load MC report template and data
  Future<void> _loadMcData() async {
    if (_hasInitialized) return; // 🔥 PREVENT MULTIPLE CALLS
    _hasInitialized = true;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load MC report template
      if (widget.reportId != null) {
        debugPrint('🔍 Loading report template for ID: ${widget.reportId}');
        final templateData = await ReportsService.getReportById(
          widget.reportId!,
        );
        debugPrint('✅ Template data loaded, parsing to Report model...');
        debugPrint('Template data type: ${templateData.runtimeType}');
        try {
          _reportTemplate = Report.fromJson(templateData.toJson());
          debugPrint('✅ Report template parsed successfully');
        } catch (parseError) {
          debugPrint('💀 Report.fromJson failed: $parseError');
          rethrow;
        }
      }

      // Load available MCs with proper loading state
      setState(() {
        _isLoadingMcs = true;
      });

      try {
        _availableMcs = await ReportsService.getMyAvailableGroups();

        setState(() {
          _isLoadingMcs = false;
        });

        // Load reports for each MC
        await _loadReportsForAllMcs();
      } catch (e) {
        setState(() {
          _isLoadingMcs = false;
          _availableMcs = [];
        });
        // Don't fail the entire screen, just continue without MC data
      }
    } catch (e) {
      debugPrint('💀 ERROR in _loadMcData: $e');
      debugPrint('💀 Stack trace: ${StackTrace.current}');
      setState(() {
        _error = _getCleanErrorMessage(e, 'Failed to load report template');
        _isLoadingMcs = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Load reports for all available MCs
  Future<void> _loadReportsForAllMcs() async {
    for (final mc in _availableMcs) {
      try {
        final reports = await ReportsService.getReportDetailsByGroupId(
          mc['id'],
        );

        // Sort reports by date (newest first)
        reports.sort((a, b) {
          final dateA =
              DateTime.tryParse(a['submittedAt']?.toString() ?? '') ??
              DateTime(1970);
          final dateB =
              DateTime.tryParse(b['submittedAt']?.toString() ?? '') ??
              DateTime(1970);
          return dateB.compareTo(dateA);
        });

        if (mounted) {
          setState(() {
            _mcReports[mc['id']] = reports;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _mcReports[mc['id']] = [];
          });
        }
      }
    }
  }

  // 🔥 ADD MANUAL REFRESH METHOD
  Future<void> _refreshData() async {
    _hasInitialized = false;
    await _loadMcData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MC Attendance Reports',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshData, // 🔥 USE NEW REFRESH METHOD
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading MC reports...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshData, // 🔥 USE NEW REFRESH METHOD
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_reportTemplate == null && _availableMcs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Could not load report data at this time',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData, // 🔥 USE NEW REFRESH METHOD
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // 🔥 ENSURE SCROLLABLE
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_reportTemplate != null) ...[
              _buildReportHeader(),
              const SizedBox(height: 24),
              _buildReportFieldsWithForm(),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.church, size: 24, color: Colors.purple),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _reportTemplate!.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _reportTemplate!.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip('Frequency', _reportTemplate!.submissionFrequency),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.purple).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color ?? Colors.purple.shade700,
        ),
      ),
    );
  }

  Widget _buildReportFieldsWithForm() {
    if (_reportTemplate?.fields == null) return const SizedBox();

    final visibleFields = _reportTemplate!.fields!
        .where((field) => !field.hidden)
        .toList();

    // 🔥 SORT FIELDS BY ORDER
    visibleFields.sort((a, b) => a.order.compareTo(b.order));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Fields',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fill out the fields below to submit your MC report',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // Generate form fields
            ...visibleFields.map(
              (field) => _buildTemplateFieldWithInput(field),
            ),

            const SizedBox(height: 24),

            // Submit button
            SubmitButton(
              text: _isSubmitting ? 'Submitting...' : 'Submit Report',
              onPressed: _isSubmitting ? () {} : _submitReport,
              backgroundColor: Colors.black,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateFieldWithInput(ReportField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: field.required ? Colors.red : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  field.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInputForField(field),
        ],
      ),
    );
  }

  Widget _buildInputForField(ReportField field) {
    final fieldName = field.name.toLowerCase();
    final fieldLabel = field.label.toLowerCase();

    // Stream field dropdown
    if (field.name == 'mcStreamPlatform' ||
        fieldName.contains('stream') ||
        fieldLabel.contains('stream') ||
        fieldLabel.contains('how did you stream')) {
      final dropdownItems = (field.options ?? [])
          .map((option) => {'id': option.toString(), 'name': option.toString()})
          .toList();

      // 🔥 USE KEY TO PREVENT REBUILD LOOPS
      return Dropdown(
        key: ValueKey('stream_${field.name}'), // 🔥 ADD UNIQUE KEY
        hintText: field.label.length > 20 ? 'Select option' : 'Select ${field.label}',
        items: dropdownItems,
        getDisplayText: (item) => item['name'] ?? 'Unknown Option',
        value: _selectedStreamOption != null
            ? dropdownItems.cast<Map<String, dynamic>?>().firstWhere(
                (item) => item?['name'] == _selectedStreamOption,
                orElse: () => null,
              )
            : null,
        onChanged: (selectedOption) {
          if (mounted) {
            setState(() {
              _selectedStreamOption = selectedOption?['name'];
            });
          }
        },
        validator: field.required
            ? (value) {
                if (value == null) {
                  return 'Please select ${field.label}';
                }
                return null;
              }
            : null,
      );
    }

    // Date picker
    if (fieldName.contains('date') || fieldLabel.contains('date')) {
      return CustomDatePicker(
        key: ValueKey('date_${field.name}'), // 🔥 ADD UNIQUE KEY
        hintText: field.label.length > 15 ? 'Select date' : 'Select ${field.label.toLowerCase()}',
        prefixIcon: Icons.calendar_today,
        selectedDate: _selectedDate,
        onDateSelected: (date) {
          if (mounted) {
            setState(() {
              _selectedDate = date;
            });
          }
        },
        validator: field.required
            ? (value) {
                if (value == null) {
                  return '${field.label} is required';
                }
                return null;
              }
            : null,
      );
    }

    // Check if this is a dynamic group selector field
    if (field.type.toLowerCase() == 'select' && 
        field.options != null && 
        field.options!.isNotEmpty &&
        field.options![0] is Map<String, dynamic> &&
        (field.options![0] as Map<String, dynamic>)['type'] == 'dynamic_group_selector') {
      
      return _buildDynamicGroupSelector(field);
    }

    // Initialize controller if not exists
    if (!_controllers.containsKey(field.name)) {
      _controllers[field.name] = TextEditingController();
    }

    // Text area
    if (field.type.toLowerCase() == 'textarea' ||
        fieldLabel.contains('comment') ||
        fieldLabel.contains('note') ||
        fieldLabel.contains('description') ||
        fieldLabel.contains('summary')) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: TextFormField(
          key: ValueKey('textarea_${field.name}'), // 🔥 ADD UNIQUE KEY
          controller: _controllers[field.name],
          maxLines: 4,
          validator: field.required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '${field.label} is required';
                  }
                  return null;
                }
              : null,
          decoration: InputDecoration(
            hintText: 'Enter ${field.label.toLowerCase()}',
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      );
    }

    // Regular text field
    return CustomTextField(
      key: ValueKey('text_${field.name}'), // 🔥 ADD UNIQUE KEY
      hintText: 'Enter ${field.label.toLowerCase()}',
      controller: _controllers[field.name],
      keyboardType: _getKeyboardType(field.type),
      validator: field.required
          ? (value) {
              if (value == null || value.isEmpty) {
                return '${field.label} is required';
              }
              return null;
            }
          : null,
    );
  }

  /// Build dynamic group selector dropdown
  Widget _buildDynamicGroupSelector(ReportField field) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _resolveDynamicGroupOptions(field),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Loading ${field.label.toLowerCase()}...',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error loading ${field.label.toLowerCase()}',
                    style: TextStyle(color: Colors.red.shade600, fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }

        final options = snapshot.data ?? [];
        
        // Get current selection for this field
        final currentSelection = _dynamicSelections[field.name];
        final selectedItem = currentSelection != null 
            ? options.cast<Map<String, dynamic>?>().firstWhere(
                (item) => item != null && item['id'] == currentSelection['id'],
                orElse: () => null,
              )
            : null;

        return Dropdown(
          key: ValueKey('dynamic_${field.name}'),
          hintText: options.isEmpty 
              ? 'No ${field.label.toLowerCase()} available'
              : 'Select ${field.label.toLowerCase()}',
          prefixIcon: Icons.group,
          items: options,
          getDisplayText: (option) => option['name'] ?? 'Unknown',
          value: selectedItem,
          onChanged: options.isEmpty ? null : (selected) {
            if (mounted) {
              setState(() {
                _dynamicSelections[field.name] = selected;
              });
            }
          },
          validator: field.required
              ? (value) {
                  if (value == null) {
                    return 'Please select ${field.label}';
                  }
                  return null;
                }
              : null,
        );
      },
    );
  }

  /// Resolve dynamic group options from field configuration
  Future<List<Map<String, dynamic>>> _resolveDynamicGroupOptions(ReportField field) async {
    try {
      debugPrint('🔍 Resolving options for field: ${field.name}');
      debugPrint('🔍 Field options: ${field.options}');
      
      if (field.options == null || field.options!.isEmpty) {
        debugPrint('⚠️ Field has no options');
        return [];
      }

      if (field.options![0] is! Map<String, dynamic>) {
        debugPrint('⚠️ First option is not a Map: ${field.options![0].runtimeType}');
        return [];
      }

      final selectorConfig = field.options![0] as Map<String, dynamic>;
      debugPrint('🔍 Selector config: $selectorConfig');
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final result = await ReportsService.resolveDynamicGroupSelector(
        selectorConfig, 
        authProvider,
      );
      
      debugPrint('✅ Resolved ${result.length} options for field ${field.name}');
      return result;
    } catch (e) {
      debugPrint('💀 Error resolving dynamic group options for ${field.name}: $e');
      debugPrint('💀 Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  TextInputType _getKeyboardType(String type) {
    switch (type.toLowerCase()) {
      case 'number':
      case 'integer':
        return TextInputType.number;
      case 'email':
        return TextInputType.emailAddress;
      case 'phone':
        return TextInputType.phone;
      case 'url':
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      ToastHelper.showWarning(context, 'Please fill in all required fields');
      return;
    }

    // Check if we have any required dynamic field selections
    if (_dynamicSelections.isEmpty) {
      ToastHelper.showWarning(context, 'Please complete all required fields');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final Map<String, dynamic> formData = {};
      for (var entry in _controllers.entries) {
        formData[entry.key] = entry.value.text;
      }

      if (_selectedStreamOption != null) {
        formData['mcStreamPlatform'] = _selectedStreamOption;
      }

      // Add dynamic field selections to form data
      for (var entry in _dynamicSelections.entries) {
        final fieldName = entry.key;
        final selection = entry.value;
        
        if (selection != null) {
          // For name fields, store the name; for ID fields, store the ID
          if (fieldName.toLowerCase().contains('name')) {
            formData[fieldName] = selection['name'];
          } else if (fieldName.toLowerCase().contains('id')) {
            formData[fieldName] = selection['id'];
          } else {
            // Default: assume it wants the name
            formData[fieldName] = selection['name'];
          }
        }
      }

      if (_selectedDate != null) {
        formData['date'] = _selectedDate!.toIso8601String();
      }

      print('🚀 Submitting MC report: $formData');

      // Get groupId from dynamic selections
      final groupId = _dynamicSelections.values.first['id'] as int;
      
      final submission = await ReportsService.submitReport(
        groupId: groupId,
        reportId: widget.reportId ?? 1,
        data: formData,
      );

      if (mounted) {
        final selectedGroup = _dynamicSelections.values.first;
        final newSubmissionData = {
          'id': submission.id,
          'reportId': widget.reportId ?? 1,
          'groupId': selectedGroup['id'],
          'groupName': selectedGroup['name'],
          'submittedAt': DateTime.now().toIso8601String(),
          'submittedBy': {'name': 'Current User'},
          'data': formData,
        };

        final mcId = selectedGroup['id'];
        if (_mcReports.containsKey(mcId)) {
          _mcReports[mcId]!.insert(0, newSubmissionData);
        } else {
          _mcReports[mcId] = [newSubmissionData];
        }

        _mcReports[mcId]!.sort((a, b) {
          final dateA =
              DateTime.tryParse(a['submittedAt']?.toString() ?? '') ??
              DateTime(1970);
          final dateB =
              DateTime.tryParse(b['submittedAt']?.toString() ?? '') ??
              DateTime(1970);
          return dateB.compareTo(dateA);
        });

        setState(() {});

        ToastHelper.showSuccess(
          context,
          'MC report submitted successfully! 🎉',
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(
          context,
          _getCleanErrorMessage(e, 'Error submitting report'),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// Convert technical error messages to user-friendly ones
  String _getCleanErrorMessage(dynamic error, String defaultMessage) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('connection refused') ||
        errorString.contains('connection error')) {
      return 'Server is unavailable. Please try again later.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please check your connection and try again.';
    } else if (errorString.contains('host not found') ||
        errorString.contains('network unreachable')) {
      return 'No internet connection. Please check your network settings.';
    } else if (errorString.contains('404') ||
        errorString.contains('not found')) {
      return 'Resource not found. Please contact support.';
    } else if (errorString.contains('500') ||
        errorString.contains('server error')) {
      return 'Server error. Please try again later.';
    } else if (errorString.contains('empty reply') ||
        errorString.contains('connection closed') ||
        errorString.contains('no data received')) {
      return 'Server did not respond. This feature may not be implemented yet.';
    }

    return defaultMessage;
  }
}
