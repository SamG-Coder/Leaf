# Play mode

Set **Player start** in the inspector using X/Z and heading, **Place start in viewport**, or **Use camera location**. The cyan marker shows its location. Starts attach to terrain or float at the surface of deep water. Start coordinates are saved in map JSON, autosave and undo history; legacy maps default to the centre.

Click **Play** to hide the editor and enter first person. Mouse look uses pointer lock where the browser permits it. If mouse capture is blocked, hold the left mouse button and drag to look; movement still works. Escape opens the pause menu with Resume, Restart and End Play. Losing an established pointer lock, leaving the window, or hiding the page also pauses. Capture failure at startup does not pause. End Play restores the editor camera, settings and environment state.

- WASD: move; Shift: run on land.
- Space: jump on land, swim upward in deep water.
- Ctrl or C: dive. Looking up/down while moving also steers swimming.
- Once submerged, release vertical controls to hold depth. Look down while moving or use C/Ctrl to dive; Space rises.

Character physics runs at a fixed 60 Hz with bounded catch-up. Jumping works while walking or sprinting, including immediately on spawn, with a short input buffer and coyote time. It includes gravity, jumping, terrain grounding, map boundaries and approximate upright collision volumes for tree trunks, rocks and deadwood. Nearby colliders are queried through spatial cells. Plants remain static; there is no rigid-body simulation or branch/leaf collision. Collider silhouettes are approximate and rock stepping/climbing is not implemented.

Swimming uses the same ocean, rotated water rectangles and smoothed polygon outlines as scene water. Underwater rendering uses separate colour-channel absorption to preserve nearby seabed contrast, FFT-driven surface normals/refraction, Fresnel reflection and moving seabed caustics in CUDA. Reflections reuse visible scene colour and use a bounded three-step terrain-height lookup outside the screen. The fallback approximates sandy bed colour; it does not reflect off-screen objects or fully trace refraction/polygon-side exits. It reuses the wave field and one output buffer without a second scene render. The viewport fills the available window while retaining the renderer's existing internal resolution.

Play movement and temporary environment progression do not edit the map. Pause freezes movement and play animation time. The configured environment clock still honours its Play time checkbox.

Validation: `node scripts/test-play-model.mjs` covers movement, jumping, grounding, collision, swimming, resurfacing, water bounds and spawn serialization. `node scripts/test-play-browser.mjs` covers real pointer lock, blocked-capture fallback, keyboard movement, drag look, underwater rendering, pause/resume and restoring the editor.

Rain streaks and water splash rings share a quantized 60 Hz animation clock. Camera rendering and cloud animation are not capped. This caps animation phases, not the number of weather shader dispatches.

`node scripts/test-underwater-views.mjs` captures horizontal, seabed and upward surface views in a separate Edge test session and checks for GPU errors. Outputs are in `artifacts/underwater-*.png`.
