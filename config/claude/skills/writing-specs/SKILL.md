---
name: writing-specs
description: Use when a project has no living spec and needs one — a new project starting from an idea, or existing code whose purpose and behaviour live only in someone's head. Triggers on "napisz spec", "stwórz spec.md", "zbierz wymagania", "write a spec for this project", "co ten projekt właściwie robi", on reaching a project with no spec at the start of pipeline work, on a spec past 40 KB that needs splitting, and on a spec still holding a decision table (`| D1 |` rows) that must be migrated before a change adds or changes a decision. Otherwise this skill does not amend an existing spec — each change does, with its code (executing-plans in a run).
---

# Writing Specs

A living spec states what a project **is right now** — precisely enough that
a fresh session told "zaimplementuj spec.md" builds a project that behaves the
same, and its Weryfikacja section proves it. Why things are the way they are
lives next to it, in `decisions.md`. Written once per project, then kept true
by every change.

This is a bootstrap job — one document, one sitting, its own user gate. It
opens no run state; a change to *code* comes afterwards, through
development-workflow as usual.

## Two files

- **`spec.md`** — current state only. Read in full before every change.
- **`decisions.md`** — in the same directory as `spec.md` (a per-component
  spec gets its own, with its own numbering). An append-only log of why. Never
  read whole by default: grep it for a number when a change touches a section
  that cites `(Dn)`, or wants to change that decision.

Test for every line of the spec: *does an implementer need this to build the
same thing?* No → it goes to `decisions.md` (rationale, rejected options),
to git (history, "we changed X"), or nowhere.

## Two readers, and only one of them can ask

A person reads the spec weeks later, having forgotten; an agent reads it to
build from, in a fresh session, and **fills a gap instead of asking**. Where
they diverge, the agent's constraints decide.

- **Exact values, verbatim.** Numbers with units, identifiers spelled as in
  code, user-facing strings in quotes. "A friendly error message" is not a
  requirement; `"Nie udało się zapisać — spróbuj ponownie"` is.
- **One interpretation per sentence.** If a sentence admits two readings, pick
  one — or move it to the open points with what would settle it.
- **Behaviour by example.** A rule plus an input → result example beats a
  paragraph; point it at the test or command that checks it.
- **Stable numbers.** Sections (§5.2) and decisions (D14) are cited by plans
  and commits; never renumber.
- **Cite code by path and symbol, never by line.** `src/harmonia/store.py`
  (`pool_upsert`), not `store.py:104-106`.

## The skeleton

Polish unless the project's own artifacts are English. Numbered `## N.`
headings. The middle (sections 3–5) is project-shaped: read a sibling spec
(`~/work/*/spec.md`, `~/projects/*/spec.md`) for how this house names them.

```markdown
# <Projekt>

## 1. Cel i zakres
Problem, użytkownik, co projekt robi — 2–5 zdań.

## 2. Poza zakresem
Czego implementator NIE buduje.

## 3. Zachowanie
Per funkcja: reguły + przykłady wejście → wynik, każdy wskazuje test
(`tests/x.py::nazwa`) albo komendę. Decyzja, która coś tu ogranicza: „(D7)”.

## 4. Kontrakty zewnętrzne
CLI, formaty plików, API, schematy, zmienne środowiskowe, porty — dokładnie;
link do pliku schematu zamiast przepisywania go.

## 5. Architektura
Tylko to, czego nie widać z drzewa katalogów w minutę: komponenty, przepływ
danych, gdzie co działa.

## 6. Inwarianty i ograniczenia
Co zawsze/nigdy musi być prawdą: bezpieczeństwo, dane, limity.

## 7. Punkty otwarte
### Pytania — ktoś musi zdecydować; z domyślną odpowiedzią.
### Flagi — znane ryzyko, nikt nie musi decydować dziś.

## 8. Weryfikacja
Dokładne komendy, które pokazują, że projekt działa jak opisano.
```

A section the project lacks is omitted, not left empty. An open point that
gets settled is deleted from §7 — the settlement, if it is a decision, becomes
a D entry.

## decisions.md

```markdown
# Decyzje — <Projekt>

## D7 — SQLite zamiast Postgresa (2026-11-21) · przyjęta
Kontekst: jeden użytkownik, sync pc↔laptop, bez serwera.
Decyzja: stan w jednym pliku SQLite.
Odrzucone: Postgres (koszt utrzymania), pliki JSON (brak transakcji).
Konsekwencje: zero ops; brak współbieżnych zapisów.
```

