import 'package:flutter/material.dart';

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String content;
  final DateTime date;
  final bool isImportant;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.content,
    required this.date,
    this.isImportant = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isImportant
            ? const BorderSide(color: Colors.red, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isImportant)
                  const Icon(Icons.priority_high, color: Colors.red, size: 20),
                if (isImportant) const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isImportant ? Colors.red : Colors.black,
                    ),
                  ),
                ),
                Text(
                  _formatDate(date),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class AnnouncementsSection extends StatelessWidget {
  const AnnouncementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - replace with real data later
    final announcements = [
      {
        'title': 'Sunday Service Update',
        'content':
            'This Sunday\'s service will start at 9:00 AM. Please arrive early for fellowship.',
        'date': DateTime.now().subtract(const Duration(hours: 2)),
        'isImportant': true,
      },
      {
        'title': 'Youth Meeting',
        'content':
            'Youth meeting scheduled for Friday at 7 PM. All youth members are encouraged to attend.',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'isImportant': false,
      },
      {
        'title': 'Prayer Chain Update',
        'content':
            'Remember to keep the Johnson family in your prayers. Updates will be shared during service.',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'isImportant': false,
      },
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.announcement, color: Colors.black, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Announcements',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all announcements
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          ...announcements
              .map(
                (announcement) => Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: (announcement['isImportant'] as bool)
                        ? Border.all(color: Colors.red, width: 1)
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (announcement['isImportant'] as bool)
                            const Icon(
                              Icons.priority_high,
                              color: Colors.red,
                              size: 20,
                            ),
                          if (announcement['isImportant'] as bool)
                            const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              announcement['title'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: (announcement['isImportant'] as bool)
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                          ),
                          Text(
                            _formatDate(announcement['date'] as DateTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        announcement['content'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
