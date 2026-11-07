# Command guidance

## Workflow questions

Give advice without executing commands; the menu below is only for bare invocations. Consult the relevant command references for prerequisites and scope. If the user also requests execution, follow that request.

## No-argument routing: the context-aware menu

Read this when the user invokes `/impeccable` with no argument. They are asking "what should I do?" Make the menu context-aware instead of static. There is no context CLI or signal scanner; inspect the repo directly.

1. Check whether PRODUCT.md and DESIGN.md exist at the repo root. If PRODUCT.md is missing, lead with `/impeccable init` (one line on why) and still show the rest; do not silently jump into init.
2. Look at `git status` and recent changes under `lib/` to find the surface the user is working on.
3. Optionally run `flutter analyze` once for a quick signal.

Then lead with the 2-3 highest-value next commands, each with a one-line reason, followed by the full menu (the Commands table in SKILL.md, grouped by category). Never auto-run a command; the recommendation is a suggestion the user confirms.

Reason over what you found; there is no score to obey:

- DESIGN.md missing while the app has a coherent theme in `lib/core/theme` -> `document` (capture the visual system).
- Changed files point at one screen or component -> scope `audit` or `polish` to those files, naming them.
- `flutter analyze` or the checklist in [flutter-checklist.md](flutter-checklist.md) shows hardcoded colors, text styles, or missing semantics -> `audit`, `extract` (move to theme tokens or shared components), or `harden`.
- A flat or gray palette -> `colorize`; loud or cluttered screens -> `quieter` or `distill`; weak type hierarchy -> `typeset`.
- A new screen is requested -> `shape` then new-work, or straight to building when the brief is clear.
- Otherwise group by intent (build new / improve what exists / systematize), tailored to the current screen.

Keep it to 2-3 pointed picks with the exact command to type. The menu stays the fallback; the recommendation is the lede.
