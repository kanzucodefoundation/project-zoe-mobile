import 'package:flutter/material.dart';
import 'package:project_zoe/Screens/people_screen.dart';
import 'package:project_zoe/components/report_card.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/report_provider.dart';
import 'mc_reports_display_screen.dart';
import 'garage_reports_display_screen.dart';
import 'reports_screen.dart';

class HomeSceen extends StatelessWidget {
  const HomeSceen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.church,
                        size: 32,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome to Project Zoe!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hello, ${_getFirstName(authProvider.user?.name ?? "User")}! Ready to make a difference?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Dashboard Cards Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Consumer<ReportProvider>(
            builder: (context, reportProvider, child) {
              final titleAndId = reportProvider.titleAndId;
              final isLoading = reportProvider.isLoading;

              if (isLoading) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: List.generate(
                      2,
                      (index) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    ...titleAndId.map((report) {
                      final id = report['id'].toString();
                      final title = report['title'].toString();

                      // Determine icon based on title
                      IconData icon = Icons.description;
                      Widget? targetScreen;

                      if (title.toLowerCase().contains('attendance')) {
                        icon = Icons.church;
                        targetScreen = McReportsScreen(reportId: id);
                      } else if (title.toLowerCase().contains('garage')) {
                        icon = Icons.garage;
                        targetScreen = GarageReportsScreen(reportId: id);
                      }

                      return ReportCard(
                        reportTitle: title,
                        reportIcon: icon,
                        iconColor: Colors.black,
                        onTap: () {
                          if (targetScreen != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => targetScreen!,
                              ),
                            );
                          }
                        },
                      );
                    }),
                    ReportCard(
                      reportTitle: 'People',
                      reportIcon: Icons.people,
                      iconColor: Colors.black,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PeopleScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Reports Statistics Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Text(
              'Report Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Consumer<ReportProvider>(
            builder: (context, reportProvider, child) {
              final summary = reportProvider.reportsSummary;
              final overdueReports = reportProvider.overdueReports;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  children: [
                    // Statistics Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Reports',
                            '${summary['total'] ?? 0}',
                            Icons.description,
                            Colors.blue.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Pending',
                            '${summary['pending'] ?? 0}',
                            Icons.schedule,
                            Colors.orange.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Completed',
                            '${summary['completed'] ?? 0}',
                            Icons.check_circle,
                            Colors.green.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Overdue',
                            '${overdueReports.length}',
                            Icons.warning,
                            Colors.red.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // View All Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to reports page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.assessment, color: Colors.white),
                        label: const Text(
                          'View All Reports',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          // const DashboardCardsSection(),

          // Announcements Section
          // const AnnouncementsSection(),

          // Bottom padding for navigation bar
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  String _getFirstName(String fullName) {
    if (fullName.isEmpty) return 'User';

    final parts = fullName
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.isNotEmpty ? parts.first : 'User';
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
