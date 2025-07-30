// File yang berisi implementasi untuk web
// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:js_interop';

// Gunakan import kondisional untuk memastikan kode ini hanya dijalankan pada web
import 'package:flutter/foundation.dart' show kIsWeb;

// Callback untuk autentikasi
@JSExport()
class FlutterAuthCallbackHandler {
  final Function(String, String?) callback;

  FlutterAuthCallbackHandler(this.callback);

  @JSExport('handleEvent')
  void handleEvent(String type, String? userData) {
    callback(type, userData);
  }
}

// Implementasi fungsi-fungsi JavaScript untuk web

bool isUserLoggedInJsImpl() {
  if (!kIsWeb) return false;

  try {
    final isLoggedIn = isUserLoggedInJS();
    return isLoggedIn.toDart;
  } catch (e) {
    return false;
  }
}

@JS('isUserLoggedIn')
external JSBoolean isUserLoggedInJS();

void setupJsCallbackImpl() {
  if (!kIsWeb) return;

  try {
    // Setup callback dari JS ke Flutter
    setFlutterAuthCallback(flutterAuthCallbackJS);
  } catch (e) {
    // Ignore errors
  }
}

@JS('setFlutterAuthCallback')
external void setFlutterAuthCallback(JSFunction callback);

// Fungsi yang dipanggil dari JS, mengarahkan ke callback Flutter
void flutterAuthCallback(String type, String? userDataJson) {
  if (_authCallback != null) {
    _authCallback!(type, userDataJson);
  }
}

// Variabel callback untuk menghubungkan dengan AuthController
Function(String type, String? userDataJson)? _authCallback;

void registerJsAuthCallbackImpl(Function(String, String?) callback) {
  if (!kIsWeb) return;

  try {
    _authCallback = callback;
  } catch (e) {
    // Ignore errors
  }
}

// Konverter untuk callback
final flutterAuthCallbackJS = flutterAuthCallback.toJS;

void navigateToHomeJsImpl() {
  if (!kIsWeb) return;

  try {
    navigateToRoute('/');
  } catch (e) {
    // Ignore errors
  }
}

void navigateToRouteJsImpl(String route) {
  if (!kIsWeb) return;

  try {
    navigateToRoute(route);
  } catch (e) {
    // Ignore errors
  }
}

@JS('navigateToRoute')
external void navigateToRoute(String route);

void loginWithGoogleJsImpl() {
  if (!kIsWeb) return;

  try {
    loginWithGoogleJS();
  } catch (e) {
    // Ignore errors
  }
}

@JS('loginWithGoogle')
external void loginWithGoogleJS();

void signOutFromGoogleJsImpl() {
  if (!kIsWeb) return;

  try {
    signOutFromGoogleJS();
  } catch (e) {
    // Ignore errors
  }
}

@JS('signOutFromGoogle')
external void signOutFromGoogleJS();
