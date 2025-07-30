import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional import untuk web
import 'js_interop_web.dart' if (dart.library.io) 'js_interop_mobile.dart';

// Fungsi-fungsi yang memanggil implementasi platform-specific

bool isUserLoggedInJs() {
  if (!kIsWeb) return false;
  return isUserLoggedInJsImpl();
}

void setupJsCallback() {
  if (!kIsWeb) return;
  setupJsCallbackImpl();
}

void navigateToHomeJs() {
  if (!kIsWeb) return;
  navigateToHomeJsImpl();
}

void navigateToRouteJs(String route) {
  if (!kIsWeb) return;
  navigateToRouteJsImpl(route);
}

void loginWithGoogleJs() {
  if (!kIsWeb) return;
  loginWithGoogleJsImpl();
}

void signOutFromGoogleJs() {
  if (!kIsWeb) return;
  signOutFromGoogleJsImpl();
}

// Menambahkan fungsi untuk mendaftarkan callback
void registerJsAuthCallback(Function(String, String?) callback) {
  if (!kIsWeb) return;
  registerJsAuthCallbackImpl(callback);
}
