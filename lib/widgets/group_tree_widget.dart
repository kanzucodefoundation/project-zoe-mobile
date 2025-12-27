import 'package:flutter/material.dart';
import '../models/group.dart';

/// Enhanced tree widget for displaying group hierarchy with better visual structure
class GroupTreeWidget extends StatefulWidget {
  final List<Group> groups;
  final Function(Group)? onGroupTap;
  final Function(Group)? onGroupLongPress;

  const GroupTreeWidget({
    super.key,
    required this.groups,
    this.onGroupTap,
    this.onGroupLongPress,
  });

  @override
  State<GroupTreeWidget> createState() => _GroupTreeWidgetState();
}

class _GroupTreeWidgetState extends State<GroupTreeWidget> {
  final Set<int> _expandedNodes = <int>{};

  List<Group> getChildren(int parentId) {
    return widget.groups.where((g) => g.parentId == parentId).toList();
  }

  List<Group> getRootGroups() {
    return widget.groups.where((g) => g.parentId == null).toList();
  }

  Color getColorForType(String type) {
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

  IconData getIconForType(String type) {
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

  double getIndentLevel(String type) {
    switch (type) {
      case 'movement':
        return 0.0;
      case 'network':
        return 16.0;
      case 'fob':
        return 32.0;
      case 'location':
        return 48.0;
      case 'zone':
        return 64.0;
      case 'fellowship':
        return 80.0;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rootGroups = getRootGroups();
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: rootGroups.map((group) => _buildGroupNode(group, 0)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupNode(Group group, int depth) {
    final children = getChildren(group.id);
    final hasChildren = children.isNotEmpty;
    final isExpanded = _expandedNodes.contains(group.id);
    final color = getColorForType(group.type);
    final icon = getIconForType(group.type);
    final indent = depth * 24.0;

    return Column(
      children: [
        // Main group tile
        Container(
          margin: EdgeInsets.only(left: indent, right: 8, top: 4, bottom: 4),
          child: Material(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            elevation: 1,
            shadowColor: Colors.grey.withValues(alpha: 0.2),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => widget.onGroupTap?.call(group),
              onLongPress: () => widget.onGroupLongPress?.call(group),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Expansion arrow for nodes with children
                    if (hasChildren)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedNodes.remove(group.id);
                            } else {
                              _expandedNodes.add(group.id);
                            }
                          });
                        },
                        child: AnimatedRotation(
                          turns: isExpanded ? 0.25 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 20),
                    
                    const SizedBox(width: 8),
                    
                    // Group icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: color,
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Group information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  group.categoryName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: color,
                                  ),
                                ),
                              ),
                              if (hasChildren) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '${children.length} sub-groups',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Member count badge
                    if (group.memberCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${group.activeMembers}/${group.memberCount}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Children nodes
        if (hasChildren && isExpanded)
          ...children.map((child) => _buildGroupNode(child, depth + 1)),
      ],
    );
  }
}
