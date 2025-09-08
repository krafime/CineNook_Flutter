<div align="center">
  <h1>🎬 CineNook</h1>
  <p><em>Your Ultimate Movie Discovery App</em></p>
  
  ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
  ![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
  ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
  ![GetX](https://img.shields.io/badge/GetX-9C27B0?style=for-the-badge&logo=flutter&logoColor=white)
  ![TMDB API](https://img.shields.io/badge/TMDB_API-01B4E4?style=for-the-badge&logo=themoviedatabase&logoColor=white)
</div>

---

## ✨ Tentang CineNook

**CineNook** adalah aplikasi pencarian film yang memungkinkan pengguna untuk menjelajahi berbagai kategori film, melakukan pencarian, dan melihat detail film. Aplikasi ini dirancang dengan antarmuka yang ramah pengguna dan menggunakan berbagai teknologi modern untuk memberikan pengalaman yang mulus dan informatif.

Dibangun menggunakan Flutter dengan integrasi Firebase untuk authentication dan GetX untuk state management, CineNook memberikan pengalaman yang responsif dan modern dalam menjelajahi dunia perfilman.

## 🌟 Fitur Utama

<table>
  <tr>
    <td>
      <h3>🔍 Pencarian Film</h3>
      <p>Fitur pencarian yang kuat memungkinkan pengguna untuk menemukan film berdasarkan kata kunci</p>
    </td>
    <td>
      <h3>🔥 Film Populer</h3>
      <p>Menampilkan daftar film populer saat ini dengan data real-time dari TMDB</p>
    </td>
  </tr>
  <tr>
    <td>
      <h3>🎭 Sedang Tayang</h3>
      <p>Menampilkan film yang sedang tayang di bioskop saat ini</p>
    </td>
    <td>
      <h3>🚀 Film Mendatang</h3>
      <p>Menampilkan film yang akan datang dalam waktu dekat</p>
    </td>
  </tr>
  <tr>
    <td>
      <h3>📝 Detail Film</h3>
      <p>Menampilkan informasi terperinci tentang film, termasuk genre, durasi, dan informasi terkait lainnya</p>
    </td>
    <td>
      <h3>🔗 Film Serupa</h3>
      <p>Rekomendasi film serupa berdasarkan film yang sedang dilihat</p>
    </td>
  </tr>
  <tr>
    <td colspan="2">
      <h3>🔐 Authentication dengan Firebase</h3>
      <p>Sistem login dan registrasi yang aman menggunakan Firebase Authentication</p>
    </td>
  </tr>
</table>

## 📱 Screenshots

<div align="center">
  <table>
    <tr>
      <td align="center">
        <div style="border: 2px solid #333; border-radius: 15px; overflow: hidden; box-shadow: 0 4px 8px rgba(0,0,0,0.3); margin: 10px;">
          <img src="https://github.com/user-attachments/assets/3606a5c0-2d39-4a7f-9008-a2f9f67b05f2" width="280" alt="Home Screen" />
        </div>
        <br/>
        <strong>🏠 Home Screen</strong>
        <br/>
        <em>Tampilan utama dengan kategori film</em>
      </td>
      <td align="center">
        <div style="border: 2px solid #333; border-radius: 15px; overflow: hidden; box-shadow: 0 4px 8px rgba(0,0,0,0.3); margin: 10px;">
          <img src="https://github.com/user-attachments/assets/6453a3ea-46ad-4469-ac50-fea4542a68ea" width="280" alt="Movie Details" />
        </div>
        <br/>
        <strong>🎬 Movie Details</strong>
        <br/>
        <em>Detail lengkap informasi film</em>
      </td>
      <td align="center">
        <div style="border: 2px solid #333; border-radius: 15px; overflow: hidden; box-shadow: 0 4px 8px rgba(0,0,0,0.3); margin: 10px;">
          <img src="https://github.com/user-attachments/assets/3482063d-5d54-4fc0-b82d-af940e238967" width="280" alt="Search Results" />
        </div>
        <br/>
        <strong>🔍 Search Results</strong>
        <br/>
        <em>Hasil pencarian film</em>
      </td>
    </tr>
  </table>
</div>

## 🛠️ Teknologi yang Digunakan

- **Flutter**: Framework utama untuk pengembangan cross-platform
- **Dart**: Bahasa pemrograman untuk development
- **Firebase**: Backend services untuk authentication dan hosting
- **GetX**: State management dan dependency injection
- **GoRouter**: Routing dan navigation management
- **TMDB API**: Sumber data film real-time
- **HTTP Package**: HTTP client untuk API integration
- **Google Fonts**: Typography styling

## 🏗️ Arsitektur Aplikasi

```
lib/
├── api/                 # API service layer
├── controllers/         # GetX controllers untuk state management
├── models/             # Data models (Movie, MovieDetails, dll)
├── repository/         # Repository layer untuk data management
├── router/             # App routing configuration
├── widgets/            # Reusable UI components
├── constants.dart      # API keys dan konstanta
├── firebase_options.dart # Firebase configuration
└── main.dart          # Entry point aplikasi
```

## 📦 Instalasi dan Setup

### Prerequisites
- Flutter SDK (versi terbaru)
- Dart SDK
- Firebase account
- TMDB API key

### Langkah Instalasi

1. **Clone repository:**
   ```bash
   git clone https://github.com/krafime/CineNook_Flutter.git
   cd CineNook_Flutter
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Setup TMDB API:**
   
   Buat file `constants.dart` di folder `lib/` dengan content:
   ```dart
   class Constants {
     static const String apiKey = "YOUR_TMDB_API_KEY_HERE";
   }
   ```
   Dapatkan API key gratis di [TMDB](https://www.themoviedb.org/settings/api)

4. **Setup Firebase (opsional):**
   - Project sudah dikonfigurasi dengan Firebase
   - Untuk development lokal, pastikan Firebase CLI terinstall
   - Jalankan `firebase login` dan `firebase init` jika diperlukan

5. **Run aplikasi:**
   ```bash
   flutter run
   ```

## 🚀 Platform Support

CineNook mendukung multiple platform:
- ✅ **Android** - Full support
- ✅ **iOS** - Full support  
- ✅ **Web** - PWA ready

## 🌟 Fitur Mendatang

- [ ] Sistem bookmark dan watchlist
- [ ] Rating dan review film
- [ ] Mode offline dengan caching
- [ ] Notifikasi film terbaru
- [ ] Social sharing features
- [ ] Personalized recommendations
- [ ] Multi-language support

## 🤝 Kontribusi

Kontribusi selalu diterima! Berikut cara berkontribusi:

1. **Fork repository ini**
2. **Buat feature branch:**
   ```bash
   git checkout -b feature/fitur-keren
   ```
3. **Commit perubahan:**
   ```bash
   git commit -m 'Menambahkan fitur keren'
   ```
4. **Push ke branch:**
   ```bash
   git push origin feature/fitur-keren
   ```
5. **Buat Pull Request**

## 🌐 Demo Live

Kamu dapat mencoba CineNook secara langsung di:
🔗 **[krafime.github.io](https://krafime.github.io/)**

## 📬 Kontak

Ada pertanyaan atau saran? Jangan ragu untuk menghubungi:

- **Email**: krafime@gmail.com
- **GitHub**: [@krafime](https://github.com/krafime)
- **Issues**: [GitHub Issues](https://github.com/krafime/CineNook_Flutter/issues)

---

<div align="center">
  <p>Dibuat dengan ❤️ oleh <strong>Krafime</strong></p>
  <p>
    <a href="https://github.com/krafime">
      <img src="https://img.shields.io/github/followers/krafime?style=social" alt="Follow on GitHub">
    </a>
  </p>
  
  ⭐ **Jangan lupa beri star jika project ini membantu!** ⭐
</div>
