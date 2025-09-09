import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/errors/exceptions.dart' as app_exceptions;
import '../../models/user_model.dart';

abstract class SupabaseDatasource {
  Future<UserModel> login({
    required String email,
    required String password,
  });
  
  Future<UserModel> register({
    required String email,
    required String password,
    required String businessName,
    String? phone,
  });
  
  Future<void> logout();
  
  Future<UserModel?> getCurrentUser();
  
  Future<void> updateProfile({
    String? businessName,
    String? phone,
  });
  
  Stream<UserModel?> get authStateChanges;
}

class SupabaseDatasourceImpl implements SupabaseDatasource {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw const app_exceptions.AuthException('Login gagal');
      }
      
      // Get user profile from users table; fallback to auth user if missing
      UserModel userProfile;
      try {
        userProfile = await _getUserProfile(response.user!.id);
      } catch (e) {
        // Fallback if profile query fails
        final u = response.user!;
        userProfile = UserModel(
          id: u.id,
          email: u.email ?? email,
          phone: null,
          businessName: 'Toko',
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
      }
      
      // Update last active
      await _updateLastActive(response.user!.id);
      
      return userProfile;
    } on AuthException {
      throw const app_exceptions.AuthException('Email atau kata sandi salah');
    } catch (e) {
      throw app_exceptions.ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String businessName,
    String? phone,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw const app_exceptions.AuthException('Registrasi gagal');
      }
      
      // Create user profile in users table
      final userData = {
        'id': response.user!.id,
        'email': email,
        'business_name': businessName,
        'phone': phone,
        'created_at': DateTime.now().toIso8601String(),
        'last_active': DateTime.now().toIso8601String(),
      };
      
      await _client
          .from(SupabaseConfig.usersTable)
          .insert(userData);
      
      return UserModel.fromJson({
        ...userData,
        'created_at': DateTime.now().toIso8601String(),
        'last_active': DateTime.now().toIso8601String(),
      });
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('over_email_send_rate_limit') || msg.contains('429')) {
        throw const app_exceptions.AuthException(
          'Terlalu banyak permintaan. Coba lagi dalam 60 detik atau gunakan email lain.',
        );
      }
      // Bubble up with original message for other auth errors
      throw app_exceptions.AuthException(e.message);
    } catch (e) {
      throw app_exceptions.ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw app_exceptions.ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;
      try {
        return await _getUserProfile(user.id);
      } catch (_) {
        // Fallback to auth user if profile not found
        return UserModel(
          id: user.id,
          email: user.email ?? '',
          phone: null,
          businessName: 'Toko',
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
      }
    } catch (e) {
      throw app_exceptions.ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateProfile({
    String? businessName,
    String? phone,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw const app_exceptions.AuthException('User not authenticated');
      
      final updateData = <String, dynamic>{};
      if (businessName != null) updateData['business_name'] = businessName;
      if (phone != null) updateData['phone'] = phone;
      updateData['last_active'] = DateTime.now().toIso8601String();
      
      await _client
          .from(SupabaseConfig.usersTable)
          .update(updateData)
          .eq('id', user.id);
    } catch (e) {
      throw app_exceptions.ServerException(message: e.toString());
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((data) {
      if (data.session?.user == null) return null;
      
      // Note: This would require additional implementation to fetch user profile
      // For now, returning null when auth state changes
      return null;
    });
  }

  Future<UserModel> _getUserProfile(String userId) async {
    // Try to fetch user profile; handle missing row gracefully
    final response = await _client
        .from(SupabaseConfig.usersTable)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response != null) {
      return UserModel.fromJson(Map<String, dynamic>.from(response));
    }

    // If no profile row exists, create a minimal default profile
    final authUser = _client.auth.currentUser;
    final userData = {
      'id': userId,
      'email': authUser?.email,
      'business_name': 'Toko',
      'phone': null,
      'created_at': DateTime.now().toIso8601String(),
      'last_active': DateTime.now().toIso8601String(),
    };

    await _client.from(SupabaseConfig.usersTable).insert(userData);
    return UserModel.fromJson(userData);
  }

  Future<void> _updateLastActive(String userId) async {
    await _client
        .from(SupabaseConfig.usersTable)
        .update({'last_active': DateTime.now().toIso8601String()})
        .eq('id', userId);
  }
}
