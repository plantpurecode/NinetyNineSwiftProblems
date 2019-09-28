set -o pipefail

NSUnbufferedIO=YES xcodebuild -project "NinetyNineSwiftProblems.xcodeproj" -scheme "NinetyNineSwiftProblems" -derivedDataPath "./.build" build test 2>&1 | xcbeautify
