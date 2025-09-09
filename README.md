# Selly Clone - Keyboard Toko Online

Aplikasi Flutter untuk penjual online dengan keyboard terintegrasi yang memudahkan pengelolaan transaksi, invoice, dan komunikasi dengan pelanggan melalui WhatsApp dan Instagram.

## 🚀 Fitur Utama

### 📱 Keyboard Terintegrasi
- Custom keyboard untuk aplikasi chat (WhatsApp, Instagram, dll)
- Template pesan cepat (salam, promosi, konfirmasi pesanan)
- Aksi cepat (buat invoice, hitung ongkir, cek stok)
- Quick response dengan emoji dan format profesional

### 📊 Manajemen Invoice
- Buat invoice dengan mudah dan cepat
- Generate PDF otomatis dengan design profesional
- Share invoice langsung ke WhatsApp/email
- Tracking status pembayaran
- Riwayat invoice lengkap

### 🏪 Manajemen Produk
- Katalog produk dengan foto dan deskripsi
- Update stok real-time
- Kategori produk
- Search dan filter produk

### 🚚 Kalkulator Ongkir
- Hitung ongkir untuk JNE, J&T, SiCepat
- Pilihan layanan regular dan ekspres
- Estimasi waktu pengiriman
- Format pesan ongkir siap kirim

### 💰 Dashboard Analytics
- Statistik penjualan harian
- Total invoice dan pendapatan
- Grafik trend penjualan
- Laporan bulanan

## 🛠️ Teknologi

### Backend
- **Supabase**: Database PostgreSQL dengan real-time sync
- **Row Level Security**: Keamanan data per user
- **Storage**: Penyimpanan file PDF invoice

### Frontend
- **Flutter 3.x**: Framework UI cross-platform
- **BLoC Pattern**: State management yang scalable
- **Clean Architecture**: Arsitektur yang maintainable

### Dependencies Utama
```yaml
flutter_bloc: ^8.1.3           # State management
supabase_flutter: ^2.0.0       # Backend service
google_mobile_ads: ^4.0.0      # Monetisasi
pdf: ^3.10.0                   # Generate PDF
printing: ^5.11.0              # Print & share PDF
sqflite: ^2.3.0               # Local database
```

## 📋 Setup & Installation

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/selly-clone.git
cd selly-clone
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Get API Keys

**RajaOngkir API (Required for shipping calculator):**
1. Register at [RajaOngkir.com](https://rajaongkir.com)
2. Get your API key from dashboard
3. Update `lib/core/config/app_config.dart`:
```dart
static const String rajaOngkirApiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

### 4. Konfigurasi Supabase

1. Buat project baru di [Supabase](https://supabase.com)
2. Salin URL dan anon key ke `lib/core/config/supabase_config.dart`
3. Jalankan migration SQL untuk membuat tabel:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    business_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    last_active TIMESTAMP DEFAULT NOW()
);

-- Templates table
CREATE TABLE templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(100),
    content TEXT,
    category VARCHAR(50),
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Products table
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255),
    price DECIMAL(10,2),
    stock INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Invoices table
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    invoice_number VARCHAR(50) UNIQUE,
    customer_name VARCHAR(255),
    customer_phone VARCHAR(20),
    items JSONB,
    subtotal DECIMAL(12,2),
    shipping_cost DECIMAL(10,2),
    total DECIMAL(12,2),
    pdf_url TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

4. Enable Row Level Security untuk semua tabel di Supabase dashboard

### 4. Konfigurasi AdMob

1. Buat akun AdMob di [Google AdMob](https://admob.google.com)
2. Buat unit iklan banner dan interstitial
3. Update `lib/core/config/admob_config.dart` dengan ID iklan production
4. Update `android/app/src/main/AndroidManifest.xml` dengan App ID AdMob

### 5. Setup Firebase (Opsional)
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login dan konfigurasi
firebase login
flutterfire configure
```

### 6. Build & Run
```bash
# Development
flutter run

# Release
flutter build apk --release
```

## 🎯 Cara Menggunakan Keyboard

### 1. Aktifkan Keyboard
1. Buka Settings > System > Languages & input > Virtual keyboard
2. Pilih "Selly Keyboard" dan aktifkan
3. Kembali ke aplikasi dan pilih Selly sebagai keyboard default

### 2. Gunakan di WhatsApp/Instagram
1. Buka chat di WhatsApp atau Instagram
2. Ketuk area input text
3. Switch ke Selly Keyboard (icon keyboard di notification)
4. Pilih template atau aksi cepat yang diinginkan

### 3. Template Categories
- **Salam**: Ucapan selamat datang
- **Promosi**: Penawaran dan diskon
- **Konfirmasi**: Konfirmasi pesanan
- **Pengiriman**: Info pengiriman dan tracking

## 📱 Screenshot

| Dashboard | Invoice | Keyboard |
|-----------|---------|----------|
| ![Dashboard](screenshots/dashboard.png) | ![Invoice](screenshots/invoice.png) | ![Keyboard](screenshots/keyboard.png) |

## 🔒 Keamanan & Privacy

- Semua data user dienkripsi dengan Row Level Security
- Tidak ada data yang dibagikan ke pihak ketiga
- Local database untuk mode offline
- Automatic logout untuk keamanan

## 💡 Tips Penggunaan

1. **Template Efektif**: Buat template yang personal dan ramah
2. **Update Stok**: Selalu update stok produk untuk menghindari overselling
3. **Format Konsisten**: Gunakan format invoice yang konsisten
4. **Backup Data**: Aktifkan sync cloud untuk backup otomatis

## 🐛 Troubleshooting

### Keyboard tidak muncul
1. Pastikan sudah mengaktifkan di Settings
2. Restart aplikasi chat
3. Check permission di Android Settings

### PDF tidak generate
1. Check permission storage
2. Pastikan ada space yang cukup
3. Update aplikasi ke versi terbaru

### Sync error
1. Check koneksi internet
2. Logout dan login kembali
3. Clear app cache

## 🤝 Contributing

1. Fork repository
2. Buat feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

## 📞 Support

- Email: support@sellyapp.com
- WhatsApp: +62-XXX-XXXX-XXXX
- Telegram: @sellyapp

## 🎉 Credits

Dibuat dengan ❤️ untuk UMKM Indonesia

---

**Selly Clone** - Solusi lengkap untuk toko online Anda!