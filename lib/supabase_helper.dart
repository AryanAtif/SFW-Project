import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    String? bucket,
    String contentType = 'application/octet-stream',
    bool? signed,
    int signedExpiry = 3600, // seconds
  }) async {
    final storage = Supabase.instance.client.storage;
    // Resolve defaults from environment
    String? defaultBucket;
    try {
      defaultBucket = dotenv.env['SUPABASE_STORAGE_BUCKET'];
    } catch (_) {
      defaultBucket = null;
    }
    defaultBucket ??= 'bucket1';  // Changed from 'public' to match your setup
    final bucketToUse = bucket ?? defaultBucket;
    bool bucketPrivate = false;
    try {
      bucketPrivate = (dotenv.env['SUPABASE_BUCKET_PRIVATE'] ?? 'false').toLowerCase() == 'true';
    } catch (_) {
      bucketPrivate = false;
    }
    final signedToUse = signed ?? bucketPrivate;

    try {
      await storage.from(bucketToUse).uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: contentType),
      );
    } catch (e) {
      final msg = e.toString();
      bool uploadSucceeded = false;
      
      // If the error is a missing bucket and a service role key is available,
      // attempt to create the bucket automatically (useful for initial setup).
      if (msg.toLowerCase().contains('bucket not found') || msg.toLowerCase().contains('bucket')) {
        final serviceKey = () {
          try {
            return dotenv.env['SUPABASE_SERVICE_KEY'];
          } catch (_) {
            return null;
          }
        }();

        final supabaseUrl = () {
          try {
            return dotenv.env['SUPABASE_URL'];
          } catch (_) {
            return null;
          }
        }();

        if (serviceKey != null && supabaseUrl != null) {
          try {
            // Create an admin client using the service role key and attempt
            // to create the missing bucket. Use dynamic calls to be resilient
            // to small SDK differences.
            final admin = SupabaseClient(supabaseUrl, serviceKey);
            try {
              await (admin.storage as dynamic).createBucket(bucketToUse, public: !bucketPrivate);
            } catch (_) {
              // Some SDK versions expect different parameter names.
              try {
                await (admin.storage as dynamic).createBucket(bucketToUse);
              } catch (_) {
                // ignore - creation failed, will retry with original storage client
              }
            }

            // Retry upload once with the default (anon) client
            try {
              await storage.from(bucketToUse).uploadBinary(
                path,
                bytes,
                fileOptions: FileOptions(contentType: contentType),
              );
              uploadSucceeded = true;
            } catch (_) {
              // Retry failed; re-throw the original error below
            }
          } catch (_) {
            // Admin client creation failed; will throw original error below
          }
        }
      }

      // If upload succeeded after auto-create, return the URL.
      // Otherwise, provide a clearer message if the bucket doesn't exist or permissions fail.
      if (!uploadSucceeded) {
        throw Exception('Failed to upload to storage bucket "$bucketToUse": $e');
      }
    }

    return getFileUrl(path, bucket: bucketToUse, signed: signedToUse, signedExpiry: signedExpiry);
  }

  /// Get file URL for [path] in [bucket]. If [signed] is true we request a
  /// signed URL from Supabase Storage that expires in [signedExpiry] seconds.
  static Future<String> getFileUrl(
    String path, {
    String? bucket,
    bool signed = false,
    int signedExpiry = 3600,
  }) async {
    final storage = Supabase.instance.client.storage;
    String? defaultBucket2;
    try {
      defaultBucket2 = dotenv.env['SUPABASE_STORAGE_BUCKET'];
    } catch (_) {
      defaultBucket2 = null;
    }
    defaultBucket2 ??= 'bucket1';  // Changed from 'public' to match your setup
    final bucketToUse = bucket ?? defaultBucket2;
    bool bucketPrivate2 = false;
    try {
      bucketPrivate2 = (dotenv.env['SUPABASE_BUCKET_PRIVATE'] ?? 'false').toLowerCase() == 'true';
    } catch (_) {
      bucketPrivate2 = false;
    }
  final signedToUse = signed || bucketPrivate2;

    try {
      if (signedToUse) {
        final res = await storage.from(bucketToUse).createSignedUrl(path, signedExpiry);
        return res.toString();
      }

        final publicUrl = storage.from(bucketToUse).getPublicUrl(path);
        return publicUrl;
    } catch (e) {
      throw Exception('Failed to obtain URL for $path in bucket "$bucketToUse": $e');
    }
  }
}
