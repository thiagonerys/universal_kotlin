#!/bin/bash

# This script is referenced in the following files:
#   application/mobile/native/apple/ios/ios_x64/application.xcodeproj/project.pbxproj
#   application/mobile/native/apple/ios/ios_x64_with_framework/application.xcodeproj/project.pbxproj
#   application/mobile/native/apple/ios/ios_x64_copying_framework/iosApp.xcodeproj/project.pbxproj
#   application/mobile/native/apple/ios/ios_x64_framework/framework.xcodeproj/project.pbxproj

if [[ -z "$module" ]]; then
    printf "Module name not found. Check if the 'shellScript' entry is correctly configured in your 'project.pbxproj' file."

    exit 1
fi

export enabledModules="$module"
export task=":application:application-mobile:application-mobile-native:application-mobile-native-apple:application-mobile-native-apple-ios:$module"

printf "Environment Variables:\n"
env | sort


printf "Before - Contents of $TARGET_BUILD_DIR"
tree $TARGET_BUILD_DIR

if [ "$module" = "application-mobile-native-apple-ios-ios_x64" ]; then
    echo "Skipping"
    # rm -f $TARGET_BUILD_DIR/$EXECUTABLE_PATH
fi

if [ "$module" = "application-mobile-native-apple-ios-ios_x64_copying_framework" ]; then
    ./gradlew --stacktrace --warning-mode all \
        -p $SRCROOT/ \
        -Pconfiguration.build.dir=$CONFIGURATION_BUILD_DIR \
        -Pkotlin.build.type=$KOTLIN_BUILD_TYPE \
        -Pkotlin.target=$KOTLIN_TARGET \
        "$task:copyFramework"
elif [ -z $KOTLIN_NATIVE_BUILD_CAPABLE ]; then
    ./gradlew --stacktrace --warning-mode all "$task:buildForXcode"
else
    printf "Uknown module '$module'. Not target action defined"

    exit 2
fi

if [ "$module" = "application-mobile-native-apple-ios-ios_x64" ]; then
    mkdir -p $TARGET_BUILD_DIR/application.app
    mv "$TARGET_BUILD_DIR/$module.kexe" $TARGET_BUILD_DIR/application.app/application
fi

printf "After - Contents of $TARGET_BUILD_DIR"
tree $TARGET_BUILD_DIR
