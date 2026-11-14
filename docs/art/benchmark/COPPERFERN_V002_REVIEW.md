# Copperfern V002 — visual review pack

Everything below is captured from Godot 4.7.2 running the benchmark scene, except the approved
reference (concept art). No new assets were generated for this pack. Details and provenance:
[COPPERFERN_BENCHMARK_V002.md](COPPERFERN_BENCHMARK_V002.md).

## 1. Approved reference vs V001 vs V002
![](copperfern_v002/review_compare_reference_v001_v002.png)

## 2. Player character — 4 directions, idle and walk
![](copperfern_v002/review_keeper_sheet_labeled.png)

- Animated, from the sheet: [anim_keeper_sheet_idle_walk_x4.gif](copperfern_v002/anim_keeper_sheet_idle_walk_x4.gif) (left four: idle; right four: walk)
- Animated, in game: [forest](copperfern_v002/anim_keeper_ingame_forest_walk_x3.gif) · [tavern](copperfern_v002/anim_keeper_ingame_tavern_walk_x3.gif) (down, left, right, up)
- Known detail: the north walk frames are drawn ~2 px taller than the north idle frames, so the head shifts slightly when walking north starts.

## 3. Forest (V002 PixelLab terrain, trees, bushes, gathering objects)
| | |
|---|---|
| ![](copperfern_v002/cf_08_forest_path.png) path, meadow, undergrowth edge, trees, bushes, both gatherables | ![](copperfern_v002/cf_10_glowcap_gathered.png) glowcap picked (stubs remain) |
| ![](copperfern_v002/cf_12_moonberry_gathered.png) moonberry picked (leaves only) | ![](copperfern_v002/cf_13_behind_tree_fade.png) keeper behind a tree (canopy fades) |

Still V001 in the forest: the tiny decor tiles (flowers, pebbles, grass tufts), item icons, HUD.

## 4. Tavern (current interior)
![](copperfern_v002/review_tavern_annotated.png)

Only the keeper is V002. Floor, flagstones, walls, counter, table, chairs, stove/fire/pot, doormat and
HUD are V001.

## 5. Gameplay preview
- Video (23 s, 1280×720, 30 fps): [gameplay_preview_v002.mp4](copperfern_v002/gameplay_preview_v002.mp4)
- Same as GIF: [gameplay_preview_v002.gif](copperfern_v002/gameplay_preview_v002.gif)

Scripted with the real input actions (`tests/visual/tour_copperfern.tscn`, recorded with Godot's
`--write-movie`): tavern walk → out the door → up the forest path → gather glowcaps → cross to the
moonberry bush and gather → walk back past and behind the trees.
