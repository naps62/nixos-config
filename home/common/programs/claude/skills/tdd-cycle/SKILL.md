---
description: Execute a full TDD red-green-refactor cycle
---

Execute a comprehensive Test-Driven Development (TDD) workflow with strict red-green-refactor discipline:

## Configuration

### Coverage Thresholds
- Minimum line coverage: 80%
- Minimum branch coverage: 75%
- Critical path coverage: 100%

### Refactoring Triggers
- Cyclomatic complexity > 10
- Method length > 20 lines
- Class length > 200 lines
- Duplicate code blocks > 3 lines

## Phase 1: Test Specification and Design

### 1. Requirements Analysis
Analyze requirements for: $ARGUMENTS. Define acceptance criteria, identify edge cases, and create test scenarios.

### 2. Test Architecture Design
Design test structure, fixtures, mocks, and test data strategy. Ensure testability and maintainability.

## Phase 2: RED - Write Failing Tests

### 3. Write Unit Tests (Failing)
Write FAILING unit tests. Tests must fail initially. Include edge cases, error scenarios, and happy paths. DO NOT implement production code yet.

### 4. Verify Test Failure
Verify all tests are failing correctly. Ensure failures are for the right reasons (missing implementation, not test errors).

**GATE**: Do not proceed until all tests fail appropriately.

## Phase 3: GREEN - Make Tests Pass

### 5. Minimal Implementation
Implement MINIMAL code to make tests pass. Focus only on making tests green. Do not add extra features or optimizations.

### 6. Verify Test Success
Run all tests and verify they pass. Check coverage metrics. Ensure no tests were accidentally broken.

**GATE**: All tests must pass before proceeding.

## Phase 4: REFACTOR - Improve Code Quality

### 7. Code Refactoring
Refactor implementation while keeping tests green. Apply SOLID principles, remove duplication, improve naming. Run tests after each refactoring.

### 8. Test Refactoring
Refactor tests: remove duplication, improve names, extract common fixtures. Ensure coverage unchanged or improved.

## Phase 5: Integration Tests

### 9. Write Integration Tests (Failing First)
Write FAILING integration tests. Test component interactions, API contracts, and data flow.

### 10. Implement Integration
Make integration tests pass. Focus on component interaction and data flow.

## Validation Checkpoints

### RED Phase
- [ ] All tests written before implementation
- [ ] All tests fail with meaningful error messages
- [ ] No test passes accidentally

### GREEN Phase
- [ ] All tests pass
- [ ] No extra code beyond test requirements
- [ ] Coverage meets minimum thresholds

### REFACTOR Phase
- [ ] All tests still pass after refactoring
- [ ] Code complexity reduced
- [ ] Duplication eliminated

## Anti-Patterns to Avoid

- Writing implementation before tests
- Writing tests that already pass
- Skipping the refactor phase
- Modifying tests to make them pass
- Writing tests after implementation

TDD implementation for: $ARGUMENTS
