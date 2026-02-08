#!/bin/sh

ZOWE_USERNAME="$1"

if [ -z "$ZOWE_USERNAME" ]; then
  echo "ERROR: ZOWE_USERNAME is not set"
  exit 1
fi


cd cobolcheck
chmod +x cobolcheck

cd scripts
chmod +x linux_gnucobol_run_tests
cd ..

run_cobolcheck() {
  program=$1
  echo "Running cobolcheck for $program"

  ./cobolcheck -p "$program" || true

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

    run_cobolcheck $program
done
echo "Mainframe operations completed"
