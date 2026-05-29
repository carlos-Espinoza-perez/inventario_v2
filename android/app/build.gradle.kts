import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Resuelve credenciales: key.properties tiene prioridad, luego variables de entorno
val releaseKeyAlias: String? =
    (keystoreProperties["keyAlias"] as? String)?.takeIf { it.isNotBlank() }
    ?: System.getenv("KEY_ALIAS")

val releaseKeyPassword: String? =
    (keystoreProperties["keyPassword"] as? String)?.takeIf { it.isNotBlank() }
    ?: System.getenv("KEY_PASSWORD")

val releaseStorePassword: String? =
    (keystoreProperties["storePassword"] as? String)?.takeIf { it.isNotBlank() }
    ?: System.getenv("KEY_STORE_PASSWORD")

val releaseStoreFilePath: String? =
    (keystoreProperties["storeFile"] as? String)?.takeIf { it.isNotBlank() }
    ?: System.getenv("KEYSTORE_PATH")

val hasReleaseKeys = listOf(releaseKeyAlias, releaseKeyPassword, releaseStorePassword, releaseStoreFilePath)
    .all { !it.isNullOrBlank() }

android {
    namespace = "com.example.inventario_v2"
    compileSdk = 35
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.inventario_v2"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    if (hasReleaseKeys) {
        signingConfigs {
            create("release") {
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
                storeFile = file(releaseStoreFilePath!!)
                storePassword = releaseStorePassword
                enableV1Signing = true
                enableV2Signing = true
            }
        }
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
        }

        release {
            signingConfig = if (hasReleaseKeys) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            isMinifyEnabled = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
