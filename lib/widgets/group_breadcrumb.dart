import 'package:flutter/material.dart';
import '../models/group.dart';

/// Breadcrumb navigation widget for group hierarchy
class GroupBreadcrumb extends StatelessWidget {
  final List<Group> groups;
  final Group currentGroup;
  final Function(Group)? onGroupTap;

  const GroupBreadcrumb({
    super.key,
    required this.groups,
    required this.currentGroup,
    this.onGroupTap,
  });

  List<Group> _getPathToGroup(Group group) {
    final List<Group> path = [group];
    Group? current = group;

    while (current?.parentId != null) {
      current = groups.firstWhere(
        (g) => g.id == current!.parentId,
        orElse: () => throw Exception('Parent group not found'),
      );
      path.insert(0, current);
    }

    return path;
  }

  @override
  Widget build(BuildContext context) {
    final path = _getPathToGroup(currentGroup);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Icon(Icons.home, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            ...path.asMap().entries.map((entry) {
              final index = entry.key;
              final group = entry.value;
              final isLast = index == path.length - 1;

              return Row(
                children: [
                  if (index > 0) ...[
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                  ],
                  GestureDetector(
                    onTap: isLast ? null : () => onGroupTap?.call(group),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isLast
                            ? Colors.blue.shade100
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        group.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isLast
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isLast
                              ? Colors.blue.shade800
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Group statistics card
class GroupStatsCard extends StatelessWidget {
  final Group group;
  final List<Group> allGroups;

  const GroupStatsCard({
    super.key,
    required this.group,
    required this.allGroups,
  });

  int _getChildrenCount(Group group) {
    return allGroups.where((g) => g.parentId == group.id).length;
  }

  int _getTotalDescendants(Group group) {
    int count = 0;
    final children = allGroups.where((g) => g.parentId == group.id).toList();

    for (final child in children) {
      count += 1 + _getTotalDescendants(child);
    }

    return count;
  }

  @override
  Widget build(BuildContext context) {
    final directChildren = _getChildrenCount(group);
    final totalDescendants = _getTotalDescendants(group);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getColorForType(group.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconForType(group.type),
                    color: _getColorForType(group.type),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        group.categoryName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Direct Children',
                    directChildren.toString(),
                    Icons.account_tree,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'All Descendants',
                    totalDescendants.toString(),
                    Icons.nature_people,
                  ),
                ),
                if (group.memberCount > 0)
                  Expanded(
                    child: _buildStatItem(
                      'Members',
                      '${group.activeMembers}/${group.memberCount}',
                      Icons.people,
                    ),
                  ),
              ],
            ),
            if (group.details.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                group.details,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'movement':
        return Colors.purple.shade600;
      case 'network':
        return Colors.blue.shade600;
      case 'fob':
        return Colors.teal.shade600;
      case 'location':
        return Colors.orange.shade600;
      case 'zone':
        return Colors.green.shade600;
      case 'fellowship':
        return Colors.pink.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'movement':
        return Icons.public;
      case 'network':
        return Icons.hub;
      case 'fob':
        return Icons.location_city;
      case 'location':
        return Icons.place;
      case 'zone':
        return Icons.map;
      case 'fellowship':
        return Icons.groups;
      default:
        return Icons.folder;
    }
  }
}
