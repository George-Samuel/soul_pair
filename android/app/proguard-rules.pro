# android/app/proguard-rules.pro - ВАШ ИСПРАВЛЕННЫЙ ФАЙЛ

# FLUTTER
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# YOUR APP
-keep class com.george_samusevich.soul_pair.** { *; }

# KOTLIN
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# ANDROIDX
-keep class androidx.** { *; }
-dontwarn androidx.**

# METHOD CHANNELS
# ← Отлично, что удалили проблемные строки!

# FOR CAMERA/GALLERY
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# ANNOTATIONS
-keepattributes *Annotation*