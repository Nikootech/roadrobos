# ═══ RoadRobos ProGuard Rules ═══

# --- Razorpay ---
-keep class com.razorpay.** {*;}
-dontwarn com.razorpay.**
-keepattributes Signature,Exceptions,*Annotation*
-keep class com.google.android.gms.common.api.internal.LifecycleCallback { *; }

# --- Firebase Crashlytics ---
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class com.google.firebase.crashlytics.** { *; }
-dontwarn com.google.firebase.crashlytics.**

# --- Firebase Messaging ---
-keep class com.google.firebase.messaging.** { *; }

# --- Google Sign-In ---
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.android.gms.**

# --- Flutter Secure Storage ---
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# --- Geolocator ---
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# --- Flutter ---
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# --- General ---
-dontwarn kotlin.**
-dontwarn org.codehaus.**
-keepattributes InnerClasses

# --- Play Core ---
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
