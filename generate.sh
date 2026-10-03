#!/bin/sh
# Build and run the Project Sekai adaptation of Chorus-ACE/BirthdayCalGen.
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
build_dir=${BIRTHDAY_BUILD_DIR:-"$project_dir/build"}
xcodebuild -quiet -project "$project_dir/SekaiBirthdayCalGen.xcodeproj" \
    -scheme SekaiBirthdayCalGen -configuration Debug -destination 'platform=macOS' \
    -derivedDataPath "$build_dir" CODE_SIGNING_ALLOWED=NO build
exec "$build_dir/Build/Products/Debug/SekaiBirthdayCalGen" "$@"
