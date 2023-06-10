import 'package:cetalks/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text('Account'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outlined,
                size: 60,
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                authProvider.userName,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  if (authProvider.isLoggedIn) {
                    await Provider.of<AuthProvider>(context, listen: false)
                        .logout();
                  } else {
                    await Provider.of<AuthProvider>(context, listen: false)
                        .login();
                  }
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white)),
                child: Text(
                  authProvider.isLoggedIn ? 'Logout' : 'Login With Google',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 16),
              if (!authProvider.isLoggedIn)
                Text('Login to interact with CETALKS',
                    style: TextStyle(color: Colors.white60)),
            ],
          ),
        ),
      ),
    );
  }
}
