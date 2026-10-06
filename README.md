<div align="center">

<img src="./assets/icons/streambeats_logo.png" alt="StreamBeats Logo" width="160">

# 🎵 StreamBeats

**Pemutar Musik Hybrid Lintas Platform (Lokal & Streaming) Canggih yang Didukung oleh Flutter & Rust.**

[![GitHub Release](https://img.shields.io/github/v/release/DuskCipher/StreamBeats?display_name=release&style=for-the-badge&color=f01d7c)](https://github.com/DuskCipher/StreamBeats/releases/latest)
[![GitHub Downloads](https://img.shields.io/github/downloads/DuskCipher/StreamBeats/total?style=for-the-badge&label=DOWNLOADS&color=25D366)](https://github.com/DuskCipher/StreamBeats/releases/latest)
[![GitHub License](https://img.shields.io/github/license/DuskCipher/StreamBeats?style=for-the-badge&color=1881cc)](https://github.com/DuskCipher/StreamBeats/blob/master/LICENSE)
[![Build Status](https://img.shields.io/github/actions/workflow/status/DuskCipher/StreamBeats/checkout.yml?style=for-the-badge)](https://github.com/DuskCipher/StreamBeats/actions)

<div style="margin: 10px 0;">
  <img src="https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white">
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white">
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black">
</div>

---

**StreamBeats** adalah pemutar musik modern, open-source, dan berfokus pada privasi yang dirancang untuk menyatukan musik Anda di satu tempat. Dengan menggabungkan performa tinggi pustaka audio lokal Anda dan fleksibilitas streaming online melalui arsitektur plugin **Rust** (`.bex`) yang aman, StreamBeats menghadirkan pengalaman mendengarkan musik premium tanpa batas. **Tanpa iklan, tanpa login akun, tanpa pelacakan data.**

</div>

---

## Jaminan Keamanan & Sumber Resmi
Untuk melindungi perangkat Anda dari APK palsu yang dimodifikasi secara ilegal oleh pihak ketiga:
- **Situs Resmi & Unduhan Aman**:
  - Halaman Rilis GitHub: [Rilis Resmi StreamBeats](https://github.com/DuskCipher/StreamBeats/releases)
  - Halaman Web Resmi: [duskcipher.github.io/StreamBeats](https://duskcipher.github.io/StreamBeats/)

> [!WARNING]
> Jangan pernah mengunduh installer StreamBeats dari luar sumber resmi di atas. Kami tidak bertanggung jawab atas kerusakan sistem atau pelanggaran privasi akibat penggunaan file dari pihak ketiga.

---

## Fitur Utama StreamBeats

- **Bebas Iklan Selamanya:** Nikmati musik favorit tanpa jeda iklan atau interupsi komersial.
- **Plugin Engine Berbasis Rust:** Menggunakan ekstensi aman berformat `.bex` untuk menambahkan sumber streaming baru tanpa batasan.
- **Integrasi Perpustakaan Lokal:** Putar berkas audio lokal Anda (MP3, FLAC, AAC, dll.) berdampingan dengan playlist online.
- **Lirik Karaoke Tersinkron:** Tampilan lirik lagu dengan fitur sinkronisasi waktu dan penyesuaian waktu tunda (offset) manual.
- **Audio DSP & Crossfade:** Equalizer internal canggih dan fitur perpindahan antar lagu yang mulus (crossfade).
- **Smart Link Recovery:** Otomatis mencadangkan dan mencari sumber lagu alternatif jika streaming utama terputus.
- **Scrobbling Last.fm Offline:** Riwayat lagu yang Anda dengarkan akan tetap tercatat dan dikirimkan saat Anda kembali online.
- **Discord Rich Presence:** Bagikan lagu yang sedang Anda putar secara realtime ke profil Discord Anda.
- **Ekspor & Impor Fleksibel:** Simpan perpustakaan lagu dan konfigurasi favorit Anda dalam format file JSON atau M3U.
- **Lokalisasi Multibahasa:** Antarmuka intuitif yang telah sepenuhnya diterjemahkan ke dalam 8 bahasa utama global.

---

## 🌍 Dukungan Bahasa saat Ini

Aplikasi telah sepenuhnya diterjemahkan secara native ke dalam bahasa berikut:

| Bendera | Bahasa | Status Terjemahan |
| :---: | :--- | :---: |
| 🇮🇩 | **Bahasa Indonesia** | ✅ 100% Selesai |
| 🇺🇸 | **English** | ✅ 100% Selesai |
| 🇮🇳 | **हिन्दी (Hindi)** | ✅ 100% Selesai |
| 🇩🇪 | **Deutsch (Jerman)** | ✅ 100% Selesai |
| 🇪🇸 | **Español (Spanyol)** | ✅ 100% Selesai |
| 🇯🇵 | **日本語 (Jepang)** | ✅ 100% Selesai |
| 🇰🇷 | **한국어 (Korea)** | ✅ 100% Selesai |
| 🇨🇳 | **中文 (Mandarin)** | ✅ 100% Selesai |

---

## 🛠️ Panduan Pengembangan Lokal (Kompilasi Mandiri)

Jika Anda ingin membangun StreamBeats sendiri dari source code:

### 1. Prasyarat Sistem
Pastikan perangkat Anda sudah terpasang perkakas berikut:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versi stabil terbaru)
- [Rust toolchain](https://www.rust-lang.org/tools/install) (cargo, rustc)
- Pustaka kompilasi platform target (C++ Build Tools untuk Windows, Xcode untuk macOS, build-essential untuk Linux)

### 2. Kloning Repositori
```bash
git clone https://github.com/DuskCipher/StreamBeats.git
cd StreamBeats
```

### 3. Pasang Generator Jembatan Rust-Flutter
StreamBeats menggunakan `flutter_rust_bridge` v2 untuk komunikasi super-cepat antara Flutter dan Rust.
```bash
cargo install flutter_rust_bridge_codegen
```

### 4. Jalankan Kode Generator & Bangun Aplikasi
Jalankan perintah flutter untuk memicu hooks generator dan mengunduh dependensi:
```bash
flutter pub get
```
Jalankan aplikasi di perangkat atau emulator pilihan Anda:
```bash
flutter run
```

---

## Kontribusi ke Project
Kami sangat menghargai kontribusi dari komunitas! Setiap kontribusi kode, desain, perbaikan bug, atau dokumentasi sangatlah berharga untuk perkembangan aplikasi ini.

1. Buka halaman **Issues** terlebih dahulu untuk mendiskusikan perubahan yang ingin dilakukan.
2. Lakukan **Fork** pada repositori ini.
3. Buat branch fitur baru (`git checkout -b fitur/fitur-keren-saya`).
4. Lakukan commit dan kirimkan **Pull Request**.

---

## 📫 Hubungi Kami & Komunitas
Mari terhubung dan bergabung bersama komunitas kami:

<div align="center">

[![GitHub Developer Profile](https://img.shields.io/badge/GitHub_Developer-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/DuskCipher)
[![WhatsApp Channel](https://img.shields.io/badge/WhatsApp_Channel-25D366?style=for-the-badge&logo=whatsapp&logoColor=white)](https://whatsapp.com/channel/0029Vb8V2qh8V0tpL0VDky0M)

</div>

<p align="center"><i>Dibuat dengan dedikasi penuh oleh DuskCipher dan kontributor hebat komunitas.</i></p>
