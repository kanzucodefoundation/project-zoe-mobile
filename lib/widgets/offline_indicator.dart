import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme.dart';
import '../services/connectivity_service.dart';

/// A widget that displays when the user is offline
class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, child) {
        if (connectivityService.isOnline) {
          return const SizedBox.shrink(); // Don't show anything when online
        }

        return Container(
          width: double.infinity,
          color: Colors.red.shade600,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'No internet connection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A full-screen offline message for critical screens
class OfflineScreen extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const OfflineScreen({
    super.key,
    this.title = 'No Internet Connection',
    this.message = 'This app requires an internet connection to function. Please check your connection and try again.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                size: 100,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (onRetry != null)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A card-style offline message for sections within screens
class OfflineMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const OfflineMessage({
    super.key,
    this.message = 'No internet connection. Please check your connection and try again.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.orange.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Offline',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.orange.shade700,
              fontSize: 14,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}