# Corehold

> One tower. Infinite pressure. Build the machine before the swarm solves you.

Corehold is a 2D single-tower incremental roguelite defense game built with Godot 4.x.

The player controls one central tower. Enemies attack from all directions in waves. The tower fires automatically, but the player makes decisions about upgrades, modules, targeting, power, heat, defense, and long-term progression.

## Quick Start

### Prerequisites

- [Godot 4.x](https://godotengine.org/download) (4.2 or later recommended)

### Running the Project

1. Install Godot 4.x.
2. Open the Godot Project Manager.
3. Click **Import** and select this folder (the one containing `project.godot`).
4. Click **Import & Edit**.
5. Press **F5** or click the Play button to run the Main Menu scene.

### Project Structure

```
/corehold
  /addons          - Editor plugins (empty for now)
  /assets          - Art, audio, fonts, VFX
    /audio
    /fonts
    /sprites
    /vfx
  /data            - JSON data files for weapons, enemies, upgrades, waves
  /scenes          - Godot scene files (.tscn)
  /scripts         - GDScript source code
    /core          - Global state, event bus, constants
    /combat        - Tower, enemy, projectile, wave logic
    /systems       - Heat, power, shield, upgrade, save systems
    /ui            - HUD, menus, panels
    /util          - JSON loader, weighted tables, debug tools
  /tests           - Test scenes and scripts
  project.godot    - Godot project configuration
```

## Development Notes

- This project follows a sprint-based roadmap. See GitHub Issues for current work.
- The game is data-driven: weapon stats, enemy definitions, upgrade pools, and wave compositions are loaded from JSON files in `/data`.
- All game logic is kept separate from UI where practical.
- The project should remain playable after every issue is completed.

## License

All rights reserved. This project is not yet licensed for redistribution.
