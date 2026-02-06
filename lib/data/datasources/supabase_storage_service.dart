import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';
import '../../core/error/exceptions.dart';

/// Service for uploading images to Supabase Storage
/// Handles NIC uploads (private bucket) and lounge photos (public bucket)
class SupabaseStorageService {
  final SupabaseClient supabaseClient;

  SupabaseStorageService({required this.supabaseClient});

  /// Upload NIC image to private bucket
  /// Returns the private URL (requires authentication to access)
  Future<String> uploadNICImage({
    required File imageFile,
    required String userId,
    required String side, // 'front' or 'back'
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'nic_${userId}_${side}_$timestamp.jpg';
      final path = '$userId/$fileName';

      // Upload to nic_uploads bucket (private, max 2MB)
      await supabaseClient.storage
          .from(AppConfig.nicUploadsBucket)
          .upload(path, imageFile);

      // Get the signed URL (valid for a limited time)
      final url = supabaseClient.storage
          .from(AppConfig.nicUploadsBucket)
          .getPublicUrl(path);

      return url;
    } catch (e) {
      throw FileUploadException('Failed to upload NIC image: ${e.toString()}');
    }
  }

  /// Upload lounge photo to public bucket
  /// Returns the public URL (accessible without authentication)
  Future<String> uploadLoungePhoto({
    required File imageFile,
    required String loungeId,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'lounge_${loungeId}_$timestamp.jpg';
      final path = '$loungeId/$fileName';

      // Upload to lounge_photos bucket (public, max 5MB)
      await supabaseClient.storage
          .from(AppConfig.loungePhotosBucket)
          .upload(path, imageFile);

      // Get the public URL
      final url = supabaseClient.storage
          .from(AppConfig.loungePhotosBucket)
          .getPublicUrl(path);

      return url;
    } catch (e) {
      throw FileUploadException('Failed to upload lounge photo: ${e.toString()}');
    }
  }

  /// Delete an image from storage
  /// Can be used for both NIC and lounge photos
  Future<void> deleteImage({
    required String url,
    required bool isNICImage,
  }) async {
    try {
      // Extract the path from the URL
      final uri = Uri.parse(url);
      final path = uri.pathSegments.skip(4).join('/'); // Skip /storage/v1/object/public/bucket/

      final bucket = isNICImage 
          ? AppConfig.nicUploadsBucket 
          : AppConfig.loungePhotosBucket;

      await supabaseClient.storage
          .from(bucket)
          .remove([path]);
    } catch (e) {
      throw FileUploadException( 'Failed to delete image: ${e.toString()}');
    }
  }

  /// Upload multiple lounge photos
  /// Returns list of public URLs
  Future<List<String>> uploadMultipleLoungePhotos({
    required List<File> imageFiles,
    required String loungeId,
  }) async {
    final urls = <String>[];
    
    for (final imageFile in imageFiles) {
      final url = await uploadLoungePhoto(
        imageFile: imageFile,
        loungeId: loungeId,
      );
      urls.add(url);
    }

    return urls;
  }
}
