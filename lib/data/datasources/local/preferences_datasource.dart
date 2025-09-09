import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';

abstract class PreferencesDatasource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
  Future<void> setFirstLaunch(bool isFirstLaunch);
  Future<bool> isFirstLaunch();
  Future<void> setKeyboardEnabled(bool enabled);
  Future<bool> isKeyboardEnabled();
}

class PreferencesDatasourceImpl implements PreferencesDatasource {
  final SharedPreferences _prefs;
  
  static const String _cachedUserKey = 'CACHED_USER';
  static const String _firstLaunchKey = 'FIRST_LAUNCH';
  static const String _keyboardEnabledKey = 'KEYBOARD_ENABLED';
  
  PreferencesDatasourceImpl(this._prefs);

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await _prefs.setString(_cachedUserKey, userJson);
    } catch (e) {
      throw CacheException('Failed to cache user: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = _prefs.getString(_cachedUserKey);
      if (userJson == null) return null;
      
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      throw CacheException('Failed to get cached user: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _prefs.remove(_cachedUserKey);
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }

  @override
  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    try {
      await _prefs.setBool(_firstLaunchKey, isFirstLaunch);
    } catch (e) {
      throw CacheException('Failed to set first launch: $e');
    }
  }

  @override
  Future<bool> isFirstLaunch() async {
    try {
      return _prefs.getBool(_firstLaunchKey) ?? true;
    } catch (e) {
      throw CacheException('Failed to get first launch: $e');
    }
  }

  @override
  Future<void> setKeyboardEnabled(bool enabled) async {
    try {
      await _prefs.setBool(_keyboardEnabledKey, enabled);
    } catch (e) {
      throw CacheException('Failed to set keyboard enabled: $e');
    }
  }

  @override
  Future<bool> isKeyboardEnabled() async {
    try {
      return _prefs.getBool(_keyboardEnabledKey) ?? false;
    } catch (e) {
      throw CacheException('Failed to get keyboard enabled: $e');
    }
  }
}