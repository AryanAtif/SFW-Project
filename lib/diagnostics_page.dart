import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_auth/firebase_auth.dart';

class DiagnosticsPage extends StatefulWidget {
  const DiagnosticsPage({super.key});

  @override
  State<DiagnosticsPage> createState() => _DiagnosticsPageState();
}

class _DiagnosticsPageState extends State<DiagnosticsPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    setState(() => _loading = true);
    try {
      final email = _emailController.text.trim();
      final pass = _passwordController.text;
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signed in as ${cred.user?.uid}')));
      setState(() {});
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-in failed: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _registerWithEmail() async {
    setState(() => _loading = true);
    try {
      final email = _emailController.text.trim();
      final pass = _passwordController.text;
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pass);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registered and signed in as ${cred.user?.uid}')));
      setState(() {});
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Register failed: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Register failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed out')));
    setState(() {});
  }

  Future<void> _signInAnonymously() async {
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.signInAnonymously();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Anonymous sign-in: ${cred.user?.uid}')));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Anonymous sign-in failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String appName = 'n/a';
    String projectId = 'n/a';
    String storageBucket = 'n/a';
    try {
      final app = Firebase.app();
      appName = app.name;
  projectId = app.options.projectId;
  storageBucket = app.options.storageBucket ?? storageBucket;
    } catch (e) {
      // ignore
    }

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        backgroundColor: Colors.brown.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Firebase App: $appName', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Project ID: $projectId'),
              const SizedBox(height: 8),
              Text('Storage Bucket: $storageBucket'),
              const SizedBox(height: 16),
              Text('Auth', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (user == null) ...[
                const Text('No signed-in user'),
                const SizedBox(height: 8),
                const Text('If you expect anonymous sign-in to work, ensure Anonymous sign-in is enabled in Firebase Console → Authentication → Sign-in method.'),
              ] else ...[
                Text('UID: ${user.uid}'),
                Text('IsAnonymous: ${user.isAnonymous}'),
              ],
              const SizedBox(height: 16),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _loading ? null : _signInWithEmail,
                    child: const Text('Sign In'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _loading ? null : _registerWithEmail,
                    child: const Text('Register'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _loading ? null : _signInAnonymously,
                    child: const Text('Sign In Anon'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: (user == null || _loading) ? null : _signOut,
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open Firebase Console to review Storage rules')));
                },
                child: const Text('Open Firebase Console'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
