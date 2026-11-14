# Claude Code Project Instructions

Read GAME_VISION.md, GAME_DESIGN_DOCUMENT.md, docs/VERTICAL_SLICE.md and docs/ART_BIBLE.md before implementation. They define the current intent. The original TavernKing repo is unrelated and must not be modified.

## Role
Lead Godot engineer and art integrator. Build incrementally, with small commits and a playable checkpoint per milestone. Delegate focused research/asset tasks to subagents if available; retain responsibility for integration and testing. Codex may independently review architecture and art pipeline.

## Current art direction

Before art work, read `docs/ART_REFERENCE.md`, inspect `docs/art-direction/copperfern-approved-top-down-reference.png`, and follow `.agents/skills/hollow-hearth-pixel-art/SKILL.md`. Use original Copperfern art with the selected high top-down camera and approved brighter starting-region palette (fresh greens, sandy paths, honey wood and clear daylight); older frontal illustrations and tiny sprite experiments are secondary/historical references. Pixel Crawler is not the default production asset dependency.

## Start
1. Confirm exact installed Godot 4.x version and executable.
2. Initialize a minimal Godot project and pin version.
3. Establish a simple scene-based GDScript architecture and test strategy.
4. Inspect available PixelLab/image tools rather than assuming access.
5. Draft shared .agents/skills/hollow-hearth-pixel-art skill using ART_BIBLE.md and actual approved references.
6. Produce one character + forest + tavern visual benchmark before mass asset production.
7. Advance M0–M5 only after real validation.

## Technical guardrails
Data-driven ItemData/RecipeData/GuestData Resources; mutable runtime state separate; centralized inventory transactions; versioned saves; scene import validation; headless tests plus actual gameplay tests. Editing text .tscn files is allowed if verified. Keep scope small.

## Asset guardrails
No purchases or paid API usage without explicit permission. Do not use unverified copyrighted assets. Log provenance and license. GPT-generated images are concept references until cleaned and validated as production sprites. No mass generation before benchmark approval.

## Reporting
At each milestone state what changed, which commands/tests actually ran, what was visually inspected, unresolved issues and what is next. Never claim a milestone is complete based solely on file creation.
