# ProGuard / R8 keep rules for the prod release build.
# See docs/release_process.md section 6.2. R8 can strip classes that are only
# reached by reflection, which shows up as a release-only crash. Keep the
# Flutter engine and the location plugin so that never happens.

# ── Flutter engine ────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# ── Geolocator (Android) ──────────────────────────────────────────────────────
# The only plugin. Parts are reached via reflection / the Android framework.
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# ── Keep annotations and native method names ──────────────────────────────────
-keepattributes *Annotation*
-keepclasseswithmembernames class * {
    native <methods>;
}
