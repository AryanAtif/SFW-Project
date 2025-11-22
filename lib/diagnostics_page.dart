import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'supabase_helper.dart';

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
      final supabase = Supabase.instance.client;
      try {
        // Try modern API
        await (supabase.auth as dynamic).signInWithPassword(email: email, password: pass);
      } catch (_) {
        // Fallback to older API
        await (supabase.auth as dynamic).signIn(email: email, password: pass);
      }
      final user = supabase.auth.currentUser;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signed in as ${user?.id ?? 'unknown'}')));
      setState(() {});
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
      final supabase = Supabase.instance.client;
      try {
        await (supabase.auth as dynamic).signUp(email: email, password: pass);
      } catch (_) {
        // older API fallback
        await (supabase.auth as dynamic).signUpWithPassword(email: email, password: pass);
      }
      final user = supabase.auth.currentUser;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registered and signed in as ${user?.id ?? 'unknown'}')));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Register failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    final supabase = Supabase.instance.client;
    try {
      await (supabase.auth as dynamic).signOut();
    } catch (_) {}
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed out')));
    setState(() {});
  }

  Future<void> _signInAnonymously() async {
    // Supabase does not support anonymous sign-in by default. Inform the user.
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anonymous sign-in is not supported by Supabase. Please create an account or sign in.')));
  }

  Future<void> _testUpload() async {
    setState(() => _loading = true);
    try {
      final filename = 'diagnostics/test_upload_${DateTime.now().millisecondsSinceEpoch}.txt';
      final path = filename;
      final bytes = Uint8List.fromList('diagnostics test upload ${DateTime.now().toIso8601String()}'.codeUnits);

      // Upload via helper which will use configured bucket and signed URL
      final fileUrl = await SupabaseHelper.uploadBytes(bytes, path, contentType: 'text/plain');
      if (fileUrl.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Test upload succeeded: $fileUrl')));
        debugPrint('Test upload succeeded at path=$path');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Test upload completed but no URL available')));
        debugPrint('Test upload completed but returned empty URL');
      }
    } catch (e, st) {
      debugPrint('Unexpected error during test upload: $e\n$st');
      final msg = e.toString();
      if (msg.contains('storage bucket') || msg.toLowerCase().contains('bucket')) {
        // Provide actionable guidance to fix common "bucket not found" misconfiguration.
        showDialog(context: context, builder: (ctx) => AlertDialog(
          title: const Text('Storage bucket error'),
          content: const Text('The storage upload failed and it looks like the configured bucket may not exist or your service role lacks permissions.\n\nPlease check your Supabase project Storage -> Buckets and either create the bucket or set SUPABASE_STORAGE_BUCKET in your .env to the correct bucket name.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ));
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Test upload failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
  final supabase = Supabase.instance.client;
  final appName = 'Supabase';
    final projectId = supabase.auth.currentUser?.id ?? 'n/a';
    final storageBucket = 'public';
    final user = supabase.auth.currentUser;

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
              Text('Supabase URL: $appName', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Current User ID: $projectId'),
              const SizedBox(height: 8),
              Text('Storage Bucket: $storageBucket'),
              const SizedBox(height: 16),
              Text('Auth', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (user == null) ...[
                const Text('No signed-in user'),
                const SizedBox(height: 8),
                const Text('Use Sign In / Register to authenticate with Supabase.'),
              ] else ...[
                Text('UID: ${user.id}'),
                Text('Email: ${user.email ?? 'n/a'}'),
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: _loading ? null : _signInWithEmail,
                    child: const Text('Sign In'),
                  ),
                  ElevatedButton(
                    onPressed: _loading ? null : _registerWithEmail,
                    child: const Text('Register'),
                  ),
                  ElevatedButton(
                    onPressed: _loading ? null : _signInAnonymously,
                    child: const Text('Sign In Anon'),
                  ),
                  ElevatedButton(
                    onPressed: (user == null || _loading) ? null : _signOut,
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open Supabase Console to review Storage rules')));
                },
                child: const Text('Open Supabase Console'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _testUpload,
                child: const Text('Test Upload to Storage'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
