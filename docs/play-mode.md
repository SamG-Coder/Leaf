# Play mode

Set **Player start** in the inspector using X/Z and heading, **Place start in viewport**, or **Use camera location**. The cyan marker shows its location. Starts attach to terrain or float at the surface of deep water. Start coordinates are saved in map JSON, autosave and undo history; legacy maps default to the centre.

Click **Play** to hide the editor and enter first person. Mouse look uses pointer lock where the browser permits it. If mouse capture is blocked, hold the left mouse button and drag to look; movement still works. Escape opens the pause menu with Resume, Restart and End Play. Losing an established pointer lock, leaving the window, or hiding the page also pauses. Capture failure at startup does not pause. End Play restores the editor camera, settings and environment state.

- WASD: move; Shift: run on land.
- Space: jump on land, swim upward in deep water.
- Ctrl or C: dive. Looking up/down while moving also steers swimming.
- Release swim controls to drift toward the surface.

Character physics runs at a fixed 60 Hz with bounded catch-up. It includes gravity, jumping, terrain grounding, map boundaries and approximate upright collision volumes for tree trunks, rocks and deadwood. Nearby colliders are queried through spatial cells. Plants remain static; there is no rigid-body simulation or branch/leaf collision. Collider silhouettes are approximate and rock stepping/climbing is not implemented.

Swimming uses the same ocean, rotated water rectangles and smoothed polygon outlines as scene water. Underwater rendering adds distance absorption, teal haze, mild distortion and an approximate surface light window in CUDA. It does not ray-trace underwater refraction or polygon-side exits. The viewport fills the available window while retaining the renderer's existing internal resolution.

Play movement and temporary environment progression do not edit the map. Pause freezes movement and play animation time. The configured environment clock still honours its Play time checkbox.

Validation: `node scripts/test-play-model.mjs` covers movement, jumping, grounding, collision, swimming, resurfacing, water bounds and spawn serialization. `node scripts/test-play-browser.mjs` covers real pointer lock, blocked-capture fallback, keyboard movement, drag look, underwater rendering, pause/resume and restoring the editor.
