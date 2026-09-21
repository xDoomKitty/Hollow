# Asset provenance

All game-specific graphics are original code-native art in `game/scripts/map_view.gd`: underground floors/walls, transit tracks, containers, camp structures, colonist coats/packs/lamps, creatures, stairs, fog and map overlays. Wayfarer adds original wagon/roadstead, screw-jack, paired-lane and shared-load ledger symbols. Underway Fork adds original signpost, survey-case, radiant bridge, shrouded bypass and route-token symbols. `game/assets/icon.svg` is an original vector icon. No assets were extracted from RimWorld, Project Zomboid or another game.

Original sound effects and ambience are synthesized by `tools/create_audio.py` into the WAV files in `game/assets`. The generator is retained so these assets can be edited and reproduced. There are no recorded samples or third-party game audio assets.

The engine supplies its fallback font and rendering/audio functionality. `tools/write_licenses.gd` collects Godot's engine license, component notices and attribution information into `game/assets/ENGINE_NOTICES.txt`, included in exports. This document records provenance; it does not replace the individual dependency licenses or a later commercial release review.

Engine source and distribution: https://godotengine.org/download/archive/4.5.1-stable/
