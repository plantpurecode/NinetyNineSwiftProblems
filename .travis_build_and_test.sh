set -o pipefail

xcodebuild -project "NinetyNineSwiftProblems.xcodeproj" -scheme "NinetyNineSwiftProblems" build test 2>&1 | xcbeautify
