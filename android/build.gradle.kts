allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Patch unmigrated plugins before Gradle configures Android library projects.
val patchKotlinPlugins = rootProject.file("../tool/patch_kotlin_plugins.ps1")
if (patchKotlinPlugins.exists()) {
    providers.exec {
        commandLine(
            "powershell",
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            patchKotlinPlugins.absolutePath,
        )
    }.result.get()
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
