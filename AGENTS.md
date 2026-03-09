## Repository Rules

- When replacing a workflow, remove the old workflow entirely.
- Do not keep fallbacks, compatibility paths, or toggle/env-based alternate behavior.
- Keep installation logic static and deterministic.
- Do not leave dead variables or optional branches after migrations.
