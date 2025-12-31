import 'package:flutter/material.dart';
import '../../widgets/custom_toast.dart';
import 'package:project_zoe/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true; // Default to enabled
  bool _weeklyRemindersEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Notifications Section
            _buildSettingsSection(
              title: 'Notifications',
              icon: Icons.notifications_outlined,
              children: [
                // Main notification toggle
                _buildSettingsTile(
                  title: 'Enable Notifications',
                  subtitle: 'Get reminders to submit your reports',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      if (!value) {
                        // Cancel all notifications when disabled
                        notificationService.cancelAllNotifications();
                        setState(() {
                          _weeklyRemindersEnabled = false;
                        });
                        _showToast('All notifications cancelled');
                      }
                    },
                    activeThumbColor: Colors.green,
                  ),
                ),

                const Divider(height: 1),

                // Weekly reminders toggle
                _buildSettingsTile(
                  title: 'Weekly Report Reminders',
                  subtitle: 'Every Wednesday at 9:00 AM',
                  trailing: Switch(
                    value: _weeklyRemindersEnabled && _notificationsEnabled,
                    onChanged: _notificationsEnabled
                        ? (value) {
                            setState(() {
                              _weeklyRemindersEnabled = value;
                            });
                            if (value) {
                              notificationService
                                  .scheduleMcReportReminderWeekly();
                              _showToast(
                                'Weekly reminders scheduled for Wednesdays at 9 AM',
                              );
                            } else {
                              notificationService.cancelMcReportReminder();
                              _showToast('Weekly reminders cancelled');
                            }
                          }
                        : null,
                    activeThumbColor: Colors.blue,
                  ),
                  enabled: _notificationsEnabled,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Test Notifications Section
            _buildSettingsSection(
              title: 'Test Notifications',
              icon: Icons.bug_report_outlined,
              children: [
                // Test now button
                _buildActionTile(
                  title: 'Test Notification Now',
                  subtitle: 'Send a test notification immediately',
                  icon: Icons.send_outlined,
                  onTap: _notificationsEnabled
                      ? () {
                          notificationService.showNotification(
                            title: 'Report Submission Reminder',
                            body:
                                'Don\'t forget to submit your daily report. Tap here to continue.',
                          );
                          _showToast('Test notification sent');
                        }
                      : null,
                  enabled: _notificationsEnabled,
                ),

                const Divider(height: 1),

                // 2-minute test
                _buildActionTile(
                  title: 'Set 2-Minute Test Reminder',
                  subtitle: 'Schedule a test reminder in 2 minutes',
                  icon: Icons.schedule_outlined,
                  onTap: _notificationsEnabled
                      ? () {
                          notificationService
                              .scheduleReportReminderIn2Minutes();
                          _showToast(
                            'Test reminder set for 2 minutes from now',
                          );
                        }
                      : null,
                  enabled: _notificationsEnabled,
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required Widget trailing,
    bool enabled = true,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: enabled ? Colors.black : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: enabled ? Colors.grey[600] : Colors.grey[400]),
      ),
      trailing: trailing,
      enabled: enabled,
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
    bool enabled = true,
  }) {
    return ListTile(
      leading: Icon(icon, color: enabled ? Colors.blue : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: enabled ? Colors.black : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: enabled ? Colors.grey[600] : Colors.grey[400]),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: enabled ? Colors.grey : Colors.grey[300],
      ),
      onTap: onTap,
      enabled: enabled,
    );
  }

  void _showToast(String message) {
    ToastHelper.showInfo(context, message);
  }
}
