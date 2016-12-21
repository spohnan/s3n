#!/usr/bin/env bash

# Put the test stubs at the front of the application search path
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH="$SCRIPT_DIR/stubs:$PATH"

testKeyName() {
    assertEquals "acbd18-foo" $(s3n-key-name "foo")
}

testEmptyKeyName() {
    assertEquals "ERROR" $(s3n-key-name "")
}

. "${SCRIPT_DIR}/../src/alias.sh"
. shunit2
