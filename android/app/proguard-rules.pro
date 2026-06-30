# WorkManager + Room (required for release builds; R8 strips WorkDatabase_Impl otherwise).
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.InputMerger
-keep class * extends androidx.work.ListenableWorker
-keep class androidx.work.** { *; }
-keep class androidx.work.impl.** { *; }
-keepclassmembers class * extends androidx.work.Worker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}
-keep class * extends androidx.room.RoomDatabase
-keep @androidx.room.Entity class *
-keepclassmembers class * {
    @androidx.room.* <methods>;
}

-keep class dev.fluttercommunity.workmanager.** { *; }

# Flutter deferred components reference Play Core (optional; not bundled in sideload APKs).
-dontwarn com.google.android.play.core.**

-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
