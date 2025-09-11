class AppConfig {
  static const String appName = 'Selly Clone';
  static const String appVersion = '1.0.0';
  static const String androidPackageName = 'com.yourcompany.selly';
  
  // Environment
  static const bool isProduction = false;
  
  // Database
  static const String localDbName = 'selly_local.db';
  static const int localDbVersion = 1;
  
  // Keyboard Service
  static const String keyboardServiceName = 'SellyKeyboardService';
  static const Duration keyboardLoadTimeout = Duration(seconds: 1);
  
  // PDF Generation
  static const String invoicePrefix = 'INV';
  static const String dateFormat = 'dd/MM/yyyy';
  
  // Shipping API - RajaOngkir Migration Status (2025)
  // NOTE: Old RajaOngkir API discontinued. New API requires enterprise account at collaborator.komerce.id
  // Using mock data until enterprise API key is available
  static const String rajaOngkirApiKey = 'DEMO_KEY_REQUIRES_ENTERPRISE_ACCOUNT'; // Requires enterprise account
  static const String rajaOngkirDeliveryApiKey = 'ZqAyVyOZa7026ad9c55b6e46pob5ybf1'; // Legacy delivery API  
  static const String rajaOngkirBaseUrl = 'https://api-sandbox.collaborator.komerce.id/tariff/api/v1';
  static const String rajaOngkirProdBaseUrl = 'https://api.collaborator.komerce.id/tariff/api/v1';
  static const double defaultWeight = 1000; // gram
  static const List<String> supportedCouriers = ['jne', 'pos', 'tiki', 'jnt', 'sicepat', 'idx', 'ninja'];
  
  // Development Configuration
  static const bool useMockShippingData = true; // Set false when enterprise API key available
}