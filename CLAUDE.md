# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

コトバ Kotoba is a single-page, offline-first PWA for Taiwanese learners studying Japanese (JLPT N5→N4). No build step, no framework, no dependencies, no package.json, no tests. It is plain static files served directly (GitHub Pages). UI language and code comments are Traditional Chinese.

## Commands

There is nothing to build or compile. To work on it:

- **Run locally:** serve the folder over HTTP (the service worker and `fetch()` calls need a real origin). E.g. `python -m http.server 8000` then open `http://localhost:8000`. Opening `index.html` via `file://` breaks the SW and PWA behavior.
- **Deploy:** `GitHub-一鍵更新.bat` — bumps the SW cache version, `git add -A`, `git commit -m "update"`, `git push`. GitHub Pages rebuilds in ~1 min. First-time publish is `GitHub-第一次設定.bat` (creates the repo via `gh`, enables Pages).
- **Bump cache version manually:** `powershell -NoProfile -ExecutionPolicy Bypass -File bump-version.ps1` — increments `CACHE` in `sw.js` and keeps `APPVER` in `index.html` in sync. **Any change to a cached asset requires this bump**, or installed clients keep serving the stale cached copy.

`.deploy/` and `.netlify/` are stale tooling folders, gitignored. `backups/` and `*backup*.json` are gitignored because this is a public repo — never commit user data.

## Architecture

### File layout

- `index.html` — the entire app: all HTML, all CSS, and ~1650 lines of vanilla JS in one `<script>` block (starts line 450, banks loaded lines 444-449). Five `<section>`s (`s-prac`, `s-course`, `s-bank`, `s-ai`, `s-me`) toggled by the bottom `<nav>` via `data-s`.
- `bank-*.js` — question banks, loaded as plain `<script>` before the main script. Each assigns a backtick template string to a `window.*_RAW` global (except `bank-course.js` / `bank-verb.js` which assign structured objects/functions).
- `sw.js` — service worker: network-first, falls back to cache, falls back to `index.html`. `ASSETS` list must include every file that should work offline.
- `manifest.webmanifest`, `icon-192.png`, `icon-512.png` — PWA install metadata.

### Data banks (pipe-delimited lines, parsed by `lines()` + `.split('|')` in index.html, `lines()` at line 459)

| Global | File | Format |
|---|---|---|
| `VOCAB_RAW` | bank-vocab.js | `漢字\|讀音\|中文\|詞性\|級別` |
| `VERB_RAW` | bank-verb.js | `辭書形\|讀音\|中文\|類別(1五段/2一段/3不規則)\|級別` |
| `PAIR_RAW` | bank-verb.js | `自動詞\|讀音\|他動詞\|讀音\|中文` |
| `GRAMMAR_RAW` | bank-grammar.js | `句型\|中文\|接續\|例句\|例句假名\|例句中譯\|級別` |
| `SENT_RAW` | bank-sentence.js | `日文(詞塊用 / 分隔)\|全假名\|中文\|情境\|級別\|step` |
| `KANA_RAW` | bank-kana.js | `平假名\|片假名\|羅馬字\|分組` |

`bank-verb.js` also defines `window.conjV(verb, form)` (the conjugation engine) and `window.VERB_FORMS`. `bank-course.js` (`window.COURSE`/`window.COURSE2`) and `bank-kana.js` (`window.KANA`) are still loaded so their globals exist, but the 14-day course, N4 weeks, and 50-音 speed test were **removed from the UI** (see below) — `COURSE` is now only read by the `curUnit()` stub for the optional AI 句子批改 grammar hint.

When editing banks: keep the exact column count and delimiter, keep the `gram` strings in `bank-course.js` byte-identical to the first column of `bank-grammar.js`, and one entry per line inside the template literal. Lines starting with `#` inside the literal are treated as comments (`lines()` skips them) — use them to section the bank; readings must be pure kana.

Bank sizes: vocab ~694 (300 N5 / 394 N4), grammar 108, sentences ~335, verbs 127. The vocab bank is still well short of a full N4 list (~1500 cumulative) — it's a curated core set, meant to be supplemented (AI 生題 / user 加單字 / external deck).

### State & persistence

- Single mutable global `S`, shape defined by `fresh()` (line 481; `let S=fresh()` at 492). `save()` (line 510) writes `S` (as JSON) to `localStorage` under `kotoba_data_v1` **and** debounced to IndexedDB (`kotoba`/`kv`) as a backup; `load()` prefers localStorage, restores from IndexedDB if localStorage is empty.
- Adding a new field to `S`: add it to `fresh()`. `load()` does `Object.assign(fresh(), parsed)` plus per-sub-object merges, so top-level primitives get defaults for free but nested objects need their own `Object.assign(fresh().x, S.x)` line in `load()`.

