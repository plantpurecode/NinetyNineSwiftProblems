set -o pipefail

xcodebuild -project "NinetyNineSwiftProblems.xcodeproj" -scheme "NinetyNineSwiftProblems" -derivedDataPath "./.build" build 2>&1 | xcbeautify
NSUnbufferedIO=YES xcodebuild -project "NinetyNineSwiftProblems.xcodeproj" -scheme "NinetyNineSwiftProblems" -derivedDataPath "./.build" test 2>&1 | xcbeautify
