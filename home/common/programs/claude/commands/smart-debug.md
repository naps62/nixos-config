---
description: Debug complex issues with root cause analysis and multiple fix approaches
---

Debug complex issues using a structured debugging approach:

## Debugging Approach

### 1. Primary Debug Analysis
- Analyze error messages and stack traces
- Identify code paths leading to the issue
- Reproduce the problem systematically
- Isolate the root cause
- Suggest multiple fix approaches

Analyze: "$ARGUMENTS"

Provide detailed analysis including:
1. Error reproduction steps
2. Root cause identification
3. Code flow analysis leading to the error
4. Multiple solution approaches with trade-offs
5. Recommended fix with implementation details

### 2. Performance Debugging (if performance-related)
If the issue involves performance problems, also:
- Profile code execution
- Identify bottlenecks
- Analyze resource usage
- Suggest optimization strategies

## Debug Output Structure

### Root Cause Analysis
- Precise identification of the bug source
- Explanation of why the issue occurs
- Impact analysis on other components

### Reproduction Guide
- Step-by-step reproduction instructions
- Required environment setup
- Test data or conditions needed

### Solution Options
1. **Quick Fix** - Minimal change to resolve issue
   - Implementation details
   - Risk assessment

2. **Proper Fix** - Best long-term solution
   - Refactoring requirements
   - Testing needs

3. **Preventive Measures** - Avoid similar issues
   - Code patterns to adopt
   - Tests to add

### Implementation Guide
- Specific code changes needed
- Order of operations for the fix
- Validation steps

Issue to debug: $ARGUMENTS
