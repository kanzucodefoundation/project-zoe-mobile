import 'package:flutter/material.dart';

class ShepherdsTile extends StatelessWidget {
  final String shepherdName;
  final String shepherdEmail;
  final VoidCallback? onButtonPressed;
  final String buttonText;

  const ShepherdsTile({
    super.key,
    required this.shepherdName,
    required this.shepherdEmail,
    this.onButtonPressed,
    this.buttonText = 'Contact',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Shepherd Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade200,
            child: Icon(Icons.person, size: 35, color: Colors.grey.shade600),
          ),

          const SizedBox(width: 16),

          // Shepherd Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shepherdName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  shepherdEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),

          // Contact Button
          SizedBox(
            width: 80,
            height: 36,
            child: ElevatedButton(
              onPressed: onButtonPressed ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
