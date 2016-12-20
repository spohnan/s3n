# s3n

IMAGE := spohnan/shunit2
ALIAS_FILE = ~/.aws/cli/alias
BUILD_REGEX = 's/^s3n[a-zA-Z0-9-]*/& = !f/; s/^}/ }; f/; s/\#!\/usr\/bin\/env bash/\[toplevel\]/'

build: test
	@sed $(BUILD_REGEX) src/alias.sh > alias

deploy: test build
	@if [ ! -d $(shell dirname $(ALIAS_FILE)) ]; then mkdir -p $(shell dirname $(ALIAS_FILE)); fi
	@cat alias > $(ALIAS_FILE)

test:
	@echo Starting test run ...
	@docker run --rm -v $$(pwd):/tmp/s3n $(IMAGE) bash /tmp/s3n/test/test.sh

.PHONY: build deploy test