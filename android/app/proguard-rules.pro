# Flutter-specific ProGuard rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Supabase
-keep class io.github.jan-tennert.supabase.** { *; }

# Keep annotation
-keepattributes *Annotation*
