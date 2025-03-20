const fs = require("fs");
const path = require("path");
require("dotenv").config();

// Path ke file output build Flutter
const buildPath = path.join(__dirname, "../build/web");
const indexPath = path.join(buildPath, "index.html");

// Cek apakah file .env dimuat dengan benar
if (!process.env.FIREBASE_API_KEY) {
  console.warn(
    "Warning: Environment variables not properly loaded. Check your .env file."
  );
}

// Baca konfigurasi dari environment variables
const firebaseConfig = {
  apiKey: process.env.FIREBASE_API_KEY || "PLACEHOLDER_API_KEY",
  authDomain: process.env.FIREBASE_AUTH_DOMAIN || "PLACEHOLDER_AUTH_DOMAIN",
  projectId: process.env.FIREBASE_PROJECT_ID || "PLACEHOLDER_PROJECT_ID",
  storageBucket:
    process.env.FIREBASE_STORAGE_BUCKET || "PLACEHOLDER_STORAGE_BUCKET",
  messagingSenderId:
    process.env.FIREBASE_MESSAGING_SENDER_ID ||
    "PLACEHOLDER_MESSAGING_SENDER_ID",
  appId: process.env.FIREBASE_APP_ID || "PLACEHOLDER_APP_ID",
  measurementId:
    process.env.FIREBASE_MEASUREMENT_ID || "PLACEHOLDER_MEASUREMENT_ID",
};

// Encode konfigurasi untuk obfuscation dasar
const encodedFirebaseConfig = Buffer.from(
  JSON.stringify(firebaseConfig)
).toString("base64");
const recaptchaKey = process.env.RECAPTCHA_KEY || "PLACEHOLDER_RECAPTCHA_KEY";

console.log("Preparing to inject secrets into index.html...");

// Cek apakah build directory ada
if (!fs.existsSync(buildPath)) {
  console.error(`Build directory not found at ${buildPath}`);
  console.error("Please run 'flutter build web' first");
  process.exit(1);
}

// Baca file index.html
fs.readFile(indexPath, "utf8", (err, data) => {
  if (err) {
    console.error("Error reading index.html:", err);
    process.exit(1);
  }

  console.log("Successfully read index.html");

  // Ganti placeholder dengan nilai sebenarnya
  const updatedHtml = data
    .replace('"__FIREBASE_CONFIG_PLACEHOLDER__"', `"${encodedFirebaseConfig}"`)
    .replace('"__RECAPTCHA_KEY_PLACEHOLDER__"', `"${recaptchaKey}"`);

  // Tulis kembali file index.html
  fs.writeFile(indexPath, updatedHtml, "utf8", (err) => {
    if (err) {
      console.error("Error writing index.html:", err);
      process.exit(1);
    }
    console.log("✓ Secrets successfully injected into index.html");
  });
});
