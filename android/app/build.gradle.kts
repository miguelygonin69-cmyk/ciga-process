// Configuration du module d'application corrigée pour la compatibilité V2/V3, MultiDex et Kotlin.

def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android' // Assure le support Kotlin/Java standard

android {
    namespace "com.ciga.process_final"
    compileSdkVersion flutter.compileSdkVersion
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    defaultConfig {
        applicationId "com.ciga.process_final"
        
        // CRITIQUE : minSDK 21 pour les plugins PDF
        minSdkVersion 21 
        
        // CORRECTION : Active le support MultiDex pour les applications complexes
        multiDexEnabled true 
        
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    // Dépendance essentielle pour les applications MultiDex (Kotlin est géré par Flutter)
    implementation "androidx.multidex:multidex:2.0.1" 
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk8:$kotlin_version"
}