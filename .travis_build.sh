set -o pipefail

xcodebuild -project "NinetyNineSwiftProblems.xcodeproj" -scheme "NinetyNineSwiftProblems" -derivedDataPath "./.build" build test
