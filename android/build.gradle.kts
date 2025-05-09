allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.1' // or latest
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
