#! /bin/bash

version="v1.0"

if [[ $1 == "-h" || $1 == "--help" ]]; then
    echo "[INFO] APK builder script"
    echo "0. Creates build APK using flutter build"
    echo "1. Adds unique identifier - <branch>-<hash>-<timestamp> - to the APK"
    echo "2. By default, installs build APK on your phone."
    echo "3. Running 'bash build.sh no-install' or './build.sh no-install' skips installation"
    exit 0
fi

inputBuildDir="build/app/outputs/apk/release"
if [ ! -d $inputBuildDir ]; then
    echo "[WARN] '${inputBuildDir}' does not exist"
fi
inputBuildAPKFilename="app-release.apk"
outputBuildDir="build-apks"

function createBuildsDir {
    # Creates output build directory if it does not exist
    if [[ ! -d $outputBuildDir ]]; then
        echo "[INFO] '$outputBuildDir' does not exist. Creating directory..."
        mkdir $outputBuildDir
    fi
}

function cleanFlutterBuilds {
    # Removes existing 'build' directory
    echo "[WARN] Running flutter clean"
    flutter clean
}

function buildFutter {
    # Creates build APK
    echo "[INFO] Building flutter apk..."
    flutter build apk
}

function createOutputBuildAPK {
    # Creates output build APK - <branch>-<hash>-<timestamp>.apk
    currentBranch=$(git branch | grep \* | awk '{print $2}')
    latestCommitHashShort=$(git rev-parse --short HEAD)
    currentTimestamp=$(date "+%H%M%S_%d%m%Y")
    outputAPKFilename="${currentBranch}-${latestCommitHashShort}-${currentTimestamp}.apk"
    _in=$inputBuildDir/$inputBuildAPKFilename
    _out=$outputBuildDir/$outputAPKFilename
    echo "[INFO] Copying relase apk from $_in to $_out"
    cp $_in $_out
}

function installFlutterBuild {
    # Installs flutter build apk
    echo "[INFO] Installing flutter build..."
    flutter install
}

createBuildsDir
cleanFlutterBuilds
buildFutter
if [[ $1 == "no-install" ]]; then
    echo "[WARN] Not installing flutter build apk..."
else
    installFlutterBuild
fi
