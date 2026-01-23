# Repository Guidelines

## Coding Style & Best Practices
- I prefer no dots at the end of sentences
- If ScrechKit is added as a library, prefer ScrechKit's view modifiers such as .hapticOn(), .title(), .secondary() or .title(.secondary); ScrechKit imports SwiftUI as well, which has all Foundation code asin it
- Shapes: Use shape style shorthand in view modifiers; Prefer .background(.thinMaterial, in: .capsule) over .background(.thinMaterial, in: Capsule())
- .onChange now provides two closure parameters: oldValue and newValue; Use `_` for any parameter you do not need; If neither parameter is needed, omit them entirely
- Bindings: do not use Bindings with a getter & setter for readability
- Prefer adaptive .font() fonts (or ScrechKit's if the lib is present) over .fontSize()
- Subviews: Split subviews in long views into separate views in separate files
- When defining enums, prefer concise single-line cases without associated values, written as a simple comma-separated list, for example: case cloud, game, bot
- Naming: `UpperCamelCase` for types, `lowerCamelCase` for values/functions; SwiftUI views typically end in `View` (for example `DashboardView.swift`)

## Swift Concurrency
- GCD: prefer Swift Concurrency APIs over Grand Central Dispatch
- Swift 6 language mode
- MainActor default isolation mode enabled
- All API calls must be async/await
- All functions/props in View structs are @MainActor by default

## Build & Test
- Do not build or create unit tests unless I ask to do so

## Git
- When asked to push, commit all existing changes first
- When asked to checkout, do that in the main project without creating copies of it
- Commit messages are short and action-oriented (for example `improved …`, `fixed …`, `removed …`). Use a concise subject; add a scope when helpful (for example `macOS: fix settings crash`)
- PRs should describe the user-visible impact, list affected platforms/schemes

## Security
- Don’t commit secrets or environment-specific files

## Skills
A skill is a set of local instructions to follow that is stored in a `SKILL.md` file. Below is the list of skills that can be used. Each entry includes a name, description, and file path so you can open the source for full instructions when using a specific skill.
### Available skills
- skill-creator: Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Codex's capabilities with specialized knowledge, workflows, or tool integrations. (file: /Users/topscrech/.codex/skills/.system/skill-creator/SKILL.md)
- skill-installer: Install Codex skills into $CODEX_HOME/skills from a curated list or a GitHub repo path. Use when a user asks to list installable skills, install a curated skill, or install a skill from another repo (including private repos). (file: /Users/topscrech/.codex/skills/.system/skill-installer/SKILL.md)
### How to use skills
- Discovery: The list above is the skills available in this session (name + description + file path). Skill bodies live on disk at the listed paths.
- Trigger rules: If the user names a skill (with `$SkillName` or plain text) OR the task clearly matches a skill's description shown above, you must use that skill for that turn. Multiple mentions mean use them all. Do not carry skills across turns unless re-mentioned.
- Missing/blocked: If a named skill isn't in the list or the path can't be read, say so briefly and continue with the best fallback.
- How to use a skill (progressive disclosure):
  1) After deciding to use a skill, open its `SKILL.md`. Read only enough to follow the workflow.
  2) If `SKILL.md` points to extra folders such as `references/`, load only the specific files needed for the request; don't bulk-load everything.
  3) If `scripts/` exist, prefer running or patching them instead of retyping large code blocks.
  4) If `assets/` or templates exist, reuse them instead of recreating from scratch.
- Coordination and sequencing:
  - If multiple skills apply, choose the minimal set that covers the request and state the order you'll use them.
  - Announce which skill(s) you're using and why (one short line). If you skip an obvious skill, say why.
- Context hygiene:
  - Keep context small: summarize long sections instead of pasting them; only load extra files when needed.
  - Avoid deep reference-chasing: prefer opening only files directly linked from `SKILL.md` unless you're blocked.
  - When variants exist (frameworks, providers, domains), pick only the relevant reference file(s) and note that choice.
- Safety and fallback: If a skill can't be applied cleanly (missing files, unclear instructions), state the issue, pick the next-best approach, and continue.
