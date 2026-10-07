plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.io.FileInputStream
import java.util.Properties

val keystorePropertiesFile = rootProject.file("key.properties")


android {
    namespace = "ls.streambeats.musicplayer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "ls.streambeats.musicplayer"
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            isUniversalApk = true
        }
    }
    dependenciesInfo {
        includeInApk = false
        includeInBundle = false
    }

    signingConfigs {
        getByName("debug") {
            enableV1Signing = true
            enableV2Signing = true
        }
        if (keystorePropertiesFile.exists()) {
            println("   ✅ key.properties found - configuring release signing")
            val keystoreProperties = Properties()
            keystoreProperties.load(FileInputStream(keystorePropertiesFile))

            val keystoreFileName = keystoreProperties["storeFile"] as String?
            val keyAliasValue = keystoreProperties["keyAlias"] as String?

            println("   Keystore file path: $keystoreFileName")
            println("   Key alias: $keyAliasValue")

            if (keystoreFileName != null) {
                val keystoreFile = rootProject.file(keystoreFileName)
                println("   Keystore file exists: ${keystoreFile.exists()}")
                println("   Keystore file path: ${keystoreFile.absolutePath}")
            }

            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String?
                enableV1Signing = true
                enableV2Signing = true
                println("   ✅ Release signing config created successfully with V1 & V2 signing")
            }
        } else {
            println("   ❌ key.properties not found - using debug signing")
        }
    }

    buildTypes {
        release {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
                println("   📦 Release build: Using release signing config")
            }
            else{
                signingConfig = signingConfigs.getByName("debug")
                println("   📦 Release build: Using debug signing config (no keystore)")
            }
        }
    }

    // To reduce the size of the APK, since from AGP 8.0.0 the default value of useLegacyPackaging is false.
     packagingOptions {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}

flutter {
    source = "../.."
}
