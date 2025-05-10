import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    FileInputStream(localPropertiesFile).use { stream ->
        localProperties.load(stream)
    }
}

// Versioning (Defaults to 1 if not set in local.properties)
val flutterVersionCode = localProperties.getProperty("flutter.versionCode", "1").toInt()
val flutterVersionName = localProperties.getProperty("flutter.versionName", "1.0")

android {
    namespace = "com.tgeiling.backquest"
    compileSdk = 35
    
    // Set the specific NDK version required by your plugins
    ndkVersion = "27.0.12077973"  // Updated as requested in the error message

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.tgeiling.backquest"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode
        versionName = flutterVersionName
        multiDexEnabled = true
    }

    signingConfigs {
        // Debug config for development
        getByName("debug") {
            // Default debug keystore
        }
    }

    buildTypes {
        getByName("debug") {
            // Use debug signing config
            signingConfig = signingConfigs.getByName("debug")
        }
        
        getByName("release") {
            // For development, use debug signing config
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    
    implementation(platform("com.google.firebase:firebase-bom:33.11.0"))
    implementation("com.google.firebase:firebase-messaging")
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.21")
    implementation("androidx.multidex:multidex:2.0.1")
}