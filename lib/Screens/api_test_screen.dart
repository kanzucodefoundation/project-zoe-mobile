import 'package:flutter/material.dart';
import '../api/connectivity_test.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';

/// Widget to test API connectivity and functionality
class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  List<String> _testResults = [];
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Connection Test'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isRunning ? null : _runTests,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isRunning
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Run API Tests'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Results:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._testResults.map(
                        (result) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            result,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runTests() async {
    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    _addResult('🧪 Starting API Tests...\n');

    // Test 1: Basic connectivity
    _addResult('1. Testing basic connectivity...');
    try {
      final connected = await ConnectivityTest.runAllTests();
      _addResult(connected ? '✅ Connectivity: PASS' : '❌ Connectivity: FAIL');
    } catch (e) {
      _addResult('❌ Connectivity: ERROR - $e');
    }

    _addResult('');

    // Test 2: Authentication endpoint
    _addResult('2. Testing authentication endpoint...');
    try {
      await AuthService.loginUser(
        email: 'test@example.com',
        password: 'wrongpassword',
        churchName: 'test',
      );
      _addResult('❌ Auth: Unexpected success with wrong credentials');
    } catch (e) {
      if (e.toString().contains('401') ||
          e.toString().contains('unauthorized') ||
          e.toString().contains('invalid')) {
        _addResult(
          '✅ Auth: Endpoint responding correctly (rejected bad credentials)',
        );
      } else if (e.toString().contains('connection') ||
          e.toString().contains('network')) {
        _addResult('❌ Auth: Connection failed - $e');
      } else {
        _addResult('⚠️ Auth: Unexpected error - $e');
      }
    }

    _addResult('');

    // Test 3: Report endpoints
    _addResult('3. Testing report endpoints...');
    try {
      await ReportService.getAllReports();
      _addResult('✅ Reports: Endpoint accessible');
    } catch (e) {
      if (e.toString().contains('401') ||
          e.toString().contains('unauthorized')) {
        _addResult('✅ Reports: Endpoint protected (needs authentication)');
      } else if (e.toString().contains('connection') ||
          e.toString().contains('network')) {
        _addResult('❌ Reports: Connection failed - $e');
      } else {
        _addResult('⚠️ Reports: Unexpected error - $e');
      }
    }

    // Test 4: MC Report submission test
    _addResult('');
    _addResult('4. Testing MC Report submission...');
    try {
      await ReportService.submitMcReport(
        gatheringDate: DateTime.now().toIso8601String(),
        mcName: 'Test MC',
        hostHome: 'Test Home',
        totalMembers: 10,
        attendance: 8,
        streamingMethod: 'YouTube',
        attendeesNames: 'Test attendees',
        visitors: 'Test visitors',
        highlights: 'Test highlights',
        testimonies: 'Test testimonies',
        prayerRequests: 'Test prayer requests',
      );
      _addResult('✅ MC Report: Submission successful');
    } catch (e) {
      if (e.toString().contains('401') ||
          e.toString().contains('unauthorized')) {
        _addResult('✅ MC Report: Endpoint protected (needs authentication)');
      } else if (e.toString().contains('connection') ||
          e.toString().contains('network')) {
        _addResult('❌ MC Report: Connection failed - $e');
      } else {
        _addResult('⚠️ MC Report: Error - $e');
      }
    }

    _addResult('');
    _addResult('🎯 Test Summary:');
    _addResult(
      '- Base URL: https://staging-projectzoe.kanzucodefoundation.org/server',
    );
    _addResult(
      '- API URL: https://staging-projectzoe.kanzucodefoundation.org/server/api',
    );
    _addResult('- Login: /api/auth/login');
    _addResult('- Register: /api/register');
    _addResult('- Profile: /api/auth/profile');
    _addResult('- Reports: /api/reports');
    _addResult('- Submit Report: /api/reports/submit');
    _addResult('- Categories: /api/reports/category');
    _addResult('\\n✅ Tests completed!');

    setState(() {
      _isRunning = false;
    });
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add(result);
    });
    // Small delay to show real-time updates
    Future.delayed(const Duration(milliseconds: 100));
  }
}