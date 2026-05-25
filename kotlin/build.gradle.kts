// Kotlin / JVM library: Coptic calendar arithmetic.
// Publishes com.wizardlabz:kiahk to Maven Central via the Sonatype Central Portal.
//
// vanniktech.maven.publish bundles:
//   - GPG signing (in-memory key via ORG_GRADLE_PROJECT_signing* properties)
//   - Sources + Javadoc jars
//   - Central Portal upload (no manual staging-repo dance)

import com.vanniktech.maven.publish.SonatypeHost
import com.vanniktech.maven.publish.KotlinJvm
import com.vanniktech.maven.publish.JavadocJar

plugins {
    // Latest stable Kotlin 2.x; compatible with Gradle 8.x and 9.x.
    kotlin("jvm") version "2.1.20"
    // Vanniktech's plugin handles Central Portal upload + signing.
    id("com.vanniktech.maven.publish") version "0.30.0"
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(kotlin("test"))
    testImplementation("org.junit.jupiter:junit-jupiter:5.11.3")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
    // Tiny, zero-transitive-deps JSON parser — used only to read the shared
    // cross-port test contract at core/test-vectors.json. Not exposed in
    // the published library API.
    testImplementation("com.google.code.gson:gson:2.11.0")
}

kotlin {
    // JVM 11 is the broadest practical baseline for Android + server-side
    // (Android API 26+ supports Java 11 source/target via desugaring; Compose
    // requires it).
    jvmToolchain(11)
}

tasks.test {
    useJUnitPlatform()
    testLogging {
        events("passed", "skipped", "failed")
        showStandardStreams = false
    }
}

// Sources + Javadoc jars are picked up automatically by vanniktech plugin.

mavenPublishing {
    // CENTRAL_PORTAL = Sonatype's newer pipeline (not the legacy OSSRH).
    publishToMavenCentral(SonatypeHost.CENTRAL_PORTAL)

    // Signing is required for Maven Central. Credentials come from
    // ORG_GRADLE_PROJECT_signingInMemoryKey / *Password env vars in CI;
    // local dev can use ~/.gradle/gradle.properties.
    signAllPublications()

    configure(KotlinJvm(javadocJar = JavadocJar.Empty()))

    coordinates(group.toString(), "kiahk", version.toString())

    pom {
        name.set("Kiahk")
        description.set("Coptic calendar arithmetic — date conversion, Easter, and feast days. Kotlin/JVM port of kiahk.")
        url.set("https://github.com/amir-magdy-of-wizardlabz/kiahk")
        inceptionYear.set("2026")
        licenses {
            license {
                name.set("MIT License")
                url.set("https://opensource.org/licenses/MIT")
                distribution.set("repo")
            }
        }
        developers {
            developer {
                id.set("amir-magdy-of-wizardlabz")
                name.set("Amir Magdy")
                email.set("amir.magdy@wizardlabz.com")
                organization.set("WizardLabz")
                organizationUrl.set("https://wizardlabz.com")
            }
        }
        scm {
            url.set("https://github.com/amir-magdy-of-wizardlabz/kiahk")
            connection.set("scm:git:git://github.com/amir-magdy-of-wizardlabz/kiahk.git")
            developerConnection.set("scm:git:ssh://git@github.com/amir-magdy-of-wizardlabz/kiahk.git")
        }
        issueManagement {
            system.set("GitHub Issues")
            url.set("https://github.com/amir-magdy-of-wizardlabz/kiahk/issues")
        }
    }
}
