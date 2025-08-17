BUF ?= buf

.PHONY: lint
lint:
	$(BUF) lint

.PHONY: breaking
breaking:
	# main と比較（初回はスキップされる想定）
	$(BUF) breaking --against '.git#branch=main'

.PHONY: generate
generate:
	$(BUF) generate

.PHONY: tidy
tidy:
	go mod tidy
