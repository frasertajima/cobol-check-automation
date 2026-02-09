# COBOL Check Automation - Key Learnings

## Project Structure
- cobol-check 0.2.19 runs on z/OS USS via Java JAR (not binary)
- Config: `cobol-check-0.2.19/config.properties`
- cobol-check expects sources at `src/main/cobol/`, tests at `src/test/cobol/<PROGRAM>/`
- Lab puts files at repo root (*.CBL, *.JCL) and `test/<PROGRAM>/` - workflow must map these to USS paths
- Program names must NOT contain hyphens in filenames (`DEPTPAY` not `DEPT-PAY`) since the name is used as PROGRAM-ID and load module name

## Workflow File Mapping (main.yml step 3)
- `*.CBL` (repo root) → uploaded to `src/main/cobol/` on USS
- `test/<PROGRAM>/*.cut` (repo) → uploaded to `src/test/cobol/<PROGRAM>/` on USS (directory created first)
- `*.JCL` (repo root) → uploaded to cobolcheck root on USS

## Common Issues & Fixes
- **USS paths are case-sensitive**: Use lowercase `/z/` not `/Z/`, lowercase usernames
- **COBOL fixed-format**: Files must have 7-space prefix (cols 1-6 seq + col 7 indicator). Zed editor strips these — always verify column layout before committing
- **DATA DIVISION header**: Must include `DATA DIVISION.` before `WORKING-STORAGE SECTION.` — easy to miss
- **JCL IF/ENDIF**: Must be `// IF` and `// ENDIF` (space after `//`), not `//IF`
- **JCL member names**: SYSIN/SYSLMOD must match the program name (`DEPTPAY` not `CBL0001`)
- **JCL RUN step**: Needs SYSOUT, CEEDUMP, SYSUDUMP DD statements
- **cobol-check test.run**: Set to `false` on z/OS since `zos.process` is not configured (avoids NullPointerException)
- **Generated files**: `CC##99.CBL` goes to `testruns/` subdirectory, not base dir
- **Test suite (.cut) files**: Variable names must NOT have spaces around hyphens (`EMP-HOURS` not `EMP - HOURS`). Spaces cause cobol-check to generate 0 procedure division statements → IGZ0037S runtime fall-through error
- **Zowe upload**: `upload file-to-uss` does NOT create intermediate directories - must create them first with `create uss-directory`
- **GitHub Actions**: Secrets are masked as `***` in logs (cosmetic only). Use `${VAR,,}` for bash lowercase

## Zowe Commands
- List jobs: `zowe jobs list jobs --owner Z89165 --prefix "*"`
- View job output: `zowe jobs view all-spool-content JOBxxxxx`
- GitHub PAT needs `workflow` scope to push changes to `.github/workflows/`

## Debugging Compile/Runtime Errors
- `Procedure Division statements = 0` in compile listing → test suite (.cut) parsing failed, check for spaces in variable names
- `IGZ0037S flow of control proceeded beyond last line` → no STOP RUN executed, likely empty procedure division from bad .cut
- `IGYDS0009-E should not begin in area A` → missing 7-space prefix in CBL file
- `IEFC605I UNIDENTIFIED OPERATION FIELD` → JCL IF/ENDIF missing space after `//`
- `S806 MODULE NOT FOUND` → JCL compiles as one member name but runs as another

## suggested improvements
Add result capture to the workflow** — We could add a step to `main.yml` that automatically lists and fetches the job output after submission, so it appears directly in the GitHub Actions log.

The JCL currently doesn't get *submitted* by the workflow though — cobol-check generates the merged program, copies it to the MVS dataset, but the JCL has to be submitted separately (either manually via VSCode or via Zowe). It should eventually have a fully automated submit + result capture.
