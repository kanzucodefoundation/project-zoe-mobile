import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  final String shepherdName;
  final String shepherdEmail;
  final String shepherdAvatar;
  final VoidCallback? onButtonPressed;
  final String buttonText;

  const ContactTile({
    super.key,
    required this.shepherdAvatar,
    required this.shepherdName,
    required this.shepherdEmail,
    this.onButtonPressed,
    this.buttonText = 'Contact',
  });

  // Get first letter for fallback avatar
  String getInitials() {
    if (shepherdName.isEmpty) return '?';
    final names = shepherdName.trim().split(' ');
    if (names.length >= 2) {
      return '${names.first[0]}${names.last[0]}'.toUpperCase();
    }
    return names.first[0].toUpperCase();
  }

  // Get different colors based on name hash
  MaterialColor getAvatarColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.pink,
    ];
    final hash = shepherdName.hashCode;
    return colors[hash.abs() % colors.length];
  }

  // Build network avatar with better error handling
  Widget buildNetworkAvatar(String url, double size) {
    // Validate URL first
    if (url.isEmpty || url == 'null') {
      return buildFallbackAvatar(size);
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: size,
      height: size,
      headers: {'User-Agent': 'Mozilla/5.0 (compatible; FlutterApp/1.0)'},
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        print(
          '🔄 Loading avatar for $shepherdName: ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}',
        );
        return Container(
          width: size,
          height: size,
          color: Colors.grey.shade200,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('🔍 Avatar Error for $shepherdName:');
        print('   URL: $url');
        print('   Error: $error');
        return buildFallbackAvatar(size);
      },
    );
  }

  // Build fallback avatar with initials
  Widget buildFallbackAvatar(double size) {
    final avatarColor = getAvatarColor();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: avatarColor.shade100,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          getInitials(),
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            color: avatarColor.shade700,
          ),
        ),
      ),
    );
  }

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
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Shepherd Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: ClipOval(child: buildNetworkAvatar(shepherdAvatar, 60)),
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
