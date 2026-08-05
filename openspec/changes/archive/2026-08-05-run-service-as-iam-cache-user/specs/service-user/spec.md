## Purpose

Establishes a dedicated least-privilege system user for running the IAM cache service instead of the shared host account.

## ADDED Requirements

### Requirement: Dedicated service user
The IAM cache service SHALL run under a dedicated system user and group named `iam-cache`.

#### Scenario: Service runs as dedicated user
- **WHEN** the service is started under systemd
- **THEN** the process runs with the primary user and group `iam-cache`, not the shared host account

#### Scenario: Service user is non-interactive
- **WHEN** the `iam-cache` user is created
- **THEN** it is a system user with no login shell and no home directory

### Requirement: Service assets owned by service scope
Service assets SHALL be owned by and accessible only to the `iam-cache` service scope, with the executable accessible to the service user.

#### Scenario: Config file ownership
- **WHEN** the service is installed
- **THEN** `/etc/exordos-iam-cache/config.json` is readable by the `iam-cache` user and not modifiable by other users

#### Scenario: Binary installed for the service
- **WHEN** the service is installed
- **THEN** `/usr/local/bin/exordos-iam-cache` is executable by the `iam-cache` user

### Requirement: Migration preserves service behavior
Transitioning to the `iam-cache` user SHALL NOT change the public Core IAM introspection and JWKS routes or the internal invalidation endpoint.

#### Scenario: Routes unchanged after migration
- **WHEN** the service is migrated to run as `iam-cache` and restarted
- **THEN** the public introspection and JWKS endpoints respond as before