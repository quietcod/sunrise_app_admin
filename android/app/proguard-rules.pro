# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# Keep annotations
-keepattributes *Annotation*

# Prevent stripping of Gson/serialization
-keepattributes Signature
-keepattributes Exceptions

# Suppress missing class warnings for Play Core (used by Flutter deferred components)
-dontwarn com.google.android.play.core.**
