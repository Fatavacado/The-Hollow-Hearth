# Gameplay Loop and Session Structure

## Free-form session
The player starts in or near the tavern and chooses the next activity. There is **no required order** between adventuring and tavern service, aside from needing ingredients to cook and meals to fulfill orders.

### Adventure
Walk into a region → observe and explore → gather resources → manage carrying capacity → return by choice.

### Preparation
Inspect inventory → choose an unlocked recipe → prepare food through a short interaction → stock available dishes or prepare during service (implementation to be tested).

### Tavern
Explicitly toggle **Open** → guests arrive and request dishes → fulfill orders → receive coins and progression feedback → close when desired.

### Growth
Spend earned resources on equipment or tavern upgrades. The first upgrade should make the next exploration outing measurably better (candidate: satchel capacity).

## Anti-frustration rules
No penalties for staying closed. Avoid hard timers for routine gathering. Don't require cooking the same long minigame for every dish. Make service pacing forgiving. Keep a viable basic recipe available to avoid progression dead ends.

## Questions to prototype
Whether cooking happens before/during service; how many simultaneous guests remain fun; whether service ends immediately or after current guests when closing; how day/night affects ambiance without imposing a schedule.
