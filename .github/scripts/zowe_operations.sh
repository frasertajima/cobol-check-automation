#!/bin/bash

if [ -z "$ZOWE_USERNAME" ]; then
  echo "ERROR: ZOWE_USERNAME is not set"
  exit 1
fi

LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
USS_DIR="/z/$LOWERCASE_USERNAME/cobolcheck"

echo "Using USS directory: $USS_DIR"

# Check if directory exists
if ! zowe zos-files list uss-files "$USS_DIR" >/dev/null 2>&1; then
  echo "Directory does not exist. Creating it..."
  zowe zos-files create uss-directory "$USS_DIR"
else
  echo "Directory already exists."
fi

# Upload cobol-check distribution (binary-safe)
echo "Uploading cobol-check distribution..."
zowe zos-files upload dir-to-uss "./cobol-check-0.2.19" "$USS_DIR" --recursive --binary

echo "Verifying upload:"
zowe zos-files list uss-files "$USS_DIR"


