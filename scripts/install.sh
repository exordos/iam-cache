#!/usr/bin/env bash
#    Copyright 2026 Genesis Corporation.
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run this script as root." >&2
    exit 1
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
binary=${1:-./exordos-iam-cache}
config_dir=/etc/exordos-iam-cache
config_file="$config_dir/config.json"

if [[ ! -x $binary ]]; then
    echo "Executable IAM cache binary not found: $binary" >&2
    exit 1
fi

install -D -o root -g root -m 0755 "$binary" /usr/local/bin/exordos-iam-cache
install -D -o root -g root -m 0644 \
    "$script_dir/exordos-iam-cache.service" \
    /etc/systemd/system/exordos-iam-cache.service

if [[ ! -f $config_file ]]; then
    install -D -o root -g root -m 0644 \
        "$script_dir/iam_cache.json.example" \
        "$config_file"
fi

if command -v systemctl >/dev/null && [[ -d /run/systemd/system ]]; then
    systemctl daemon-reload
    systemctl enable --now exordos-iam-cache.service
fi
