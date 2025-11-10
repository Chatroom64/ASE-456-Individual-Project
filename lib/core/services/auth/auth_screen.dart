import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../../../features/deck_list/deck_list_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoginMode = true;
  bool _loading = false;
  String? _errorMessage;

  Future<void> _handleAuth() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both username and password.';
        _loading = false;
      });
      return;
    }

    bool success;
    if (_isLoginMode) {
      success = await _authService.signIn(username, password);
      if (!success) {
        setState(() {
          _errorMessage = 'Invalid credentials.';
          _loading = false;
        });
        return;
      }
    } else {
      success = await _authService.signUp(username, password);
      if (!success) {
        setState(() {
          _errorMessage = 'An account already exists.';
          _loading = false;
        });
        return;
      }
    }

    // If successful, go to the deck list
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DeckListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isLoginMode ? 'Sign In' : 'Sign Up',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loading ? null : _handleAuth,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : Text(_isLoginMode ? 'Sign In' : 'Sign Up'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLoginMode = !_isLoginMode;
                      });
                    },
                    child: Text(_isLoginMode
                        ? "Don't have an account? Sign up"
                        : "Already have an account? Sign in"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
