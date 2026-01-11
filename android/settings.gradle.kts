pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        // Flutter repository (must be first)
        maven {
            url = uri("https://storage.googleapis.com/download.flutter.io")
            name = "Flutter"
        }
        // Try Google Maven first
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroup("com.android.tools.external.com-intellij")
            }
        }
        mavenCentral()
        gradlePluginPortal()
        // Mirrors in case of connection issues
        maven {
            url = uri("https://jcenter.bintray.com/")
            isAllowInsecureProtocol = false
        }
        maven {
            url = uri("https://repo1.maven.org/maven2/")
        }
        // Alternative Google Maven mirror
        maven {
            url = uri("https://maven.google.com")
            name = "Google"
        }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")