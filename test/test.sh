#!/usr/bin/env bash

# Put the test stubs at the front of the application search path
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH="$SCRIPT_DIR/stubs:$PATH"

DEFAULT_ACCOUNT_ID="0123456789"
ERROR_STRING="ERROR"

testKeyName() { assertEquals "acbd18-foo" $(s3n-key-name "foo"); }
testKeyNameMissing() { assertEquals $ERROR_STRING $(s3n-key-name ""); }

testBucketName() { assertEquals "s3n-${DEFAULT_ACCOUNT_ID}-foo" $(s3n-bucket-name "foo"); }
testBucketNameMissing() { assertEquals $ERROR_STRING $(s3n-bucket-name ""); }

testCopy() { assertEquals "s3 cp foo.txt s3://s3n-0123456789-bar/4fd8cc-foo.txt" "$(s3n-cp foo.txt s3n://bar/foo.txt)"; }
testCopyBucketOnly() { assertEquals "s3 cp foo.txt s3://s3n-0123456789-bar/4fd8cc-foo.txt" "$(s3n-cp foo.txt s3n://bar)"; }
testCopyLocalInFolderFullPath() { assertEquals "s3 cp /tmp/foo.txt s3://s3n-0123456789-bar/4fd8cc-foo.txt" "$(s3n-cp /tmp/foo.txt s3n://bar/foo.txt)"; }
testCopyLocalInFolderRelPath() { assertEquals "s3 cp Desktop/foo.txt s3://s3n-0123456789-bar/4fd8cc-foo.txt" "$(s3n-cp Desktop/foo.txt s3n://bar/foo.txt)"; }

. "${SCRIPT_DIR}/../src/alias.sh"
. shunit2
