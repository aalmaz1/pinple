# Naver Map SDK Proguard Rules
-keep class com.naver.maps.map.** { *; }
-keep interface com.naver.maps.map.** { *; }
-keep class com.naver.maps.geometry.** { *; }

# Firebase Proguard Rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Flutter Optimization
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Fix for Play Core missing classes (R8 error)
-dontwarn com.google.android.play.core.**

# STRIP LOGS - Remove all logging for maximum performance in Release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

# Aggressive optimization
-optimizationpasses 5
-allowaccessmodification
-dontpreverify
