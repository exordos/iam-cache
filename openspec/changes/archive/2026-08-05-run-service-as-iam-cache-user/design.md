## Context

The service unit `scripts/exordos-iam-cache.service` currently declares `User=ubuntu` / `Group=ubuntu`, and `scripts/install.sh` copies the binary and config as `root:root` with no dedicated service account. The service is in-memory; restarting it drops the cache, so the migration is safe to apply on a restart. See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**
- Run the service under a dedicated `iam-cache` system user and group (least privilege).
- Keep the public Core IAM introspection/JWKS routes and the internal invalidation endpoint unchanged.
- Make the install script idempotent (safe to re-run) and upgrade-safe for existing installs.

**Non-Goals:**
- No changes to request routing, cache, or invalidation logic.
- No containerization or systemd hardening directives beyond the user/group change (out of scope here).

## Decisions

- **Create user via `useradd`/`adduser` when missing, not at package build time.** The service is installed by `scripts/install.sh`, so user creation belongs there. Use `id -u iam-cache` to gate creation so re-runs are idempotent. Create with `--system --no-create-home --shell /usr/sbin/nologin` (Debian/Ubuntu useradd flags `-r -M -s /usr/sbin/nologin`).
  - *Alternative considered:* a static UID + pre-provisioned account via cloud-init. Rejected - adds deployment coupling and breaks where the script runs ad-hoc.
- **Keep binary ownership as `root:root` with mode `0755`** and rely on the unit's `User` directive to run as `iam-cache`. Executable files owned by root but world-*readable/executable* is standard for system binaries; the process still drops to `iam-cache` at runtime. Config stays `root:root` `0644`. No file needs to be *owned* by the service user since the cache is in-memory and the service does not write to disk.
  - *Alternative considered:* chown config to `iam-cache:iam-cache`. Rejected - unnecessary write access violates least privilege for a read-only in-memory cache.
- **Set `User=iam-cache` / `Group=iam-cache` in the unit.** This is the single behavioral switch; it fully replaces the `ubuntu` account at runtime.

## Risks / Trade-offs

- [Service restart during migration clears the in-memory cache] → inherent and acceptable; the cache repopulates on next introspection/JWKS request, same as any restart.
- [Existing installs already placed config/binary under `/etc`/`/usr/local/bin` that the new user must read] → `iam-cache` needs read/execute only; keep those dirs world-accessible (default) so the new user resolves them.
- [Lack of a login shell/home directory complicates manual debugging] → use `journalctl -u exordos-iam-cache` and `systemctl status` rather than shelling in as the service user.

## Migration Plan

1. Update `install.sh` to ensure the `iam-cache` user/group exist (idempotent).
2. Update the systemd unit `User`/`Group` to `iam-cache`.
3. Run `install.sh` to re-install the binary/unit and create the user.
4. `systemctl daemon-reload && systemctl restart exordos-iam-cache`.
5. Verify with `systemctl status`, `ps -o user= -p <pid>` (should show `iam-cache`), and exercising the introspection/JWKS endpoints.

**Rollback:** revert the unit to `User=ubuntu`/`Group=ubuntu`, `systemctl daemon-reload && systemctl restart exordos-iam-cache`. Cache impact is limited to a restart.

## Open Questions

None.