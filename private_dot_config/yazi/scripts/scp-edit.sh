#!/bin/bash
# Open a file from SSHFS mount via scp:// in nvim (faster than FUSE)

file="$1"
mnt_base="$HOME/mnt"

# Check if file is in mount directory
if [[ ! "$file" =~ ^$mnt_base/ ]]; then
    echo "Not an SSHFS path, opening normally..."
    nvim "$file"
    exit 0
fi

# Extract mount folder name and relative path
# e.g., /home/yuv/mnt/deploy@tindo.app-root/var/log/file.txt
# mount_name = deploy@tindo.app-root
# rel_path = /var/log/file.txt

path_after_mnt="${file#$mnt_base/}"
mount_name="${path_after_mnt%%/*}"
rel_path="${path_after_mnt#$mount_name}"

# Parse user@host from mount_name
# Pattern: user@host-root or user@host-path-to-dir or just user@host
if [[ "$mount_name" =~ ^(.+@[^-]+)-root$ ]]; then
    # Mounted from root: user@host-root
    user_host="${BASH_REMATCH[1]}"
    remote_path="$rel_path"
elif [[ "$mount_name" =~ ^(.+@[^-]+)-(.+)$ ]]; then
    # Mounted from specific path: user@host-path-name
    user_host="${BASH_REMATCH[1]}"
    # For non-root mounts, path is relative to home or specified dir
    remote_path="$rel_path"
else
    # Mounted from home: user@host (no suffix)
    user_host="$mount_name"
    remote_path="$rel_path"
fi

# Construct scp:// URL
# nvim scp:// format: scp://user@host//absolute/path (double slash for absolute)
scp_url="scp://${user_host}/${remote_path}"

echo "Opening via SCP: $scp_url"
nvim "$scp_url"
