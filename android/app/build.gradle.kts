def flutterProjectRoot = rootProject.projectDir
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'


android {
    // Utiliser le nouvel ID pour éviter l'ancien cache
    namespace "com.ciga.process_final"
    compileSdk flutter.compileSdkVersion
    
    defaultConfig {
        applicationId "com.ciga.process_final" 
        // IMPÉRATIF: minSdk fixé à 21 pour le plugin printing
        minSdkVersion 21 
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    signingConfigs {
        debug {
            storeFile file("debug.keystore")
            storePassword "android"
            keyAlias "androiddebugkey"
            keyPassword "android"
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        debug {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '..'
}

dependencies {
    // Supprimer les dépendances explicites de Kotlin ici, laisser Flutter les gérer
}