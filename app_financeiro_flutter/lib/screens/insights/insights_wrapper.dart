import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import 'insights_screen.dart';

class InsightsWrapper extends StatelessWidget {
  const InsightsWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthService().getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final token = snapshot.data ?? '';
        
        return InsightsScreen(
          token: token,
          baseUrl: 'http://127.0.0.1:8000',
        );
      },
    );
  }
}

