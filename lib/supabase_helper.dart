import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Small helper utilities for uploading files and retrieving URLs from
/// Supabase Storage. This centralizes signed-url logic so the rest of the
/// app can remain storage-provider-agnostic.
class SupabaseHelper {
  SupabaseHelper._();

  /// Upload [bytes] to [bucket] at [path]. Returns the URL (signed or public)
  /// depending on [signed] and whether the bucket is configured to be private.
  static Future<String> uploadBytes(
    Uint8List bytes,
    String path, {
    String bucket = 'public',
    String contentType = 'application/octet-stream',
    bool signed = false,
    int signedExpiry = 3600, // seconds
  }) async {
    final storage = Supabase.instance.client.storage;

    // Ensure the parent folders are created implicitly by upserting the file
    try {
      await storage.from(bucket).uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: contentType),
      );
    } catch (e) {
      rethrow;
    }

    return getFileUrl(path, bucket: bucket, signed: signed, signedExpiry: signedExpiry);
  }

  /// Get file URL for [path] in [bucket]. If [signed] is true we request a
  /// signed URL from Supabase Storage that expires in [signedExpiry] seconds.
  static Future<String> getFileUrl(
    String path, {
    String bucket = 'public',
    bool signed = false,
    int signedExpiry = 3600,
  }) async {
    final storage = Supabase.instance.client.storage;
    try {
      if (signed) {
        final res = await storage.from(bucket).createSignedUrl(path, signedExpiry);
        return res.toString();
      }

      final publicUrl = storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }
}
