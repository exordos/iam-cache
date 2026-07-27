# Contributor Guide

## Project Structure

This is a Go 1.23 in-memory proxy cache for Exordos Core IAM introspection and JWKS requests. Keep the executable entry point in `cmd/exordos-iam-cache/main.go`. Application code and its unit tests live together in `internal/app/` (for example, `cache.go` and `cache_test.go`). Deployment assets are in `scripts/`; GitHub Actions workflows are in `.github/workflows/`.

Read `README.md` before changing request-routing, cache, or invalidation behavior. The public API must preserve Core IAM routes; the internal invalidation endpoint is intentionally separate.

## Build, Test, and Run

- `make build` — builds `iam-cache` from `./cmd/exordos-iam-cache`.
- `make test` — runs the race-enabled suite and `go vet`.
- `go test -race ./...` — run all tests while detecting data races.
- `go vet ./...` — perform static checks.
- `go run ./cmd/exordos-iam-cache -config scripts/iam_cache.json.example` — run locally with the example configuration.

Before submitting changes, run `gofmt -w` on modified Go files, then run `make test`. CI also builds the command with `go build ./cmd/exordos-iam-cache`.

## Go Style and Tests

Follow standard Go conventions: use `gofmt`, tabs for indentation, lower-case package names, and exported identifiers only when needed outside the package. Prefer focused, unexported helpers. Name tests `Test<Behavior>` (for example, `TestIntrospectionCacheHonorsTTLAndTokenExpiration`), use table-driven subtests for related cases, and call `t.Parallel()` only when state is isolated. Add regression tests for all behavior changes, especially cache keys, TTL/expiry, invalidation, and concurrent requests.

## Commits and Pull Requests

Recent commits follow Conventional Commit-style prefixes, such as `feat(iam): add in-memory introspection cache`, `ci: add IAM cache tests`, and `chore(deps): bump actions/setup-go`. Use an imperative, concise subject; scope feature changes when useful.

PRs should explain the behavior change, configuration or deployment impact, and test commands run. Link the related issue when applicable. Include request/response examples for API changes and document any operational or security implications. Do not commit built binaries, local IDE files, or production configuration values.
