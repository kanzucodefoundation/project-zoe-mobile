// import 'package:flutter/material.dart';

// class CustomBottomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;

//   const CustomBottomNavBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 80,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(25),
//           topRight: Radius.circular(25),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           // Reports Button (Left)
//           _buildNavItem(
//             icon: Icons.assessment,
//             label: 'Reports',
//             index: 0,
//             isSelected: currentIndex == 0,
//           ),
          
//           // Dashboard Button (Center - Large)
//           _buildCenterNavItem(),
          
//           // Admin Button (Right)
//           _buildNavItem(
//             icon: Icons.admin_panel_settings,
//             label: 'Admin',
//             index: 2,
//             isSelected: currentIndex == 2,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required IconData icon,
//     required String label,
//     required int index,
//     required bool isSelected,
//   }) {
//     return GestureDetector(
//       onTap: () => onTap(index),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: isSelected 
//                     ? Colors.black.withOpacity(0.1)
//                     : Colors.transparent,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 icon,
//                 size: 24,
//                 color: isSelected ? Colors.black : Colors.grey.shade600,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 color: isSelected ? Colors.black : Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCenterNavItem() {
//     return GestureDetector(
//       onTap: () => onTap(1),
//       child: Container(
//         width: 70,
//         height: 70,
//         decoration: BoxDecoration(
//           color: currentIndex == 1 ? Colors.black : Colors.grey.shade800,
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.dashboard,
//               color: Colors.white,
//               size: 28,
//             ),
//             const SizedBox(height: 2),
//             const Text(
//               'Dashboard',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }