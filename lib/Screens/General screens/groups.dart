import 'package:flutter/material.dart';
import '../../models/group.dart';
import '../../widgets/group_tree_widget.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final List<Group> groups = [
    Group(
      id: 1,
      name: "Worship Harvest Global",
      type: "movement",
      categoryId: 6,
      categoryName: "Movement",
      privacy: "Public",
      details: "Global movement spanning multiple continents",
      parentId: null,
      memberCount: 0,
      activeMembers: 0,
    ),
    Group(
      id: 2,
      name: "Africa Network",
      type: "network",
      categoryId: 5,
      categoryName: "Network",
      privacy: "Public",
      details: "African church network",
      parentId: 1,
      memberCount: 0,
      activeMembers: 0,
    ),
    Group(
      id: 3,
      name: "Europe Network",
      type: "network",
      categoryId: 5,
      categoryName: "Network",
      privacy: "Public",
      details: "European church network",
      parentId: 1,
      memberCount: 0,
      activeMembers: 0,
    ),
    Group(
      id: 4,
      name: "East Africa FOB",
      type: "fob",
      categoryId: 4,
      categoryName: "Forward Operating Base",
      privacy: "Public",
      details: "East African forward operating base",
      parentId: 2,
      memberCount: 0,
      activeMembers: 0,
    ),
    Group(
      id: 5,
      name: "Western Europe FOB",
      type: "fob",
      categoryId: 4,
      categoryName: "Forward Operating Base",
      privacy: "Public",
      details: "Western European base",
      parentId: 3,
      memberCount: 0,
      activeMembers: 0,
    ),
    Group(
      id: 10,
      name: "Kampala Location",
      type: "location",
      categoryId: 3,
      categoryName: "Location",
      privacy: "Public",
      details: "Main Kampala church location",
      parentId: 4,
      memberCount: 0,
      activeMembers: 0,
      address: {
        "country": "Uganda",
        "district": "Kampala",
        "freeForm": "Plot 15, Ntinda Road",
      },
    ),
    Group(
      id: 11,
      name: "Kigali Location",
      type: "location",
      categoryId: 3,
      categoryName: "Location",
      privacy: "Public",
      details: "Kigali church location",
      parentId: 4,
      memberCount: 0,
      activeMembers: 0,
      address: {
        "country": "Rwanda",
        "district": "Kigali",
        "freeForm": "KN 3 Ave, Kimihurura",
      },
    ),
    Group(
      id: 20,
      name: "North Zone Kampala",
      type: "zone",
      categoryId: 2,
      categoryName: "Zone",
      privacy: "Public",
      details: "North Kampala zone covering Ntinda, Nakawa",
      parentId: 10,
      memberCount: 0,
      activeMembers: 0,
    ),
    Group(
      id: 21,
      name: "South Zone Kampala",
      type: "zone",
      categoryId: 2,
      categoryName: "Zone",
      privacy: "Public",
      details: "South Kampala zone",
      parentId: 10,
      memberCount: 0,
      activeMembers: 0,
    ),
    Group(
      id: 22,
      name: "Central Zone Kampala",
      type: "zone",
      categoryId: 2,
      categoryName: "Zone",
      privacy: "Public",
      details: "Central Kampala zone",
      parentId: 10,
      memberCount: 0,
      activeMembers: 0,
    ),
    Group(
      id: 100,
      name: "Phase MC",
      type: "fellowship",
      categoryId: 1,
      categoryName: "Missional Community",
      privacy: "Public",
      details: "Weekly fellowship meeting",
      parentId: 20,
      memberCount: 8,
      activeMembers: 7,
      metaData: GroupMetaData(meetingDay: "Thursday", meetingTime: "19:00"),
    ),
    Group(
      id: 101,
      name: "Grace & Truth MC",
      type: "fellowship",
      categoryId: 1,
      categoryName: "Missional Community",
      privacy: "Public",
      details: "Weekly fellowship meeting",
      parentId: 20,
      memberCount: 6,
      activeMembers: 5,
      metaData: GroupMetaData(meetingDay: "Thursday", meetingTime: "19:00"),
    ),
    Group(
      id: 110,
      name: "Kingdom MC",
      type: "fellowship",
      categoryId: 1,
      categoryName: "Missional Community",
      privacy: "Public",
      details: "Weekly fellowship meeting",
      parentId: 22,
      memberCount: 6,
      activeMembers: 5,
      metaData: GroupMetaData(meetingDay: "Monday", meetingTime: "19:00"),
    ),
    Group(
      id: 111,
      name: "Lighthouse MC",
      type: "fellowship",
      categoryId: 1,
      categoryName: "Missional Community",
      privacy: "Public",
      details: "Weekly fellowship meeting",
      parentId: 22,
      memberCount: 5,
      activeMembers: 4,
      metaData: GroupMetaData(meetingDay: "Monday", meetingTime: "19:00"),
    ),
    Group(
      id: 112,
      name: "Harvest MC",
      type: "fellowship",
      categoryId: 1,
      categoryName: "Missional Community",
      privacy: "Public",
      details: "Weekly fellowship meeting",
      parentId: 22,
      memberCount: 4,
      activeMembers: 3,
      metaData: GroupMetaData(meetingDay: "Wednesday", meetingTime: "19:00"),
    ),
  ];

  List<Group> getChildren(int parentId) {
    return groups.where((g) => g.parentId == parentId).toList();
  }

  List<Group> getRootGroups() {
    return groups.where((g) => g.parentId == null).toList();
  }

  Color getColorForType(String type) {
    switch (type) {
      case 'movement':
        return Colors.purple;
      case 'network':
        return Colors.blue;
      case 'fob':
        return Colors.teal;
      case 'location':
        return Colors.orange;
      case 'zone':
        return Colors.green;
      case 'fellowship':
        return Colors.pink;
      default:
        return Colors.grey;
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

  void showGroupDetails(BuildContext context, Group group) {
    // Get children groups
    final children = groups.where((g) => g.parentId == group.id).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(group.name)),
            if (children.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${children.length} sub',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow('Type', group.categoryName),
              _DetailRow('Privacy', group.privacy),
              _DetailRow('Details', group.details),
              if (group.memberCount > 0) ...[
                const Divider(),
                _DetailRow('Members', '${group.memberCount}'),
                _DetailRow('Active Members', '${group.activeMembers}'),
              ],
              if (children.isNotEmpty) ...[
                const Divider(),
                Text(
                  'Sub-Groups:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...children
                    .map(
                      (child) => Card(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.folder,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          title: Text(
                            child.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${child.type.toUpperCase()} • ${child.memberCount} members',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            showGroupDetails(context, child);
                          },
                        ),
                      ),
                    )
                    .toList(),
              ],
              if (group.address != null) ...[
                const Divider(),
                Text('Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${group.address!['freeForm']}'),
                Text(
                  '${group.address!['district']}, ${group.address!['country']}',
                ),
              ],
              if (group.metaData != null) ...[
                const Divider(),
                Text(
                  'Meeting Schedule:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${group.metaData!.meetingDay} at ${group.metaData!.meetingTime}',
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget buildGroupTile(Group group) {
    final children = getChildren(group.id);
    final hasChildren = children.isNotEmpty;
    final color = getColorForType(group.type);
    final icon = getIconForType(group.type);

    if (hasChildren) {
      return ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${group.categoryName} • ${children.length} sub-groups',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (group.memberCount > 0)
              Chip(
                label: Text(
                  '${group.activeMembers}/${group.memberCount}',
                  style: const TextStyle(fontSize: 10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => showGroupDetails(context, group),
              tooltip: 'View Details',
            ),
          ],
        ),
        children: children.map((child) => buildGroupTile(child)).toList(),
      );
    } else {
      return ListTile(
        leading: Icon(icon, color: color),
        title: Text(group.name),
        subtitle: Text(
          group.categoryName,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (group.memberCount > 0)
              Chip(
                label: Text(
                  '${group.activeMembers}/${group.memberCount}',
                  style: const TextStyle(fontSize: 10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => showGroupDetails(context, group),
              tooltip: 'View Details',
            ),
          ],
        ),
      );
    }
  }

  bool _useSimpleView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Church Groups'),
        elevation: 2,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (value == 'simple') {
                  _useSimpleView = true;
                } else if (value == 'tree') {
                  _useSimpleView = false;
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'simple', child: Text('Simple List')),
              const PopupMenuItem(value: 'tree', child: Text('Tree View')),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_useSimpleView) {
      return _buildSimpleListView();
    }

    try {
      return GroupTreeWidget(
        groups: groups,
        onGroupTap: (group) => showGroupDetails(context, group),
        onGroupLongPress: (group) => _showGroupOptions(context, group),
      );
    } catch (e) {
      // Fallback to simple list if tree rendering fails
      return _buildSimpleListView();
    }
  }

  Widget _buildSimpleListView() {
    final rootGroups = getRootGroups();
    return ListView(
      padding: const EdgeInsets.all(8),
      children: rootGroups.map((group) => buildGroupTile(group)).toList(),
    );
  }

  void _showGroupOptions(BuildContext context, Group group) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                showGroupDetails(context, group);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('View Members'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to members screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('View Reports'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to group reports
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
