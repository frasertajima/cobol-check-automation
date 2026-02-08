#!/bin/sh

# Username passed from GitHub Actions
ZOWE_USERNAME="$1"

if [ -z "$ZOWE_USERNAME" ]; then
  echo "ERROR: ZOWE_USERNAME is not set"
  exit 1
fi

# Base directory on USS
BASE_DIR="/z/${ZOWE_USERNAME}/cobolcheck"
BIN_DIR="${BASE_DIR}/bin"
SCRIPT_DIR="${BASE_DIR}/scripts"

# Ensure cobolcheck binary is executable
cd "$BIN_DIR" || { echo "ERROR: Cannot cd to $BIN_DIR"; exit 1; }
chmod +x cobolcheck

# Ensure test runner script is executable
cd "$SCRIPT_DIR" || { echo "ERROR: Cannot cd to $SCRIPT_DIR"; exit 1; }
chmod +x linux_gnucobol_run_tests

# Return to base directory for running cobolcheck
cd "$BASE_DIR" || exit 1

run_cobolcheck() {
  program="$1"
  echo "Running cobolcheck for $program"

  "$BIN_DIR/cobolcheck" -p "$program" || true

  if [ -f "CC##99.CBL" ]; then
    cp CC##99.CBL "//'$ZOWE_USERNAME.CBL($program)'" \
      && echo "Copied CC##99.CBL to $ZOWE_USERNAME.CBL($program)" \
      || echo "Failed to copy CC##99.CBL"
  else
    echo "CC##99.CBL not found"
  fi

  if [ -f "${program}.JCL" ]; then
    cp "${program}.JCL" "//'$ZOWE_USERNAME.JCL($program)'" \
      && echo "Copied ${program}.JCL" \
      || echo "Failed to copy ${program}.JCL"
  else
    echo "${program}.JCL not found"
  fi
}

for program in NUMBERS EMPPAY DEPTPAY; do
  run_cobolcheck "$program"
done

echo "Mainframe operations completed"

