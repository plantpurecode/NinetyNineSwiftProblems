set -o pipefail

mkdir .output
touch ./.output/coverage.lcov
xcrun llvm-cov export -format lcov -instr-profile \
  $(find ./.build/Build/ProfileData -name "Coverage.profdata") \
  ./.build/Build/Products/Debug/NinetyNineSwiftProblems.app/Contents/MacOS/NinetyNineSwiftProblems > ./.output/coverage.lcov
bundle exec coveralls-lcov --repo-token "$COVERALLS_REPO_TOKEN" ./.output/coverage.lcov
