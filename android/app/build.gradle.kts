import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ─── Signing ─────────────────────────────────────────────────────────────────
// Strategy A (local file-based). key.properties and the keystore are created in
// Phase 10; until then this block is inert and release builds fall back to debug
// signing so the scaffold still builds and runs.
val keystorePropertiesFile = rootProject.file("key.properties")

android {
    namespace = "in.sreerajp.sanathana_dharma_clock"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "in.sreerajp.sanathana_dharma_clock"
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                val props = Properties()
                props.load(keystorePropertiesFile.inputStream())
                keyAlias = props.getProperty("keyAlias")
                keyPassword = props.getProperty("keyPassword")
                storeFile = props.getProperty("storeFile")?.let { file(it) }
                storePassword = props.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // Use the release keystore when it exists (Phase 10); otherwise fall
            // back to the debug key so scaffold release builds still work.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            // R8 code shrinking + resource shrinking (release_process.md §6.2).
            // Keep rules for the Flutter engine and the location plugin live in
            // proguard-rules.pro so reflection-only classes are not stripped.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Sanathana Dharma Clock Dev")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "Sanathana Dharma Clock")
        }
    }
}

flutter {
    source = "../.."
}
