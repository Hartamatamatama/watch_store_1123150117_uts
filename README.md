# Hartama Watch Store 🕰️
> **A Premium Luxury Watch E-Commerce Experience**

![Banner](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Golang](https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![MySQL](https://img.shields.io/badge/mysql-%2300f.svg?style=for-the-badge&logo=mysql&logoColor=white)

**Hartama Watch Store** adalah aplikasi *e-commerce* jam tangan mewah yang dikembangkan untuk memenuhi tugas **Ujian Tengah Semester (UTS) Mata Kuliah Mobile Apps**. Aplikasi ini menggabungkan performa tinggi *backend* Golang dengan keindahan antarmuka Flutter, serta integrasi *real-time* dari Firebase Cloud Messaging.

---

## 📺 Video Demo & Presentasi
Tonton demonstrasi lengkap fitur dan arsitektur aplikasi di sini:
https://youtu.be/XhDkMAFpHK4

---

## 📸 Dokumentasi Aplikasi (Screenshots)

| Splash Screen | Login & Register | Verify Email |
|---|---|---|
| | | |

| Dashboard | Product Detail | Success Checkout |
|---|---|---|
| | | |

---

## ✨ Fitur Utama

### 📱 Frontend (Flutter)
- **Luxury UI/UX:** Desain premium menggunakan font *Playfair Display* & *Lato*.
- **Firebase Auth:** Sistem login/register dengan Email & Google Sign-In.
- **Email Verification Gateway:** Proteksi akses aplikasi bagi user yang belum terverifikasi dengan sistem *polling real-time*.
- **Smart Cart System:** Validasi stok otomatis dari database untuk mencegah transaksi melebihi jumlah stok fisik.
- **Push Notifications (FCM):** Notifikasi otomatis saat checkout berhasil, berjalan di *Foreground*, *Background*, maupun *Terminated*.
- **Instant SnackBar:** Sistem notifikasi in-app yang responsif tanpa antrean (Instant Hide & Show).

### ⚙️ Backend (Golang & Gin)
- **Secure API:** Integrasi Firebase Admin SDK untuk verifikasi token.
- **Stock Management Logic:** Pengurangan stok otomatis di database MySQL saat checkout berhasil.
- **Auto-Trigger Notification:** Backend mengirimkan sinyal FCM secara otomatis ke perangkat user setelah transaksi diproses.

---

## 🛠️ Tech Stack

- **Mobile:** [Flutter](https://flutter.dev/) (Provider State Management)
- **Backend:** [Golang](https://go.dev/) (Gin Framework)
- **Database:** [MySQL](https://www.mysql.com/) & [GORM](https://gorm.io/)
- **Cloud:** [Firebase](https://firebase.google.com/) (Auth & Cloud Messaging)
- **HTTP Client:** [Dio](https://pub.dev/packages/dio)

---

## 🚀 Cara Menjalankan Proyek

### 1. Persiapan Backend
1. Masuk ke folder backend: `cd gin-firebase-backend`
2. Konfigurasi `.env` dan `serviceAccountKey.json` untuk Firebase.
3. Jalankan aplikasi:
   ```bash
   go run main.go
2. Persiapan Frontend
Masuk ke folder frontend: cd watch_store_uts

Pastikan file serviceAccountKey.json atau konfigurasi Firebase sudah sesuai.

Install dependencies:

Bash
flutter pub get
Jalankan aplikasi:

Bash
flutter run
🔗 Repositori Terkait
Frontend App: Hartama Watch Store Mobile

Backend API: Gin Firebase Backend

👨‍💻 Informasi Akademik
Nama: Farhan Raisprawira Hartama

Kampus: ITB Bina Sarana Global

Mata Kuliah: Mobile Apps

Dosen Pengampu: I Ketut Gunawan, S.Kom., M.MSI

© 2026 Hartama Watch Store. Developed by Farhan Raisprawira Hartama.