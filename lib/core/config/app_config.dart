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
  
  // Shipping API
  static const String rajaOngkirApiKey = 'KT5rZl7Za7026ad9c55b6e460w8Pks8M'; // Shipping cost API
  static const String rajaOngkirDeliveryApiKey = 'ZqAyVyOZa7026ad9c55b6e46pob5ybf1'; // Shipping delivery API
  static const String rajaOngkirBaseUrl = 'https://api.rajaongkir.com/starter';
  static const double defaultWeight = 1000; // gram
  static const List<String> supportedCouriers = ['jne', 'pos', 'tiki'];
}