### Spaced repetition

`srs` map keyed by `mode:id`. Intervals are `STEPS = [1,3,8,20,45,100]` days (line 544). `srsHit(mode,id,good,noWrong)` (line 547) advances/resets the step (`noWrong` skips the 錯題本 write — used by `read` self-grading and by `type` near-misses); `pick(mode,n)` prioritizes due items, then new, then the rest.

### Practice modes (simplified)

`MODES` is four: **`read`** (讀句子 — flashcard: 中文 → `revealRead()` reveals 日文+假名+grammar+語順+audio → `gradeRead(ok)` self-grades, `noWrong`), **`vocab`** (multiple-choice), **`type`** (默寫 — sentence cloze: `mkQ` blanks one short chunk, user types it; `checkType()` grades: exact = 對, kana-only when answer has kanji = 「接近」 counts for SRS but skips 錯題本, else 錯), **`build`** (重組句子). `startAuto()` orders the session read → vocab → type → build via `orderQueue()`. `poolFor(mode)` filters `poolRaw(mode)` by `S.lv` (5 = N5 only, 0 = N5+N4).

**Grammar detection & explanations:** `GRAM_MATCH` / `gramsIn(str)` string-match `bank-grammar.js` patterns (dictionary-form core + a trimmed stem) against a sentence's `j`+`k`. Used for: the 🏷 chip on question cards (`sentChip`), the 💡 提示 buttons (`typeHint`/`buildHint`, `gramSummary`), and `explainHTML(c)` — the built-in "怎麼解這題" block shown on every wrong answer (and collapsed under 看解說 when right): full answer + kana + 中文, then for sentence modes `sentExplainHTML(it)` = `wordOrderHTML(it)` + `gramDetailHTML(it)`, for vocab an example sentence. The AI 拆解 button is still there as an extra when a key is set.

`wordOrderHTML(it)` is a **rule-based** 語順 analyzer (offline, no AI): walks `it.ch` chunks, attaches standalone particle chunks to the preceding content chunk via `PART_ROLE` (は/が/を/に/で/へ/と/も/から/まで/より → role + 中文 note), special-cases `です／ます`+が = 逆接「但是」 and て-form+も = 「～てもいい」, tags the last particle-less chunk as 述語 via `predKind()`, then renders a coloured chunk skeleton + bullet notes + the SOV reminder. Used by `explainHTML` (build/type post-answer) and by `revealRead()` (read mode's 「為什麼這句話長這樣」 `<details>` in the reveal panel). `gramDetailHTML(it)` is the old "這題用到的句型" cards, extracted so both call sites share it. `buildHint()`/`typeHint()` still use the lighter `gramSummary(it)` (+ a generic ordering-principle line in `buildHint`) so hints don't hand over the answer order.

**Exam countdown:** `S.exam` (default `'2026-12-06'`, editable in 我的). `renderExam()` fills `#examCard` on the home screen with days-left + vocab/sentence coverage vs. `S.srs` + a per-day pace estimate.

The `kanji`/`verb`/`part`/`listen`/`shadow` mode branches in `mkQ`/`paint`/`poolRaw`, plus the whole course and kana-test rendering (`renderCourse`, `openDay`, `startDay`, `kanaStart`, …), are **dead code left in place** — not reachable from the UI but still parsed. Old `S.wrong` entries with those modes still render (guards use `MODES.find(...)||{n:w.mode}`).

### Sync (optional, user-configured)

`S.supa` holds a user's own Supabase URL + anon key + a share code. `syncNow()` pushes/pulls the full state blob to a `kotoba_sync` table; `mergeState(a,b)` does field-by-field conflict resolution (max counts, newest-wins on `srs` by `last` timestamp, union of logs). API keys (`S.keys`, `S.models`, `S.supa`) are explicitly excluded from sync.

### AI tutor (optional, user-configured)

`askAI(prompt, sys, maxTok)` in `index.html` at line 611. Supports two providers chosen by `S.prov`: `gemini` (Google Generative Language REST) and `claude` (Anthropic Messages API, called directly from the browser with `anthropic-dangerous-direct-browser-access`). Model lists `GEM_MODELS` / `CLA_MODELS` are tried in order until one succeeds; the working model is cached back into `S.models`. Keys are stored only in the user's local `S.keys` and entered by the user in the "我的" screen.

## Conventions

- Match the existing style: terse vanilla JS, single-letter/short names, no semicolons-optional cleanup, Traditional Chinese comments explaining *why* a rule exists (e.g. which N-level a grammar point trips people up at).
- No new dependencies or tooling. Keep it a zero-build static site.
- After changing any file listed in `sw.js`'s `ASSETS`, run `bump-version.ps1` (or deploy via the update `.bat`, which does it).
