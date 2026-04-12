# Razorpay Proguard Rules
-keep class com.razorpay.** {*;}
-dontwarn com.razorpay.**

# Required by Razorpay for safety
-keepattributes Signature,Exceptions,*Annotation*
-keep class com.google.android.gms.common.api.internal.LifecycleCallback { *; }
