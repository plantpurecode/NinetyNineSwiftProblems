set -o pipefail

xcodebuild -project "NinetyNineSwiftProblems.xcodeproj" -scheme "NinetyNineSwiftProblems" build 2>&1 | xcbeautify
NSUnbufferedIO=YES xcodebuild -project "NinetyNineSwiftProblems.xcodeproj" -scheme "NinetyNineSwiftProblems" test 2>&1 | xcbeautify
