import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'main.dart';
// no direct model imports needed here

/// A simple authentication gate. If a Supabase user session exists we show
/// the app (`MainScaffold`), otherwise we show a small login/register UI.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      // Already signed in, proceed to the main scaffold.
      return const MainScaffold();
    }

    // Not signed in yet: show login page and when login succeeds rebuild.
    return LoginPage(onLoginSuccess: () => setState(() {}));
  }
}

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginPage({required this.onLoginSuccess, super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nameController = TextEditingController();
  bool _loading = false;
  bool _isRegister = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _loading = true);
    final supabase = Supabase.instance.client;
    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    try {
      try {
        await (supabase.auth as dynamic).signInWithPassword(email: email, password: pass);
      } catch (_) {
        await (supabase.auth as dynamic).signIn(email: email, password: pass);
      }
      // Success — callback to AuthGate which will show the app.
      widget.onLoginSuccess();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    setState(() => _loading = true);
    final supabase = Supabase.instance.client;
    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    final confirm = _confirmController.text;
    final name = _nameController.text.trim();

    if (pass != confirm) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      setState(() => _loading = false);
      return;
    }

    try {
      try {
        await (supabase.auth as dynamic).signUpWithPassword(email: email, password: pass, options: {'data': {'name': name}});
      } catch (_) {
        await (supabase.auth as dynamic).signUp(email: email, password: pass);
      }

      // If signup returned a user or a session, consider the user logged in.
      final user = supabase.auth.currentUser;
      if (user != null) {
        widget.onLoginSuccess();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful — check your email to confirm your account')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Register failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isRegister ? 'Register' : 'Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isRegister) TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full name (optional)')),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              if (_isRegister) ...[
                const SizedBox(height: 8),
                TextField(controller: _confirmController, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm password')),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown[600]),
                onPressed: _loading ? null : (_isRegister ? _register : _signIn),
                child: _loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_isRegister ? 'Register' : 'Sign In'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loading ? null : () => setState(() => _isRegister = !_isRegister),
                child: Text(_isRegister ? 'Already have an account? Sign in' : 'Don\'t have an account? Register'),
              ),
              const SizedBox(height: 12),
              const Text('Accounts are persisted by Supabase. Once signed in the app will remember you.'),
            ],
          ),
        ),
      ),
    );
  }
}
