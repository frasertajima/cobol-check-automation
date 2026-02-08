#!/bin/sh
# lab incorrectly assumed binary when it is .jar file that is the executable
ZOWE_USERNAME="$1"

if [ -z "$ZOWE_USERNAME" ]; then
  echo "ERROR: ZOWE_USERNAME is not set"
  exit 1
fi

BASE_DIR="/z/${ZOWE_USERNAME}/cobolcheck"
BIN_DIR="${BASE_DIR}/bin"
SCRIPT_DIR="${BASE_DIR}/scripts"
JAR="${BIN_DIR}/cobol-check-0.2.19.jar"

# Ensure the JAR exists
if [ ! -f "$JAR" ]; then
  echo "ERROR: cobol-check JAR not found at $JAR"
  exit 1
fi

# Ensure test runner script is executable
cd "$SCRIPT_DIR" || { echo "ERROR: Cannot cd to $SCRIPT_DIR"; exit 1; }
chmod +x linux_gnucobol_run_tests

# Return to base directory
cd "$BASE_DIR" || exit 1

run_cobolcheck() {
  program="$1"
  echo "Running cobolcheck for $program"

  # Run cobolcheck via Java
  java -jar "$JAR" -p "$program" || true

  # Copy generated COBOL source
  if [ -f "CC##99.CBL" ]; then
    cp CC##99.CBL "//'$ZOWE_USERNAME.CBL($program)'" \
      && echo "Copied CC##99.CBL to $ZOWE_USERNAME.CBL($program)" \
      || echo "Failed to copy CC##99.CBL"
  else
    echo "CC##99.CBL not found"
  fi

  # Copy generated JCL
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
