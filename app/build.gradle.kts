import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.util.Properties

plugins {
  alias(libs.plugins.android.application)
  alias(libs.plugins.compose.compiler)
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
  keystorePropertiesFile.inputStream().use(keystoreProperties::load)
}
val hasReleaseSigning = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
  .all { !keystoreProperties.getProperty(it).isNullOrBlank() }

android {
  namespace = "com.gt610.lunadial"
  compileSdk = 37
  buildToolsVersion = "37.0.0"

  defaultConfig {
    applicationId = "com.gt610.lunadial"
    minSdk = 24
    targetSdk = 36
    versionCode = 5
    versionName = "0.5.1"
  }

  signingConfigs {
    if (hasReleaseSigning) {
      create("release") {
        storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
        storePassword = keystoreProperties.getProperty("storePassword")
        keyAlias = keystoreProperties.getProperty("keyAlias")
        keyPassword = keystoreProperties.getProperty("keyPassword")
      }
    }
  }

  buildTypes {
    release {
      isMinifyEnabled = true
      isShrinkResources = true
      proguardFiles(
        getDefaultProguardFile("proguard-android-optimize.txt"),
        "proguard-rules.pro",
      )
      if (hasReleaseSigning) {
        signingConfig = signingConfigs.getByName("release")
      }
    }
    debug {
      applicationIdSuffix = ".debug"
    }
  }

  compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
  }

  buildFeatures {
    compose = true
    buildConfig = true
    aidl = false
    shaders = false
  }

  // A single universal APK: the only native libraries are a few tiny ABI
  // stubs, so per-ABI splits would save nothing worth the extra choice.

  // The dependency metadata block AGP writes into the APK signing block is
  // opaque, encrypted-by-Play data. F-Droid's scanner flags it, and nothing in
  // this app needs Play to report its dependencies.
  dependenciesInfo {
    includeInApk = false
    includeInBundle = false
  }

  packaging {
    resources {
      excludes += "/META-INF/{AL2.0,LGPL2.1}"
    }
  }
}

kotlin {
  compilerOptions {
    jvmTarget = JvmTarget.JVM_17
  }
}

dependencies {
  val composeBom = platform(libs.androidx.compose.bom)
  implementation(composeBom)

  implementation(libs.androidx.core.ktx)
  implementation(libs.androidx.appcompat)
  implementation(libs.androidx.activity.compose)
  implementation(libs.androidx.lifecycle.runtime.compose)

  implementation(libs.androidx.compose.ui)
  implementation(libs.androidx.compose.ui.graphics)
  implementation(libs.androidx.compose.ui.tooling.preview)
  implementation(libs.androidx.compose.material3)
  implementation(libs.androidx.compose.material.icons.core)

  debugImplementation(libs.androidx.compose.ui.tooling)

  testImplementation(libs.junit)
}
