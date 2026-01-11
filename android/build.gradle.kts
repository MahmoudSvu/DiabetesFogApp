allprojects {
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

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
