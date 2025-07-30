# Flutter default ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Aturan khusus untuk model Anda
-keep class io.flutter.app.cinenook.models.** { *; }

# Anotasi yang digunakan oleh library
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keep public class * extends java.lang.Exception

# Untuk Google Sign In
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Jika menggunakan serialisasi json
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}