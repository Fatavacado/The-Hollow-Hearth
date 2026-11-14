# Game Design Document — Living Draft

## 1. Premise
The player inherits or establishes a small tavern at the edge of an extraordinary fantasy region (exact origin story TBD). Travelers, ghosts, forest spirits, monsters and other beings visit for food. The player is also an adventurer: expeditions supply the kitchen and reveal a wider world.

## 2. Player agency and time
- Player may **open or close the tavern voluntarily**, including taking a whole day to explore.
- No automatic punishment merely for staying closed.
- Service only begins when the player explicitly opens. Guests arrive according to simple, understandable service rules.
- Time-of-day, weather and regional events can change ambience and opportunities, but must not create stressful mandatory chores.
- Any future scheduling mechanics require testing against the freedom-of-rhythm pillar.

## 3. Exploration
Top-down movement through hand-authored, readable regions with gathering nodes, pathways, environmental interactions, secrets and optional hazards. Start with a small forest. Expand later to meadows, rivers, ruins, caves and stranger biomes only after the slice succeeds. Expeditions should offer meaningful choices and discoveries, not just repetitive clicking.

## 4. Gathering and inventory
Interact with resource nodes; collect ingredients and materials; carry them in a limited inventory with clear feedback. Shared item definitions and centralized inventory transactions prevent duplicate grants, negative quantities and inconsistent consumption. Gathering tools may unlock resource types or improve convenience.

## 5. Cooking
Recipes combine ingredients into dishes. Cooking is short, tactile and legible, with optional mastery rather than obligatory lengthy minigames. Dishes differ by ingredient cost, value and customer preference. Initial slice: five ingredients and three recipes.

## 6. Tavern service
The player chooses when to open. Guests arrive, place readable orders, wait for preparation and receive food. Serving produces money and progression feedback. Start with two distinguishable supernatural guest archetypes. Service should remain manageable by a solo player, with no staff automation in the slice.

## 7. Progression
**Player:** gain experience from meaningful exploration, gathering, cooking and service; unlock carefully selected perks or capabilities. No final XP formula until playtesting.

**Equipment/tools:** purchase or craft improvements such as a better gathering tool or expanded satchel. Each upgrade must make a noticeable difference in subsequent play.

**Tavern:** improve kitchen equipment, preparation options, capacity, comfort and eventually visual customization. Upgrades should affect available actions and service choices, not just revenue multipliers.

**World:** discover recipes, materials and routes; progression may gate some areas by tools or exploration achievements. Avoid grind walls.

## 8. Economy
Revenue from fulfilled orders; expenses for selected upgrades and optional supplies. Prevent softlocks: the player must retain a viable path to collect ingredients and serve a basic dish. No debt, rent pressure or mandatory daily operating costs in the first slice.

## 9. Supernatural identity
Creatures have personality, preferences and whimsical behavior. Their supernatural nature can create distinctive dishes and interactions without demanding an extensive dialogue system. Some regions can be eerie or dangerous, but the home tavern remains welcoming.

## 10. Feedback and UX
Clear interaction prompts, item pickup feedback, recipe ingredient requirements, guest order visibility, currency changes, upgrade consequences, accessible save/load, and clear opening/closing state.

## 11. Technical principles
Godot 4.x, GDScript, modular scenes, data-driven ItemData/RecipeData/GuestData resources, runtime state separated from definitions, versioned saves, input remapping where practical, consistent pixel rendering, automated headless checks plus real gameplay tests.

## 12. Not in the initial slice
Large overworld; full farming/fishing simulation; combat system; staff hiring; procedural generation; extensive narrative arcs; dozens of guests; multiplayer; advanced placement/building system. These are candidates only after a fun slice is validated.

## 13. Success criteria
A player can voluntarily explore, gather, cook, open, serve, earn, upgrade, save and reload, then repeat the loop without developer intervention. A 10–15 minute playtest is satisfying, comprehensible and visually coherent.
