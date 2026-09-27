# Water and shoreline materials

Open **Terrain**. Enable **Ocean to the horizon** and set sea level to flood low terrain. Ocean rendering extends beyond map edges; terrain outside the editable map is treated as a deep seabed. Shared wind, rain and animation controls also live in Terrain.

Drag **Water plane** or **Grass area** from the Scene asset library into the viewport. The actual rendered object follows the cursor before dropping; placement is saved only on drop. Select the placed polygon in the scene or hierarchy to show its inspector and corner handles. Terrain masks water wherever ground rises above its surface.

Use **W** for move, **E** for rotation around Y, and **R** for uniform scale. X/Z movement keeps ordinary objects and grass attached to terrain. Only water polygons have a vertical Y handle. These shortcuts leave RMB + WASD flight controls intact. Transforms support undo and redo.

Ocean/coastal water blends sand into shores and seabeds. Ponds and lakes use earthy, wet bank materials. Material transitions use actual ground height relative to the surface and distance from each rotated plane boundary. Water colour changes with depth, with depth-dependent transmission of the existing scene in shallows and a narrow foam band. No image textures are required.

## ClearWater adaptation

Leaf adapts the CUDA FFT and optics from [SamG-Coder/clearwater](https://github.com/SamG-Coder/clearwater/blob/b0c3bdbc87edf20e7c2dace5ad75efcfae2bf475/src/clearwater.cu), verified against the GitHub main revision `b0c3bdb`. The original MIT copyright notice is preserved in `vendor/LICENSE.ClearWater`.

- Two seeded **64 × 64 inverse FFT cascades**, spanning 37 and 149 metres, drive wave normals, reflection distortion and surface shading. This uses 8,192 spectral cells instead of ClearWater's 196,608 cells and 32 times fewer FFT butterfly outputs per update. The wave field updates at most 30 Hz, with no work when its time and wind inputs are unchanged. Wind rotates the field and controls its strength. Polygon river flow advects it independently.
- **Scene reflections** trace the existing opaque scene at half width and half height, using at most 16 march steps and three intersection refinements. No reflected scene geometry is rendered. Screen edges and misses fade to a procedural sky/cloud reflection that uses the existing weather cloud-density function.
- **Shallow-water optics** retain depth-dependent transmission and add bounded refraction distortion, brighter moving caustics derived from wave-slope divergence, and a changing shoreline wash. Fresnel reflection, highlights and foam remain visible over transparent beds; transmission no longer attenuates reflection a second time.
- Rendering remains in `.cu`, with JavaScript handling buffers, dispatch and editor input. ClearWater's demo assets, full ripple solver, photon caustics, bloom and native application are not imported.

Under Terrain's shared water controls, **Wave visibility** adjusts the normal strength, **Scene reflections** enables/disables scene tracing, and **Animate water preview** plays/pauses water time. Wave visibility and scene-reflection controls are viewport preferences, not map properties.

Water planes remain horizontal: FFT height contributes to appearance but does not displace polygon geometry or change picking. This is not fluid simulation. Caustics approximate light focusing rather than tracing photons. Scene reflections can only show geometry represented in the current camera's opaque depth buffer; hidden/off-screen objects use the sky fallback. Play mode now includes an underwater camera with absorption, haze and an approximate surface light window; see [Play mode](play-mode.md). The finite FFT fields repeat, and distant detail is filtered to reduce aliasing.

The wave buffers reserve about 512 KiB. At 1920 × 1080, immutable scene colour/depth snapshots plus the half-resolution reflection buffer use about 23.7 MiB. The snapshots prevent refraction from reading partially written water pixels. Buffers are allocated lazily on the first enabled water surface and reused thereafter.

## Shared weather interface

`map.water.weather` contains windDirection (degrees), windSpeed (0-30 m/s), and rain (0-1). Every ocean and plane receives the same values in one water dispatch. The environment weather system overrides wind speed and rain when enabled; otherwise these manual preview values apply. Wind controls ripple normals and motion, while rain affects surface streaks and illumination. Water animates by default with 4 m/s wind at 45 degrees. Pausing preserves its current phase and avoids continuous full-scene rendering during editing.

Water data is optional in version-1 maps; old maps load with water disabled. New data participates in save/load, autosave, undo and redo. When water is enabled the renderer updates the shared FFT field as needed, traces reflections if enabled, and composites one full-screen water pass, plus water proximity checks in the existing ground pass. Cost depends on the number of enabled planes; no work is added for disabled water apart from an empty ground loop.


## Polygon scene objects

Select an area in Scene, then use Draw grass or Draw water in its inspector, click 3 or more corners on the terrain, then Finish outline. Plans appear in the scene hierarchy and can be selected by clicking their filled area. Drag a corner handle to resize, click a plus handle on an edge to insert a corner, or drag the filled object to move the entire outline. Corners can also be edited or removed in the coordinate list. Concave outlines are supported; crossing edges and zero-area outlines are rejected. Escape cancels an unfinished outline. Existing rectangular water surfaces can be converted using Edit polygon outline, even if buried, or by clicking the visible surface.

Only water offers a Y offset (absolute metres from world zero). Water can sit below the ground; it becomes visible wherever terrain is below the water surface. Grass tile roots always follow terrain and have no editable vertical offset. Water polygons share the same weather and shoreline-material system as the ocean and rectangular surfaces.

Plans currently support grass and water fills. Grass tile spacing, scale and species are configurable; tile centres are clipped to the polygon, while individual blades may naturally extend across its edge. Deterministic tile transforms reuse the same species/seed geometry, rather than generating one unique mesh per tile. Each grass plan uses one picking ID for the filled scene object. There are at most 16 polygon plans with 32 corners each and 8,192 grass tiles total; dense bounding grids over 100,000 candidate cells are rejected before generation. The existing renderer's visible-object and geometry budgets still apply. Very large plans should use wider spacing.

Validation: test-plans.mjs checks concave filling, invalid edges, on-object edge insertion, vertex and body dragging, water-only height, buried surfaces, serialization and undo. test-water.mjs checks ocean, polygon editing, shared wind and animation. test-scene-tools.mjs checks move/rotate/scale handles, actual previews before placement, water-only Y handles and Terrain ocean controls. The forest water benchmark before polygon additions measured 9.17 ms dry versus 9.71 ms with ocean (10 versus 11 dispatches); these local warmed measurements are not a worst-case bound for 49 water surfaces.

Select a corner and use **Delete selected node** to remove it; deletion is disabled at three nodes. **Smooth curved edges** rounds the corners for both grass clipping and water rendering while retaining editable control nodes. Curves use up to 128 sampled boundary points. **Seeded random grass rotation** can be disabled for aligned tiles; the grass rotation seed produces repeatable rotation per tile without changing position or scale.

Transparency uses exponential attenuation over the underwater viewing-ray distance. Shallow water reveals terrain and submerged objects; deeper water becomes opaque. Coastal water is clearest, lakes intermediate, and ponds murkier. Fresnel reflection and shoreline foam remain visible. This composites a snapshot of the existing scene with bounded refractive distortion; pixels without a rendered seabed retain the water colour.

Water uses broad irregular wave shading with distance-filtered ripples and a narrow, softly varying shoreline wash. Beyond map edges the synthetic seabed stays submerged, avoiding an unrendered land strip between terrain and ocean.

Water polygon inspectors include Directional river flow, direction (0 degrees along +X, 90 along +Z), and speed in metres per second. Current advects the procedural surface pattern independently of shared wind and persists with the map. Surfaces remain horizontal: this is a visual current, not downhill fluid simulation.

The Example button now creates a 1000 by 1000 metre island map: ocean and sandy shores, two wooded uplands, four curved grass areas using seeded rotation, a lagoon and a carved river channel. The original forest generator remains available in source for stress testing.

## FFT and reflection validation

With the local server running, use `node scripts/test-water-fft.mjs`. The test compares the GPU Stockham transform against an independent CPU direct 2D DFT for two complex fields in both cascades, checks finite evolving wave data, stronger slopes in stronger wind, paused-field reuse, and reflection-on/off image differences. It captures 1080p reflections, shallow water and the island in a storm. `artifacts/water-fft-validation.json` includes full per-pass profiles for clear and storm island runs. `artifacts/water-fft-first-profile.json` retains the first shorter run, including its total-frame outlier; timings are synchronized wall-clock measurements, not GPU-only timestamps or a frame-rate guarantee.

Existing `test-water.mjs` covers ocean toggling, legacy maps, wind controls, polygon editing, serialization, undo and animation. `test-anime-styles.mjs` checks all three finishes and day/night rendering.
