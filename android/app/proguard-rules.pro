# Tally Counter — R8/ProGuard rules for the release build.
#
# The Dart side is compiled AOT, so only *native* (Kotlin/Java + plugin) code is
# affected by R8. Manifest-referenced classes are kept automatically by AGP, but
# we list the app's native entry points explicitly so shrinking never removes
# the home-screen widget providers, the notification receiver/service, or the
# VolumeButton `MainActivity` channel handler.

# --- App native classes -------------------------------------------------------
-keep class com.tallycounter.tally_counter.** { *; }

# --- Flutter embedding --------------------------------------------------------
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# --- home_widget (widget providers + background receiver) ---------------------
-keep class es.antonborri.home_widget.** { *; }

# --- sqlite3 (drift native bindings register via JNI) -------------------------
-keep class org.sqlite.** { *; }
-keep class com.tekartik.sqflite.** { *; }
-dontwarn org.sqlite.**

# --- Plugins that reflect on their Kotlin/Java types --------------------------
-keep class androidx.** { *; }
-dontwarn androidx.**

# Keep annotations used by plugin reflection.
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod
-keepattributes SourceFile,LineNumberTable

# Kotlin metadata is needed by some plugins at runtime.
-keep class kotlin.Metadata { *; }
