# Flutter/R8 ProGuard rules
# Manter classes usadas por reflection/plugins

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Supabase
-keep class io.supabase.** { *; }
-keep class com.suprgeocoder.** { *; }
-dontwarn io.supabase.**

# Retrofit / OkHttp (usados por Supabase)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Google fonts - usa reflection para carregar fonts
-keep class com.google.android.gms.tasks.** { *; }
-dontwarn com.google.android.gms.**

# flutter_local_notifications
-keep class com.dexterous.** { *; }

# image_picker / plugin registries (Android embedding)
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

# Play Core (referenciado pelo Flutter para split/deferred components;
# a classe nao esta presente em APK unico — R8 veria com "Missing classes")
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
