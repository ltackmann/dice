#!/bin/bash
set -e

#dartanalyzer --fatal-warnings .

if [ "$COVERALLS_TOKEN" ]; then
  # run tests on travis and publish code coverage
  pub global activate dart_coveralls
  pub global run dart_coveralls report \
    --token $COVERALLS_TOKEN \
    --retry 2 \
    --exclude-test-files \
    test/dice_test.dart
else
  # run tests locally
  dart test/dice_test.dart
fi
