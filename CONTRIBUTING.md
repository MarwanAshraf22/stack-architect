# Contributing to Stack Architect

Thanks for helping keep these recommendations sharp. Tech moves fast, and this skill is only as good as its references.

## Ways to contribute

1. **Propose a stack change.** A library got deprecated, a better default emerged, pricing changed. Open an issue with the "Stack update" template.
2. **Add an example.** Run the skill on a real project idea and add the resulting record to `examples/` (numbered, kebab-case filename). Include the prompt at the top.
3. **Improve a reference file.** Fix outdated facts, add missing options, sharpen guidance.
4. **Add a project archetype** to `references/01-project-types.md` if a common kind of project is missing.

## Rules for changes

- **Give a reason and a source** for every recommendation change (release notes, docs, benchmarks, maintenance status). Opinions are welcome; evidence wins.
- **Keep the voice decisive.** One default per layer plus the main alternative, not a long menu.
- **Update the "Last reviewed" date** at the top of any reference file you change.
- **Keep `SKILL.md` lean** (under 500 lines). Details belong in `references/`.
- **Don't change `00-house-defaults.md` in pull requests** unless the change is clearly better for everyone; it's meant to be customized in forks.
- Prefer proven tools; flag brand-new projects as "verify before use".

## Testing your change

Load the skill in Claude (Claude Code: put the folder in `~/.claude/skills/`, or install the plugin) and run a few prompts that touch your change, e.g. "What stack should I use for X?" Check that the output reflects the update and still follows the Stack Decision Record template.

## Pull requests

- One topic per PR.
- Describe what changed and why, with links.
- Small PRs get merged fastest.
