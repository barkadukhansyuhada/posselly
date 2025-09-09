class Validators {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email wajib diisi';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }
  
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Kata sandi wajib diisi';
    }
    
    if (password.length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }
    
    return null;
  }
  
  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Konfirmasi kata sandi wajib diisi';
    }
    
    if (password != confirmPassword) {
      return 'Kata sandi tidak cocok';
    }
    
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }
  
  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return null; // Phone is optional
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(phone)) {
      return 'Format nomor telepon tidak valid';
    }
    
    return null;
  }
  
  static String? validatePrice(String? price) {
    if (price == null || price.isEmpty) {
      return 'Harga wajib diisi';
    }
    
    final parsedPrice = double.tryParse(price);
    if (parsedPrice == null || parsedPrice < 0) {
      return 'Harga harus berupa angka positif';
    }
    
    return null;
  }
  
  static String? validateQuantity(String? quantity) {
    if (quantity == null || quantity.isEmpty) {
      return 'Jumlah wajib diisi';
    }
    
    final parsedQuantity = int.tryParse(quantity);
    if (parsedQuantity == null || parsedQuantity <= 0) {
      return 'Jumlah harus berupa angka positif';
    }
    
    return null;
  }
  
  static String? validateWeight(String? weight) {
    if (weight == null || weight.isEmpty) {
      return 'Berat wajib diisi';
    }
    
    final parsedWeight = double.tryParse(weight);
    if (parsedWeight == null || parsedWeight <= 0) {
      return 'Berat harus berupa angka positif';
    }
    
    return null;
  }
}