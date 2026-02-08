#!/bin/sh
# lab incorrectly assumed binary when it is .jar file that is the executable
ZOWE_USERNAME="$1"

if [ -z "$ZOWE_USERNAME" ]; then
  echo "ERROR: ZOWE_USERNAME is not set"
  exit 1
fi

BASE_DIR="/z/${ZOWE_USERNAME}/cobolcheck"
BIN_DIR="${BASE_DIR}/bin"
JAR="${BIN_DIR}/cobol-check-0.2.19.jar"

# Ensure the JAR exists
if [ ! -f "$JAR" ]; then
  echo "ERROR: cobol-check JAR not found at $JAR"
  exit 1
fi

# Work from the base directory
cd "$BASE_DIR" || { echo "ERROR: Cannot cd to $BASE_DIR"; exit 1; }

run_cobolcheck() {
  program="$1"
  echo "Running cobolcheck for $program"

  # Run cobolcheck via Java (test.run=false, generate only)
  java -jar "$JAR" -p "$program" || true

  # Copy generated COBOL test program from testruns/ to MVS dataset
  if [ -f "testruns/CC##99.CBL" ]; then
    cp "testruns/CC##99.CBL" "//'$ZOWE_USERNAME.CBL($program)'" \
      && echo "Copied testruns/CC##99.CBL to $ZOWE_USERNAME.CBL($program)" \
      || echo "Failed to copy CC##99.CBL"
  else
    echo "testruns/CC##99.CBL not found for $program"
  fi
}

for program in NUMBERS EMPPAY DEPTPAY; do
  run_cobolcheck "$program"
done

echo "Mainframe operations completed"
