# Task: Quality Gate Validation

**Purpose**: Ensure code meets all quality standards before merging

**Agent**: elixir-qa

**Duration**: 30 minutes - 1 hour

## Overview

Quality gates enforce standards and catch issues before code reaches production. This task validates test coverage, code quality, type safety, and formatting.

## Quality Gates

### Gate 1: Test Suite

**Command**: `mix test`

**Requirements:**
- ✅ All tests must pass (100% pass rate)
- ✅ No pending/skipped tests without justification
- ✅ Test coverage ≥ 80% for new code
- ✅ No test warnings or deprecations

**Common Failures:**
- N+1 query warnings in tests
- Flaky tests (race conditions)
- Missing test data factories
- Tests that modify global state

**Fix Strategies:**
```elixir
# N+1 Query Fix
# Bad: N+1 query in association access
users = Repo.all(User)
Enum.map(users, fn user -> user.posts end)  # Queries for each user!

# Good: Preload associations
users = Repo.all(User) |> Repo.preload(:posts)
Enum.map(users, fn user -> user.posts end)  # Already loaded

# Flaky Test Fix
# Bad: Race condition with async operations
test "processes message" do
  start_processor()
  send_message(msg)
  assert message_processed?()  # May fail due to timing
end

# Good: Use proper synchronization
test "processes message" do
  start_processor()
  send_message(msg)
  assert_receive {:message_processed, ^msg}, 1000
end
```

### Gate 2: Static Analysis (Credo)

**Command**: `mix credo --strict`

**Requirements:**
- ✅ No Credo issues (warnings or errors)
- ✅ Code follows Elixir style guide
- ✅ No code smells detected
- ✅ Cyclomatic complexity within limits

**Common Issues:**
```elixir
# Credo: Avoid if/else in pipeline
# Bad
result =
  data
  |> process()
  |> if do
    transform()
  else
    default()
  end

# Good
result =
  data
  |> process()
  |> then(fn processed ->
    if condition?(processed), do: transform(processed), else: default(processed)
  end)

# Credo: Prefer case over cond with single condition
# Bad
cond do
  x > 10 -> :large
  true -> :small
end

# Good
if x > 10, do: :large, else: :small
```

### Gate 3: Type Safety (Dialyzer)

**Command**: `mix dialyzer`

**Requirements:**
- ✅ No Dialyzer warnings
- ✅ Type specs on all public functions
- ✅ No dead code detected
- ✅ No unreachable code paths

**Common Warnings:**
```elixir
# Dialyzer: Return type mismatch
# Bad
@spec get_user(integer()) :: User.t()
def get_user(id) do
  Repo.get(User, id)  # Returns User.t() | nil, not User.t()!
end

# Good
@spec get_user(integer()) :: User.t() | nil
def get_user(id) do
  Repo.get(User, id)
end

# Or use bang version
@spec get_user!(integer()) :: User.t()
def get_user!(id) do
  Repo.get!(User, id)  # Raises if not found
end

# Dialyzer: Pattern match on wrong type
# Bad
@spec process({:ok, String.t()}) :: String.t()
def process({:ok, value}) when is_binary(value) do
  # Guard is redundant - spec already says it's String.t()
  String.upcase(value)
end

# Good
@spec process({:ok, String.t()}) :: String.t()
def process({:ok, value}) do
  String.upcase(value)
end
```

### Gate 4: Code Formatting

**Command**: `mix format --check-formatted`

**Requirements:**
- ✅ All code properly formatted
- ✅ No formatting differences detected

**Fix**: Run `mix format` and commit changes

### Gate 5: Compilation Warnings

**Command**: `mix compile --warnings-as-errors`

**Requirements:**
- ✅ No compiler warnings
- ✅ No unused variables/functions
- ✅ No ambiguous aliases

**Common Warnings:**
```elixir
# Warning: Unused variable
# Bad
def process(data, _unused) do
  transform(data)
end

# Good: Prefix with underscore if intentionally unused
def process(data, _opts) do
  transform(data)
end

# Warning: Undefined function
# Bad - typo in function name
def handle_event("save", params, socket) do
  save_data(parms)  # Typo: parms instead of params
end

# Good
def handle_event("save", params, socket) do
  save_data(params)
end
```

## Automated Quality Check

Create `mix precommit` alias in `mix.exs`:

```elixir
defp aliases do
  [
    # ... other aliases
    precommit: [
      "format",
      "test",
      "credo --strict",
      "dialyzer"
    ]
  ]
end
```

Run before committing:
```bash
mix precommit
```

## Manual Code Review Checklist

### Architecture & Design
- [ ] Follows existing patterns in codebase
- [ ] No God modules (> 500 lines)
- [ ] Proper separation of concerns
- [ ] Context boundaries respected
- [ ] No circular dependencies

### Phoenix Patterns
- [ ] Business logic in contexts, not controllers
- [ ] Controllers are thin (< 100 lines)
- [ ] Repo calls only in contexts
- [ ] Proper use of LiveView lifecycle
- [ ] Streams used for collections (not assigns)

