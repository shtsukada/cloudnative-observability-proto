BUF ?= buf
BUF_DIR := proto

.PHONY: lint
lint:
	$(BUF) lint $(BUF_DIR)

.PHONY: format
format:
	$(BUF) format -w $(BUF_DIR)

.PHONY: format-check
format-check:
	$(BUF) format --exit-code $(BUF_DIR)

.PHONY: breaking
breaking:
	# main と比較（初回はスキップされる想定）
	$(BUF) breaking $(BUF_DIR) --against '.git#branch=main,subdir=proto'

.PHONY: generate
generate:
	$(BUF) generate --template proto/buf.gen.yaml proto

.PHONY: tidy
tidy:
	go mod tidy

.PHONY: generate-check
generate-check: generate
	git diff --exit-code

.PHONY: tidy-check
tidy-check: tidy
	git diff --exit-code go.mod go.sum
