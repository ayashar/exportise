# Exportise

Exportise adalah aplikasi mobile yang membantu UMKM menilai kesiapan produk
untuk pasar ekspor, mendapatkan insight pasar, melihat rekomendasi desain, dan
berdiskusi dengan BrainStudio sebagai asisten pengembangan produk.

Project ini dibuat untuk internal hackathon Google Developers Group on Campus
(GDGoC) UGM oleh Kelompok 5, tim Wong Limo.

## Team

- Hustler: Mardhiyah Sri Winarni
- Hipster: Ayu Atikah
- Hacker (Back-End): Muhammad Adib Naziri
- Hacker (Front-End): Ayasha Rahmadinni

## Main Features

- Onboarding dan autentikasi pengguna.
- Analisis kesiapan ekspor berdasarkan nama, kategori, dan deskripsi produk.
- Ringkasan hasil analisis, skor kesiapan, insight pasar, warna, harga, dan peluang.
- Design Reference untuk rekomendasi variasi visual produk.
- BrainStudio untuk diskusi ide produk dari awal maupun lanjutan dari hasil analisis.
- Laporanku untuk riwayat hasil analisis dan referensi desain.
- Profile dan notification screen.

## Tech Stack

- Flutter untuk aplikasi mobile front-end.
- Dart sebagai bahasa utama aplikasi.
- HTTP client untuk komunikasi REST API.
- Backend terpisah: [Nazirii/GDGOC_BE](https://github.com/Nazirii/GDGOC_BE).

Secara default, data runtime berasal dari backend melalui endpoint yang
dikonfigurasi di `lib/core/api/api_config.dart`. Base URL dapat dioverride saat
build/run dengan `API_BASE_URL`.

Saat backend tidak tersedia, aplikasi menyediakan temporary reviewer login agar
penilai tetap dapat masuk dan melihat flow zero-state:

```text
Email: exportise@contoh.com
Password: Exportise123
```

## Getting Started

Pastikan Flutter sudah terpasang, lalu jalankan:

```bash
flutter pub get
flutter run
```

Jika backend berjalan di host khusus:

```bash
flutter run --dart-define=API_BASE_URL=http://your-backend-url
```

Untuk emulator Android lokal, default API base URL adalah:

```text
http://10.0.2.2:3000
```

## Build APK

Untuk membuat APK release:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release --build-name=1.0.0 --build-number=1
```

Output APK:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Jika ingin menggunakan backend production/staging:

```bash
flutter build apk --release \
  --build-name=1.0.0 \
  --build-number=1 \
  --dart-define=API_BASE_URL=https://your-backend-url
```

## Repository

- Front-End: this repository
- Back-End: [Nazirii/GDGOC_BE](https://github.com/Nazirii/GDGOC_BE)
