#!/usr/bin/env node
/**
 * Script untuk mengobfuskasi kode Dart dan mengenkripsi konfigurasi sensitif
 * Jalankan setelah flutter build web dengan perintah:
 * node scripts/obfuscate-web.js
 */

const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

// Direktori build web
const webBuildDir = path.join(__dirname, "../build/web");
const mainJsPath = path.join(webBuildDir, "main.dart.js");
const serviceWorkerPath = path.join(webBuildDir, "flutter_service_worker.js");
const firebaseConfigJsPath = path.join(webBuildDir, "firebase-config.js");
const envConfigJsPath = path.join(webBuildDir, "env-config.js");
const indexHtmlPath = path.join(webBuildDir, "index.html");

// Firebase config yang digunakan dalam production
const firebaseConfig = {
  apiKey:
    process.env.FIREBASE_API_KEY || "AIzaSyAtHCA3pJy7XIliLwKlvwmYqS7fZ90L9UY",
  authDomain:
    process.env.FIREBASE_AUTH_DOMAIN || "cinenook-flutter.firebaseapp.com",
  projectId: process.env.FIREBASE_PROJECT_ID || "cinenook-flutter",
  storageBucket:
    process.env.FIREBASE_STORAGE_BUCKET ||
    "cinenook-flutter.firebasestorage.app",
  messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID || "215921381040",
  appId:
    process.env.FIREBASE_APP_ID || "1:215921381040:web:e46f695af5e2e7fbfbf575",
  measurementId: process.env.FIREBASE_MEASUREMENT_ID || "G-LXV5GBNDME",
};

// reCAPTCHA key untuk AppCheck
const recaptchaKey =
  process.env.RECAPTCHA_KEY || "6LdbZPoqAAAAAIfEN2FS13cY8QAYAvVhV3nWAF4W";

// Google Sign-in Client ID
const googleSignInClientId =
  process.env.GOOGLE_SIGNIN_CLIENT_ID ||
  "215921381040-srck5ql8s3d47b1p09epclrqghbp8pjd.apps.googleusercontent.com";

console.log("🚀 Starting web build preparation process...");

// 1. Ganti placeholder dengan konfigurasi terenkripsi di index.html
try {
  console.log("📝 Memperbarui konfigurasi Firebase di index.html...");
  let indexHtml = fs.readFileSync(indexHtmlPath, "utf8");

  // Base64 encode the Firebase config
  const encodedFirebaseConfig = Buffer.from(
    JSON.stringify(firebaseConfig)
  ).toString("base64");

  // Ganti placeholder dengan config terenkripsi
  indexHtml = indexHtml.replace(
    "__FIREBASE_CONFIG_PLACEHOLDER__",
    encodedFirebaseConfig
  );
  indexHtml = indexHtml.replace("__RECAPTCHA_KEY_PLACEHOLDER__", recaptchaKey);
  indexHtml = indexHtml.replace(
    "__GOOGLE_SIGNIN_CLIENT_ID__",
    googleSignInClientId
  );

  // Pastikan meta tag untuk Google Sign-in sudah benar
  if (!indexHtml.includes(`content="${googleSignInClientId}"`)) {
    console.log("⚠️ Meta tag untuk Google Sign-in Client ID perlu diperbarui");

    // Coba update meta tag yang sudah ada
    const metaTagRegex =
      /<meta\s+name="google-signin-client_id"\s+content="[^"]+"\s*\/>/;
    if (metaTagRegex.test(indexHtml)) {
      indexHtml = indexHtml.replace(
        metaTagRegex,
        `<meta name="google-signin-client_id" content="${googleSignInClientId}" />`
      );
      console.log("✅ Berhasil memperbarui meta tag Google Sign-in Client ID");
    } else {
      // Jika tidak ada, tambahkan meta tag baru di head
      indexHtml = indexHtml.replace(
        "</head>",
        `  <meta name="google-signin-client_id" content="${googleSignInClientId}" />\n  </head>`
      );
      console.log("✅ Berhasil menambahkan meta tag Google Sign-in Client ID");
    }
  }

  fs.writeFileSync(indexHtmlPath, indexHtml);
  console.log("✅ Berhasil memperbarui konfigurasi di index.html");
} catch (err) {
  console.error("❌ Gagal memperbarui konfigurasi:", err);
  process.exit(1);
}

// 2. Hindari obfuskasi main.dart.js untuk popup login
console.log(
  "⚠️ Melewati obfuskasi main.dart.js untuk menghindari masalah login Google"
);
console.log(
  "ℹ️ Jika ingin obfuskasi, gunakan: npx terser main.dart.js --compress --mangle --mangle-props=false --output main.dart.js"
);

// 3. Buat file konfigurasi Firebase yang jelas
try {
  console.log("📝 Membuat firebase-config.js...");

  const safeFirebaseConfig = `
// Firebase configuration
const firebaseConfig = ${JSON.stringify(firebaseConfig, null, 2)};

// Function to get Firebase config
window.getFirebaseConfig = function() { 
  return firebaseConfig;
};
  `;

  fs.writeFileSync(firebaseConfigJsPath, safeFirebaseConfig);
  console.log("✅ Berhasil membuat firebase-config.js");
} catch (err) {
  console.error("❌ Gagal membuat firebase-config.js:", err);
}

// 4. Buat file env-config.js
try {
  console.log("📝 Membuat env-config.js...");

  const safeEnvConfig = `
// Environment configuration
window.recaptchaKey = "${recaptchaKey}";
window.googleSignInClientId = "${googleSignInClientId}";
  `;

  fs.writeFileSync(envConfigJsPath, safeEnvConfig);
  console.log("✅ Berhasil membuat env-config.js");
} catch (err) {
  console.error("❌ Gagal membuat env-config.js:", err);
}

// 5. Pastikan index.html memuat file konfigurasi
try {
  console.log("📝 Memastikan index.html memuat file konfigurasi...");

  let indexHtml = fs.readFileSync(indexHtmlPath, "utf8");

  // Periksa apakah referensi script sudah ada
  if (
    !indexHtml.includes('<script src="firebase-config.js">') &&
    !indexHtml.includes('<script src="env-config.js">')
  ) {
    // Tambahkan referensi ke file konfigurasi sebelum flutter_bootstrap.js
    indexHtml = indexHtml.replace(
      '<script src="flutter_bootstrap.js" async></script>',
      '<script src="firebase-config.js"></script>\n    <script src="env-config.js"></script>\n    <script src="flutter_bootstrap.js" async></script>'
    );

    fs.writeFileSync(indexHtmlPath, indexHtml);
    console.log("✅ Berhasil menambahkan referensi script ke index.html");
  } else {
    console.log("✅ Referensi script sudah ada di index.html");
  }
} catch (err) {
  console.error("❌ Gagal memperbarui index.html:", err);
}

console.log("🎉 Proses persiapan web build selesai!");
console.log("📋 Deploy folder build/web ke GitHub Pages");
console.log(
  "⚠️ PENTING: Pastikan domain GitHub Pages Anda (krafime.github.io) sudah terdaftar di Firebase Console > Authentication > Settings > Authorized domains"
);
console.log(
  "🔒 Untuk keamanan lebih, tambahkan domain Anda di Google Cloud Console > APIs & Services > Credentials > OAuth Client ID > Authorized JavaScript origins"
);
