# COBOL Check Automation - Key Learnings

## Project Structure
- cobol-check 0.2.19 runs on z/OS USS via Java JAR (not binary)
- Config: `cobol-check-0.2.19/config.properties`
- cobol-check expects sources at `src/main/cobol/`, tests at `src/test/cobol/<PROGRAM>/`
- Lab puts files at repo root (*.CBL, *.JCL) and `test/<PROGRAM>/` - workflow must map these to USS paths

## Common Issues & Fixes
- **USS paths are case-sensitive**: Use lowercase `/z/` not `/Z/`, lowercase usernames
- **COBOL fixed-format**: Files must have 7-space prefix (cols 1-6 seq + col 7 indicator). Zed editor may strip these
- **JCL IF/ENDIF**: Must be `// IF` and `// ENDIF` (space after `//`), not `//IF`
- **cobol-check test.run**: Set to `false` on z/OS since `zos.process` is not configured (avoids NullPointerException)
- **Generated files**: `CC##99.CBL` goes to `testruns/` subdirectory, not base dir
- **Test suite (.cut) files**: Variable names must not have spaces around hyphens (`EMP-HOURS` not `EMP - HOURS`)
- **Zowe upload**: `upload file-to-uss` does NOT create intermediate directories - must create them first with `create uss-directory`
- **GitHub Actions**: Secrets are masked as `***` in logs (cosmetic only). Use `${VAR,,}` for bash lowercase

## Zowe Commands
- List jobs: `zowe jobs list jobs --owner Z89165 --prefix "*"`
- View job output: `zowe jobs view all-spool-content JOBxxxxx`
- GitHub PAT needs `workflow` scope to push changes to `.github/workflows/`