### Ecto Patterns
- [ ] Associations preloaded when needed
- [ ] Indices on foreign keys and queried fields
- [ ] Constraints in both schema and migration
- [ ] No N+1 queries
- [ ] Proper transaction usage for multi-step operations

### LiveView Patterns
- [ ] `to_form/1` used for all forms
- [ ] `<.input>` component from core_components
- [ ] Streams have `phx-update="stream"` and proper IDs
- [ ] PubSub subscription only when `connected?(socket)`
- [ ] Empty states handled for streams
- [ ] No `else if` in HEEx (use `cond` instead)

### Error Handling
- [ ] Returns `{:ok, result}` or `{:error, reason}` tuples
- [ ] Errors handled gracefully
- [ ] User-friendly error messages
- [ ] No unhandled exceptions in normal flow
- [ ] Proper logging for debugging

### Security
- [ ] Authorization checks on all actions
- [ ] Input validation in changesets
- [ ] No SQL injection vulnerabilities
- [ ] CSRF protection enabled
- [ ] No secrets in code

### Performance
- [ ] No N+1 queries
- [ ] Proper indices on database
- [ ] Pagination for large datasets
- [ ] Streams used for large collections
- [ ] No expensive computations in templates

### Testing
- [ ] Unit tests for context functions
- [ ] LiveView tests for UI interactions
- [ ] Edge cases covered
- [ ] Error paths tested
- [ ] Tests use proper factories/fixtures

## Quality Gate Report

After running all gates, create a summary:

```markdown
# Quality Gate Report - STORY-123

**Date**: 2024-01-15
**Branch**: feature/add-search
**Developer**: elixir-dev

## Results

| Gate | Status | Details |
|------|--------|---------|
| Tests | ✅ PASS | 42 tests, 0 failures, 94% coverage |
| Credo | ✅ PASS | No issues found |
| Dialyzer | ✅ PASS | No warnings |
| Format | ✅ PASS | All files formatted |
| Compile | ✅ PASS | No warnings |

## Manual Review

- [x] Architecture follows existing patterns
- [x] No N+1 queries introduced
- [x] Proper error handling
- [x] Security checks in place
- [x] Performance acceptable

## Recommendations

None - ready to merge!

## Commands Run

```bash
mix precommit
# All checks passed ✅
```
```

## Blocking Issues

If any gate fails, **DO NOT MERGE**. Common blockers:

### ❌ Test Failures
```bash
# Output
1) test creates user with valid data (MyApp.AccountsTest)
   Expected: {:ok, %User{}}
   Got: {:error, #Ecto.Changeset<...>}
```

**Action**: Fix the test or implementation, ensure all tests pass

### ❌ Credo Issues
```bash
# Output
┃ [R] ↗ Avoid negated conditions in unless blocks.
┃     lib/my_app/accounts.ex:45
```

**Action**: Refactor code to address issues

### ❌ Dialyzer Warnings
```bash
# Output
lib/my_app/accounts.ex:23:callback_missing
Function get_user/1 has no @spec typespec.
```

**Action**: Add proper type specs

### ❌ Formatting Issues
```bash
# Output
** (Mix) mix format failed due to --check-formatted.
The following files are not formatted:
  * lib/my_app/accounts.ex
```

**Action**: Run `mix format` and commit

## Emergency Bypass

In rare cases, quality gates may need to be bypassed (production hotfix). Document reason:

```markdown
# QUALITY GATE BYPASS

**Story**: STORY-456
**Date**: 2024-01-15
**Reason**: Critical production issue - payment processing down
**Bypass**: Dialyzer (known false positive for new OTP behavior)
**Plan**: Will fix Dialyzer warning in follow-up STORY-457
**Approved By**: Tech Lead
```

## Integration with Git Hooks

Quality gates can run automatically via pre-commit hooks:

```bash
#!/bin/sh
# .git/hooks/pre-commit

echo "Running quality gates..."

# Run mix precommit
mix precommit
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo "❌ Quality gates failed! Fix issues before committing."
  exit 1
fi

echo "✅ Quality gates passed!"
exit 0
```

## Quality Metrics Dashboard

Track quality over time:

```elixir
# Quality metrics to track
- Test coverage trend (should increase)
- Credo issues count (should be 0)
- Dialyzer warnings (should be 0)
- Average cyclomatic complexity (should be < 10)
- Lines of code per module (should be < 500)
- Number of N+1 queries (should be 0)
```

## Next Steps

After passing all quality gates:
1. Create pull request
2. Request code review
3. Address review feedback
4. Merge to main branch
5. Monitor in production

## Resources

- [Credo Documentation](https://hexdocs.pm/credo)
- [Dialyzer User Guide](https://www.erlang.org/doc/man/dialyzer.html)
- [ExUnit Documentation](https://hexdocs.pm/ex_unit)
- [Phoenix Testing Guide](https://hexdocs.pm/phoenix/testing.html)
