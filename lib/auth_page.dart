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
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    setState(() => _loading = true);
    final supabase = Supabase.instance.client;
    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    try {
      try {
        await (supabase.auth as dynamic).signUpWithPassword(email: email, password: pass);
      } catch (_) {
        await (supabase.auth as dynamic).signUp(email: email, password: pass);
      }
      widget.onLoginSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Register failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown[600]),
              onPressed: _loading ? null : _signIn,
              child: _loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Sign In'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _loading ? null : _register,
              child: const Text('Register'),
            ),
            const SizedBox(height: 12),
            const Text('Accounts are persisted by Supabase. Once signed in the app will remember you.'),
          ],
        ),
      ),
    );
  }
}
