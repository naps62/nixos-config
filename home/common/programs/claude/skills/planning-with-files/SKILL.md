---
description: Structured planning with persistent markdown files for complex tasks, multi-step projects, and research.
---

# Planning with Files

Use persistent markdown files as your "working memory on disk."

## Quick Start

Before ANY complex task:

1. **Create `task_plan.md`** in the working directory
2. **Define phases** with checkboxes
3. **Update after each phase** - mark [x] and change status
4. **Read before deciding** - refresh goals in attention window

## The 3-File Pattern

For every non-trivial task, create THREE files:

| File | Purpose | When to Update |
|------|---------|----------------|
| `task_plan.md` | Track phases and progress | After each phase |
| `notes.md` | Store findings and research | During research |
| `[deliverable].md` | Final output | At completion |

## Core Workflow

```
Loop 1: Create task_plan.md with goal and phases
Loop 2: Research -> save to notes.md -> update task_plan.md
Loop 3: Read notes.md -> create deliverable -> update task_plan.md
Loop 4: Deliver final output
```

### The Loop in Detail

**Before each major action:**
```
Read task_plan.md  # Refresh goals in attention window
```

**After each phase:**
```
Edit task_plan.md  # Mark [x], update status
```

**When storing information:**
```
Write notes.md     # Don't stuff context, store in file
```

## task_plan.md Template

```markdown
# Task Plan: [Brief Description]

## Goal
[One sentence describing the end state]

## Phases
- [ ] Phase 1: Plan and setup
- [ ] Phase 2: Research/gather information
- [ ] Phase 3: Execute/build
- [ ] Phase 4: Review and deliver

## Key Questions
1. [Question to answer]

## Decisions Made
- [Decision]: [Rationale]

## Errors Encountered
- [Error]: [Resolution]

## Status
**Currently in Phase X** - [What I'm doing now]
```

## Critical Rules

1. **ALWAYS Create Plan First** - Never start a complex task without `task_plan.md`
2. **Read Before Decide** - Before any major decision, read the plan file
3. **Update After Act** - After completing any phase, immediately update the plan
4. **Store, Don't Stuff** - Large outputs go to files, not context
5. **Log All Errors** - Every error goes in the "Errors Encountered" section

## When to Use

**Use for:** Multi-step tasks (3+ steps), research tasks, building/creating something, tasks spanning multiple tool calls

**Skip for:** Simple questions, single-file edits, quick lookups

$ARGUMENTS
