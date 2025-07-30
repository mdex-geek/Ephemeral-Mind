import com.android.build.gradle.BaseExtension
import org.gradle.api.Project
import org.gradle.api.tasks.Delete
import java.io.File

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Set custom build directory
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    // Move subproject build outputs
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)

    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.application") ||
            project.plugins.hasPlugin("com.android.library")) {

            val android = project.extensions.findByName("android") as? BaseExtension
            android?.apply {
                compileSdkVersion(35)
                buildToolsVersion = "35.0.0"

                // Only set namespace if not already set
                if (this.namespace == null) {
                    this.namespace = project.group.toString()
                }
            }
        }
    }

    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
