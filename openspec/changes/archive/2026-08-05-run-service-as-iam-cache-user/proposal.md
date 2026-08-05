## Why

The IAM cache service currently runs as the shared `ubuntu` user, granting the process access to the host account's home directory and privileges it does not need. Running the service under a dedicated, minimal-privilege `iam-cache` system user reduces the blast radius of a compromise and follows least-privilege best practices for system services.

## What Changes

- Add an `iam-cache` system user (no login shell, no home directory) on install.
- Update the systemd unit (`scripts/exordos-iam-cache.service`) to run `ExordosIAMCache` under `User=iam-cache`/`Group=iam-cache` instead of `ubuntu`.
- Update `scripts/install.sh` to create the dedicated user and restrict ownership/permissions of the service config and binary to that user as appropriate.
- No change to the public Core IAM introspection/JWKS routes; request routing and the internal invalidation endpoint are unaffected.

## Capabilities

### New Capabilities
- `service-user`: Run the IAM cache service under a dedicated least-privilege `iam-cache` system user and group.

### Modified Capabilities
<!-- none -->

## Impact

- `scripts/exordos-iam-cache.service` — service unit `User`/`Group` directives changed from `ubuntu` to `iam-cache`.
- `scripts/install.sh` — gains user/group creation and tightened file ownership/permissions for `/usr/local/bin/exordos-iam-cache` and `/etc/exordos-iam-cache/config.json`.
- `scripts/iam_cache.json.example` — unaffected.
- Deployment/operations: existing installs upgrading will transition from `ubuntu` to the `iam-cache` user; the cache is in-memory and invalidated on restart, so a service restart during the migration is expected.