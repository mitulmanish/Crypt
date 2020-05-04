#!/bin/bash
if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download using `brew install Swiftlint`"
fi
