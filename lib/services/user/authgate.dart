import 'package:flutter/material.dart';
import 'package:finalflutter/services/user/auth.dart';
import 'package:finalflutter/screens/todolist/itemslistscreen.dart';
import 'package:finalflutter/screens/user/signin.dart';

class AuthGate extends StatelessWidget {
  final AuthService _authService = AuthService();

  AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _authService.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.data != null) {
          return HeroListView(); // user is logged in
        } else {
          return SignIn(); // user is not logged in
        }
      },
    );
  }
}
