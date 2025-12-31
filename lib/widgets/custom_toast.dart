import 'package:flutter/material.dart';

/// Custom toast widget that appears at the top of the screen
class CustomToast extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final Duration duration;
  final VoidCallback? onDismiss;

  const CustomToast({
    super.key,
    required this.message,
    this.backgroundColor = Colors.black87,
    this.textColor = Colors.white,
    this.icon,
    this.duration = const Duration(seconds: 3),
    this.onDismiss,
  });

  @override
  State<CustomToast> createState() => _CustomToastState();
}

class _CustomToastState extends State<CustomToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, -1),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticOut,
          ),
        );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: widget.textColor, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _dismiss,
                      child: Icon(
                        Icons.close,
                        color: widget.textColor.withValues(alpha: 0.7),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Toast helper class for showing custom toasts
class ToastHelper {
  static OverlayEntry? _currentToast;

  /// Show a success toast with green background and check icon
  static void showSuccess(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      backgroundColor: Colors.green.shade600,
      icon: Icons.check_circle_outline,
    );
  }

  /// Show an error toast with red background and error icon
  static void showError(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      backgroundColor: Colors.red.shade600,
      icon: Icons.error_outline,
    );
  }

  /// Show a warning toast with orange background and warning icon
  static void showWarning(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      backgroundColor: Colors.orange.shade600,
      icon: Icons.warning_amber_outlined,
    );
  }

  /// Show an info toast with blue background and info icon
  static void showInfo(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      backgroundColor: Colors.blue.shade600,
      icon: Icons.info_outline,
    );
  }

  /// Show a network error toast with appropriate messaging
  static void showNetworkError(BuildContext context, [String? customMessage]) {
    final message =
        customMessage ??
        'No internet connection detected. Please check your network and try again.';
    _showToast(
      context,
      message: message,
      backgroundColor: Colors.red.shade700,
      icon: Icons.wifi_off_outlined,
      duration: const Duration(seconds: 4),
    );
  }

  /// Show an authentication error toast
  static void showAuthError(BuildContext context, [String? customMessage]) {
    final message = customMessage ?? '🔐 Session expired. Please login again.';
    _showToast(
      context,
      message: message,
      backgroundColor: Colors.red.shade700,
      icon: Icons.lock_outline,
      duration: const Duration(seconds: 4),
    );
  }

  /// Smart error handler that detects error types and shows appropriate toast
  static void showSmartError(
    BuildContext context,
    dynamic error, [
    String? fallbackMessage,
  ]) {
    final errorString = error.toString().toLowerCase();

    // Check for server availability issues first (more specific)
    if (errorString.contains('connection refused') ||
        errorString.contains('connection closed') ||
        errorString.contains('empty reply from server') ||
        errorString.contains('server not available') ||
        errorString.contains('failed to connect') ||
        errorString.contains('econnrefused')) {
      showError(
        context,
        '🔧 Server is not responding. Please contact support or try again later.',
      );
    }
    // Check for actual network connectivity issues
    else if (errorString.contains('no internet connection') ||
        errorString.contains('network unreachable') ||
        errorString.contains('dns resolution failed') ||
        errorString.contains('socketexception: network is unreachable') ||
        errorString.contains('no address associated with hostname')) {
      showNetworkError(context);
    }
    // Check for timeout issues (could be server or network)
    else if (errorString.contains('timeout') ||
        errorString.contains('request timeout') ||
        errorString.contains('connection timeout')) {
      showError(
        context,
        '⏱️ Request timed out. Check your connection or try again later.',
      );
    }
    // Authentication errors
    else if (errorString.contains('unauthorized') ||
        errorString.contains('authentication') ||
        errorString.contains('login') ||
        errorString.contains('token')) {
      showAuthError(context);
    }
    // Server errors
    else if (errorString.contains('server error') ||
        errorString.contains('500') ||
        errorString.contains('internal server')) {
      showError(
        context,
        '🔧 Server is temporarily unavailable. Please try again later.',
      );
    }
    // Not found errors
    else if (errorString.contains('not found') || errorString.contains('404')) {
      showError(context, '🔍 Requested data not found.');
    }
    // Generic network-related errors (last resort)
    else if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('unreachable') ||
        errorString.contains('socket')) {
      showError(
        context,
        '🌐 Connection issue detected. Please check server status or try again later.',
      );
    } else {
      // Generic error with clean message
      final displayMessage =
          fallbackMessage ?? 'Something went wrong. Please try again.';
      showError(context, displayMessage);
    }
  }

  /// Show a custom toast with specified parameters
  static void _showToast(
    BuildContext context, {
    required String message,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Remove any existing toast
    _currentToast?.remove();

    final overlay = Overlay.of(context);
    _currentToast = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: CustomToast(
          message: message,
          backgroundColor: backgroundColor,
          textColor: textColor,
          icon: icon,
          duration: duration,
          onDismiss: () {
            _currentToast?.remove();
            _currentToast = null;
          },
        ),
      ),
    );

    overlay.insert(_currentToast!);
  }

  /// Hide current toast if showing
  static void hide() {
    _currentToast?.remove();
    _currentToast = null;
  }
}
