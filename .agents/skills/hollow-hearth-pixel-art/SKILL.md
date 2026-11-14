---
name: hollow-hearth-pixel-art
description: Shared HD pixel-art production and Godot validation workflow for The Hollow Hearth.
---

# Hollow Hearth Pixel Art — Initial Skill

**Read** docs/ART_BIBLE.md and GAME_VISION.md first. This is a starting workflow, not an approved asset specification.

## Process
1. Identify asset role, native gameplay size, camera perspective, palette and neighboring assets.
2. Inspect the actual approved visual references. Never invent unavailable source images.
3. Select a tool: licensed cohesive tileset for terrain; GPT image generation for concept/reference; PixelLab or comparable sprite tooling for production animation when available.
4. Create a **small** asset sample, not a bulk batch.
5. Check transparent background, clean pixel edges, consistent pixel density, frame registration, foot anchor, tile seams and visual readability.
6. Import into Godot using appropriate nearest-neighbor filtering, Y-sort, collision and layering.
7. Inspect in-game at native resolution against other approved assets.
8. Record asset source/license and approve, revise or reject.

## Reference files to develop
- characters.md: proportions, four-direction layout, animations and accessories
- environments.md: terrain autotiling, prop scale, layering and biome palettes
- sourcing.md: provenance and commercial-use checklist
- godot-validation.md: import, camera, scale, sorting and regression tests

## Hard stops
No copying existing commercial game sprites. No assumption that an AI concept image is a production-ready sprite sheet. No unapproved spending. No mass asset production before one coherent character + environment benchmark is accepted.