- 3–10 lines per entry; numbers continue the project's existing D sequence.
- Status: `przyjęta`, `zastąpiona przez Dn`, `zmieniona przez Dn (<zakres>)`,
  `uchylona przez Dn`. Changing a decision = a new entry + editing the old
  entry's status line; the old entry's text is never rewritten.
- Only decisions a later reader might reopen: a choice between real options.
  What the code plainly shows needs no entry.

## Draft first, then grill

Do not open with a questionnaire — half the answers are in the code.

1. **Build a strawman.** Existing code: the directory layout, then grep and
   Read for the parts that matter, plus README, config, dependency manifest
   and commit history. Greenfield: the user's description and how their other
   projects are built.
2. **Show it and say what you guessed.** Mark every inference.
3. **Grill only the gaps**, per `~/.claude/skills/writing-plans/grill-gate.md`
   (a reference file — read it directly). Push every answer to an exact
   value; "kilka sekund" is not an answer. Not known yet → an open point with
   a stated default, never your rounding.
4. **Assumptions stay assumptions:** a numbered list in §7, and reconstructed
   rationale in `decisions.md` marked `(wnioskowane)`.

**User unavailable** ("just do it", an agent alone): you do not answer for
them. Each question goes to §7 with your default; say the spec is provisional.

## Scale to the project

| Project | spec.md |
|---|---|
| A single-purpose tool, one service, a hobby repo | 60–150 lines |
| A real application with a data model and integrations | 150–350 lines |
| A system with external contracts, auth, several components | 350+, consider one spec per component |

Open points may overshoot on a legacy project — say why rather than silently
answering questions the user has not answered. A spec longer than the code
deserves is a document nobody maintains, and an unmaintained spec lies with
authority.

## Splitting a spec past 40 KB

Any spec file over 40 KB by `wc -c`: the agent reads it in full on every
task (harmonia's 302 KB spec made spec-sync tasks 3–5× the cost of a code task).

- `spec.md` becomes the index: §1, §2, and one line per `docs/<temat>.md`
  with what it holds and its section numbers.
- Group topics by what one change reads together. A topic file over 40 KB
  splits again; a single section over 40 KB splits at its `###` headings.
- Numbering stays global: a moved §7 stays §7. `decisions.md` is not split.
- Its own commit; content is moved, not rewritten, except `file:line`
  citations converted to path + symbol.

A split spec is read as the index plus the topic files the change touches.

## Migrating a spec with a decision table

A spec still holding `| D1 |` rows (or D rows spread over topic files) is on
the old model. Before any change adds or changes a decision, migrate it — one
commit, nothing else in it:

1. For each D row: the **current value** it fixes goes into the state section
   it governs, with `(Dn)` cited there; the **rationale, rejected options,
   author** go to `decisions.md` as entry Dn — the row's own wording, fields
   it lacked omitted, its date or none, the author in Kontekst. Nothing
   invented.
2. Rows that say "zmienione przez", "uchylone przez", "pierwotnie…": the old
   entry gets the matching status, the newer entry carries the current value.
3. Delete the decision table, the "next free D" line, index lines listing D
   numbers, changelog preambles, and struck/dated open points.
4. An existing `decisions.md` in another format: its entries stay as they
   are; new entries follow the format above, continuing the numbering.
5. Replace the project `CLAUDE.md` block with the one from
   `project-claude-md.md`.
6. Check: every value from the old rows is findable in the new spec
   (`grep` a sample of 10), and `wc -c` before/after.

A migration is mechanical: no user gate — report the check. Inside inline
work, commit it before noting the change's review BASE.

## What does not belong in the spec

- Rationale, rejected options, history, changelog → `decisions.md` or git.
- Defect lists, TODOs, known bugs → issues.
- Task breakdowns, phases, "definition of done" → writing-plans.
- Code beyond the odd contract snippet.

## Finishing

Put `spec.md` where the code it describes lives: project root for a single
codebase, next to the component in a monorepo; `decisions.md` beside it.
Commit both on their own, with the project `CLAUDE.md` block from
`project-claude-md.md` (next to this file) — without it, a colleague's Claude
Code never learns the spec exists. Cannot write into the repository: say so,
write it where you can, and state where it belongs.

Hand it to the user: which parts are their answers, which are your inferences,
which questions stayed open. From here the pipeline keeps it true: a change's
decisions and state sections land together with its code.

## Red flags

- Asking questions before reading the code.
- Rationale, "pierwotnie", "zmienione przez" or dates in the spec body.
- "TBD" or an empty section in the delivered document.
- "Około", "roughly", "jakiś", "odpowiedni", "w miarę" surviving — each one is
  a decision left for a subagent to make silently.
- Writing it as a plan: phases, tasks, checkboxes, estimates.
- Quietly resolving something the user has not decided.
