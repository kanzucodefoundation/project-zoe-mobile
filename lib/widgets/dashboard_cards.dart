import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 150, // Slightly reduced height for better proportions
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24, // Slightly smaller icon
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardCardsSection extends StatelessWidget {
  const DashboardCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Top row with 3 cards - using Flexible instead of Expanded with proper spacing
          Row(
            children: [
              Flexible(
                flex: 1,
                child: DashboardCard(
                  icon: Icons.assessment,
                  title: 'MC Report',
                  subtitle: 'View Reports',
                  onTap: () {
                    Navigator.pushNamed(context, '/mc-report');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 1,
                child: DashboardCard(
                  icon: Icons.garage,
                  title: 'Garage Attendance',
                  subtitle: 'Track Attendance',
                  onTap: () {
                    Navigator.pushNamed(context, '/garage-attendance');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 1,
                child: DashboardCard(
                  icon: Icons.people,
                  title: 'Shepherds Details',
                  subtitle: 'Manage Shepherds',
                  onTap: () {
                    Navigator.pushNamed(context, '/shepherds-details');
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Summary data card (full width)
          Card(
            elevation: 4,
            shadowColor: Colors.grey.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                _showComingSoon(context, 'Summary Data');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.analytics, size: 40, color: Colors.black),
                    const SizedBox(height: 12),
                    const Text(
                      'Summary data for\nMC and Garage reports.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'View consolidated reports and analytics',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Church Finance card (full width)
          Card(
            elevation: 4,
            shadowColor: Colors.grey.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                _showComingSoon(context, 'Church Finance');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.account_balance, size: 40, color: Colors.black),
                    const SizedBox(height: 12),
                    const Text(
                      'Church Finance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage church finances and donations',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    // Removed snackbar - navigation to actual screens now
  }
}
