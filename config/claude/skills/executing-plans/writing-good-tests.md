# Writing Good Tests — traps

Read when adding a mock or a test helper, or when unsure a test can fail.
What gets a test and when: CLAUDE.md "Code".

## The test must be able to fail

- **Name the break.** Before the body: which production change makes this
  test fail? None → redesign around an observable behaviour. Only an
  intentional decision (a constant, exact wording, private structure) → a
  change detector; test the behaviour that depends on it instead: not
  `expect(MAX_RETRIES).toBe(5)` but "the 6th attempt never happens".
- **Derive expectations independently** — literals, hand-checked fixtures,
  table-driven tests with literal `want`. An expected value built by the code
  under test or its helpers passes no matter what:

  ```typescript
  expect(buildSearchQuery({ tag: 'urgent' })).toBe(buildSearchQuery({ tag: 'urgent' })); // ❌
  expect(buildSearchQuery({ tag: 'urgent' })).toBe('tag:"urgent"');                       // ✅
  ```

- **Behaviour, not text.** A test that greps a script, skill or config for a
  line proves only that the source is the source: run it and assert effects.
- **Your boundary, not the framework's**: the route you register, the query
  you emit — not that the router calls a handler.
- **Time:** a fake clock, never the wall clock and sleeps.

## Mocks

- **The mock earns no assertions.** Asserting a mock exists or was called
  tests the mock. Assert the real component, or unmock.
- **Mock at the right level.** Learn the real method's side effects first;
  mock the slow or external operation below the ones the test depends on.
- **Mirror real data completely** — every documented field, not only the ones
  the test reads; a partial mock passes while integration breaks.
- **Make doubles specific** when arguments, counts or order are the contract;
  one fixture per branch (success, error, malformed).
- **Production classes carry production methods only**; test-only cleanup
  lives in test utilities.
- Mock setup bigger than the test → an integration test with real parts.

## Mutation check

Mentally break the code — wrong constant, wrong branch, missing side effect,
empty return, missing validation for zero/empty/nil/malformed. Something
should fail for each. Running a mutation for real in Python: set
`PYTHONDONTWRITEBYTECODE=1` and clear `__pycache__` between runs — CPython
reuses bytecode when size and whole-second mtime match, so a one-character
mutation can run the old code and report the opposite of the truth.
