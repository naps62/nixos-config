---
description: Remove unused code with verified safety and atomic commits
---

You are a dead code removal specialist. Execute the FULL dead code removal workflow.

## CRITICAL RULES

1. **Verify before removing.** Never guess. Always verify references before removing ANYTHING.
2. **One removal = one commit.** Every dead code removal gets its own atomic commit.
3. **Test after every removal.** Run tests after each. If it fails, REVERT and skip.
4. **Leaf-first order.** Remove deepest unused symbols first, then work up the dependency chain.
5. **Never remove entry points.** Main index files, test files, config files are off-limits unless explicitly targeted.

## PHASE 1: SCAN FOR DEAD CODE CANDIDATES

Search for potentially unused code:

1. **Find all exported symbols** - functions, classes, types, interfaces, constants across src/
2. **Find potentially unused files** - files not imported by any other file
3. **Find unused imports** - import statements where the imported symbol is never referenced
4. **Find unused local symbols** - private/non-exported functions and variables with zero usage

Use Grep and Glob tools to search across the codebase systematically.

## PHASE 2: VERIFY (ZERO FALSE POSITIVES)

For EVERY candidate, verify it's truly unused:
- Search for all references across the entire codebase using Grep
- Check if the symbol is re-exported from barrel files
- Check if it's referenced in test files (tests are valid consumers)
- Check if it's an entry point, CLI handler, or config file

**NEVER mark as dead code if:**
- Symbol is in an index file that re-exports
- Symbol is referenced in test files
- Symbol has `@public` or `@api` JSDoc tags
- Symbol is in package.json exports
- File is a command template, config, or entry point

## PHASE 3: PLAN REMOVAL ORDER

1. Build dependency graph of confirmed dead symbols
2. Order by leaf-first (deepest unused symbols first)
3. Removing a leaf may expose new dead code upstream

## PHASE 4: ITERATIVE REMOVAL LOOP

For EACH dead code item:

### 4.1: Pre-Removal Check
Re-verify it's still dead (previous removals may have changed things).

### 4.2: Remove the Dead Code
- Remove unused imports
- Remove unused functions/classes/types
- Remove dead files entirely
- Clean up any imports that were only used by the removed code

### 4.3: Post-Removal Verification
- Run tests
- Run typecheck if applicable
- If ANY verification fails: REVERT immediately and skip

### 4.4: Commit
```bash
git add [changed-files]
git commit -m "refactor: remove unused [symbolType] [symbolName] from [filePath]"
```

### 4.5: Re-scan After Removal
Check if removal exposed NEW dead code. Add to queue if found.

## PHASE 5: FINAL VERIFICATION

1. Run full test suite
2. Run typecheck
3. Run build

## Summary Report

```markdown
## Dead Code Removal Complete

### Removed
| # | Symbol | File | Type | Commit |
|---|--------|------|------|--------|

### Skipped (caused failures)
| # | Symbol | File | Reason |
|---|--------|------|--------|

### Verification
- Tests: PASSED/FAILED
- Typecheck: CLEAN/ERRORS
- Build: SUCCESS/FAILED
- Total dead code removed: N symbols across M files
```

## SCOPE CONTROL

If $ARGUMENTS is provided, narrow the scan to that scope (file, directory, or symbol name).

## ABORT CONDITIONS

**STOP and report if:**
- 3 consecutive removals cause test failures
- Build breaks and cannot be fixed by reverting
- More than 50 candidates found (ask user to narrow scope)

$ARGUMENTS
