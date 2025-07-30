// Helper functions untuk integrasi Flutter dengan JavaScript

// Fungsi untuk cek status login user via JavaScript
function isUserLoggedIn() {
  // Check localStorage atau state lain yang menandakan user sudah login
  try {
    const token = localStorage.getItem("auth_token");
    return !!token; // Return true jika token ada
  } catch (e) {
    console.error("Error checking user login status:", e);
    return false;
  }
}

// Handler callback untuk komunikasi dari JS ke Flutter
let flutterAuthCallback = null;

// Setup callback handler
function setFlutterAuthCallback(callback) {
  flutterAuthCallback = callback;
  console.log("Flutter auth callback registered");
}

// Fungsi untuk navigasi
function navigateToRoute(route) {
  try {
    window.location.hash = route;
    console.log("Navigating to route:", route);
  } catch (e) {
    console.error("Error navigating to route:", e);
  }
}

// Fungsi untuk login dengan Google
function loginWithGoogle() {
  // Integrasi dengan Firebase Auth untuk Web
  try {
    const auth = firebase.auth();
    const provider = new firebase.auth.GoogleAuthProvider();

    auth
      .signInWithPopup(provider)
      .then((result) => {
        const user = result.user;
        // Panggil callback ke Flutter
        if (flutterAuthCallback) {
          flutterAuthCallback("SIGNED_IN", JSON.stringify(user));
          console.log("User signed in, notifying Flutter");
        }
      })
      .catch((error) => {
        console.error("Google sign in error:", error);
        if (flutterAuthCallback) {
          flutterAuthCallback("ERROR", JSON.stringify(error));
        }
      });
  } catch (e) {
    console.error("Error starting Google sign in:", e);
  }
}

// Fungsi untuk sign out
function signOutFromGoogle() {
  try {
    const auth = firebase.auth();
    auth
      .signOut()
      .then(() => {
        // Hapus token dari localStorage
        localStorage.removeItem("auth_token");

        // Panggil callback ke Flutter
        if (flutterAuthCallback) {
          flutterAuthCallback("SIGNED_OUT", null);
          console.log("User signed out, notifying Flutter");
        }
      })
      .catch((error) => {
        console.error("Sign out error:", error);
      });
  } catch (e) {
    console.error("Error signing out:", e);
  }
}

// Expose functions to global scope
window.isUserLoggedIn = isUserLoggedIn;
window.setFlutterAuthCallback = setFlutterAuthCallback;
window.navigateToRoute = navigateToRoute;
window.loginWithGoogle = loginWithGoogle;
window.signOutFromGoogle = signOutFromGoogle;

// auth_helper.js
// Helper functions for Flutter-JS interop

// Helper to make Flutter callback easier
window.flutterAuthCallback = null;

// Register auth callback from Dart
window.registerFlutterAuthCallback = function (callback) {
  window.flutterAuthCallback = callback;

  // Immediately trigger callback if user is already logged in
  if (localStorage.getItem("userLoggedIn") === "true") {
    const userData = {
      uid: localStorage.getItem("userUID") || "",
      displayName: localStorage.getItem("userDisplayName") || "",
      email: localStorage.getItem("userEmail") || "",
      photoURL: localStorage.getItem("userPhotoURL") || "",
    };

    callback("SIGNED_IN", JSON.stringify(userData));
  }

  return true;
};

// Get current user information
window.getCurrentUser = function () {
  if (localStorage.getItem("userLoggedIn") === "true") {
    return {
      uid: localStorage.getItem("userUID") || "",
      displayName: localStorage.getItem("userDisplayName") || "",
      email: localStorage.getItem("userEmail") || "",
      photoURL: localStorage.getItem("userPhotoURL") || "",
    };
  }
  return null;
};

// Navigate to a Flutter route
window.navigateToFlutterRoute = function (route) {
  if (window.location.hash !== route) {
    window.location.hash = route;
    return true;
  }
  return false;
};

// Additional route helpers
window.goToHomePage = function () {
  return window.navigateToFlutterRoute("/");
};

window.goToLoginPage = function () {
  return window.navigateToFlutterRoute("/login");
};

window.goToProfilePage = function () {
  return window.navigateToFlutterRoute("/profile");
};
