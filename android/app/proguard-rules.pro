-keep class io.flutter.app.** { *; }

-keep class io.flutter.plugins.** { *; }

-keep class com.google.gson.** { *; }

-keep class com.example.yourapp.** { *; }

-keep class com.google.android.gms.ads.** { *; }
-keep interface com.google.android.gms.ads.** { *; }

-keepclassmembers class * {
    @com.google.firebase.** <methods>;
}

-dontwarn org.apache.**
-dontwarn javax.annotation.**
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-optimizations !method/inlining/
-keepclasseswithmembers class * {
  public void onPayment*(...);
}