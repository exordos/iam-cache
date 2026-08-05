## 1. Service user provisioning

- [x] 1.1 In `scripts/install.sh`, ensure a dedicated `iam-cache` system user and group exist, creating them idempotently (no login shell, no home directory) when absent
- [x] 1.2 Keep binary `/usr/local/bin/exordos-iam-cache` and config `/etc/exordos-iam-cache/config.json` owned by `root:root`, readable/executable by the service (existing `install` modes)

## 2. Systemd unit update

- [x] 2.1 Change `scripts/exordos-iam-cache.service` to `User=iam-cache` and `Group=iam-cache`
- [x] 2.2 Confirm the unit still preserves the public Core IAM introspection/JWKS routes and the internal invalidation endpoint (no runtime changes)

## 3. Verification

- [x] 3.1 Run `make test` and `go vet ./...` to confirm the service code and tests are unaffected
- [ ] 3.2 Verify the unit references resolve: `systemctl restart exordos-iam-cache` starts and the process runs as `iam-cache` (`systemctl status`, `ps -o user= -p <pid>`)
- [ ] 3.3 Exercise introspection and JWKS endpoints after migration to confirm unchanged behavior