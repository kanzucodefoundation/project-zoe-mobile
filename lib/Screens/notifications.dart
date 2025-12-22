import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:project_zoe/services/notification_service.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body:  Center(
        child: ElevatedButton(
          onPressed: () {
            notificationService.showNotification(
              title: 'Test Notification',
              body: 'This is a test notification body.',
            );
          }, 
          child: const Text('Send Notification'),
        ),
      ),
    );
  }
}