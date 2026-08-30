# GeminX Pet Collector — Roblox Simulator

A **pet collecting simulator** for Roblox built on the GeminX governed Roblox
template contracts (native Luau, Rojo sync, Studio MCP, private-playtest-first).

## Game concept

- **Gather stars** across a **Rainbow** world.
- **Level up** by collecting stars and hatching pets.
- **Unlock zones** as you rise in level (Rainbow → Shimmer → Prism → etc.).
- **Checkpoints** save your highest unlocked zone/section.
- **Discover rare rewards** via pet egg hatching with rarity tiers.

## Creator profile
- Game type: **Simulator**
- World style: **Rainbow**
- Highlighted mechanic: **Checkpoints**

## Project layout
- `src/` — Luau source (Rojo `default.project.json`).
  - `src/server/` — server-side game state, zones, checkpoints, saving.
  - `src/shared/` — shared module types (rarity, zones, config).
  - `src/client/` — HUD, touch controls, pet view.
- `default.project.json` — Rojo project map.
- `tests/` — mechanical verification fixtures.

## Honest status
Mechanical build of the native-Luau creator contract. Studio playtest evidence
is **pending** until a Roblox Studio MCP surface is connected — see the
`geminx.creator-acceptance.v1` Roblox gate in the Agent Brain.
