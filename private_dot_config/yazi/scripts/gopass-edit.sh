#!/bin/bash
# Wrapper to edit gopass entries from yazi

file="$1"

# Check if file is in password store
if [[ "$file" == */.password-store/* ]] || [[ "$file" == ~/.password-store/* ]]; then
    # Extract path relative to password store and remove .gpg extension
    store_path="${file#*/.password-store/}"
    store_path="${store_path%.gpg}"

    # Edit with gopass
    gopass edit "$store_path"
else
    # Not a password store file, open with gpg directly or editor
    echo "Not a gopass entry. Press Enter to continue..."
    read
fi
