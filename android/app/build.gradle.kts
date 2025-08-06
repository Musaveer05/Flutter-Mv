plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.clevertap"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.clevertap"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation("com.google.firebase:firebase-messaging:21.0.0");
    implementation("androidx.core:core:1.3.0");
    implementation("androidx.fragment:fragment:1.3.6");

    implementation("com.clevertap.android:push-templates:2.0.0");

    // MANDATORY for App Inbox
    implementation("androidx.appcompat:appcompat:1.3.1");
    implementation("androidx.recyclerview:recyclerview:1.2.1");
    implementation("androidx.viewpager:viewpager:1.0.0");
    implementation("com.google.android.material:material:1.4.0");
    implementation("com.github.bumptech.glide:glide:4.12.0");

    // For CleverTap Android SDK v3.6.4 and above
    implementation("com.android.installreferrer:installreferrer:2.2");

    // Optional AndroidX Media3 Libraries
    implementation("androidx.media3:media3-exoplayer:1.1.1");
    implementation("androidx.media3:media3-exoplayer-hls:1.1.1");
    implementation("androidx.media3:media3-ui:1.1.1");

    // (keep any other existing dependencies too)

}

flutter {
    source = "../.."
}

