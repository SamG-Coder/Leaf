# Building and path performance audit

Measured on 28 September 2026 in headless Microsoft Edge 154 on the local Windows machine, using real WebGPU rendering at the editor's 1024 x 768 internal resolution. Baseline: `804d52b`.

## Method

- Eleven deterministic scenes, eight warm-up frames followed by 72 measured frames per scene (792 measured frames per run).
- All 13 building shapes and seven materials; 14 path materials. The largest path fixture has 32 paths, 1,024 nodes, 992 curved edges and 12,896 sampled segments before editing.
- Anime shading, ground detail and shadows remain enabled. Same seeds, cameras, resolution, shape geometry, spline sampling, material shaders and 1024-square building shadow map in both runs.
- Fast flight covers 900 metres across a 1 km map, moving the camera pivot and shadow region as well as the camera. Close inspection uses a 1.8 m camera among building pieces. These are deterministic stress fixtures, not a designed village.
- Main timings measure CPU edits/validation plus the entire render call through GPU completion. Pixel readback/hashing happens after the timer. Profile-mode stage timings are separate diagnostic runs with additional queue waits; they are **not GPU timestamp measurements**, and must not be added up to estimate normal frame time.
- Each scenario records six SHA-256 checkpoints for final colour, depth, picking IDs and building shadow data. All 66 checkpoints match exactly before/after. Profile mode also matches normal rendering.
- Tests use a separate browser context and renderer, without modifying the user's saved editor world.

## Results

Milliseconds per frame; lower is better. P95 is the 95th percentile of 72 samples. Maximums are included because medians alone conceal stalls.

| Scenario | Median before / after | P95 before / after | Maximum before / after |
|---|---:|---:|---:|
| Empty terrain, orbit | 3.0 / 3.1 | 4.2 / 4.2 | 5.4 / 6.4 |
| 256 pieces, stationary | 3.1 / 3.0 | 4.1 / 4.2 | 5.1 / 4.5 |
| 256 pieces, orbit | 4.6 / 4.0 | 6.0 / 5.1 | 15.0 / 5.4 |
| 2,048 pieces, fast flight | 17.9 / 12.3 | 19.5 / 14.0 | 21.2 / 14.5 |
| 2,048 pieces, close inspection | 11.0 / 8.1 | 13.0 / 9.3 | 20.9 / 11.5 |
| Drag a piece among 256 | 5.0 / 4.7 | 6.9 / 5.3 | 32.4 / 5.9 |
| 256 pieces, changing sun | 4.0 / 4.0 | 4.5 / 5.0 | 5.2 / 5.1 |
| 14 paths, orbit | 3.0 / 3.1 | 4.0 / 4.1 | 4.1 / 4.2 |
| 32 paths, orbit | 3.0 / 3.0 | 4.2 / 4.0 | 4.7 / 4.5 |
| Edit a curve in 32 paths | 5.9 / 6.0 | 7.9 / 7.4 | 10.3 / 8.0 |
| 512 pieces + 14 paths, fast flight | 7.0 / 5.4 | 8.1 / 6.6 | 9.4 / 7.5 |

The largest flight fixture submits between 0 and 1,900 building pieces per frame, with 32 shadow-map rebuilds across the route. The close fixture submits between 71 and 1,455 pieces. Building edits and moving sun each rebuild shadows on all 72 measured frames; stationary/orbit cameras with a fixed shadow region retain cached shadows.

## Finding and change

The significant measured bottleneck was CPU building culling preparation. Every piece projects eight bounding corners; each corner was independently recalculating the camera basis and tangent, and constructing intermediate arrays. A prepared camera projector now reuses those camera calculations for the frame, preserving the original arithmetic order and bounds.

For the 2,048-piece fast flight, median CPU building preparation fell from **9.9 ms to 4.7 ms**. Whole-frame median fell by about **31%**. No CUDA shader, geometry detail, material, culling boundary, shadow resolution or path sampling was simplified.

The profiler now starts its total timer before path preparation and reports a separate building stage. Previously path-index preparation was missing from total time and building rendering was not attributed to its own stage.

## Path findings

Camera movement reuses the path index; it is not rebuilt every frame. At the measured density (maximum 64 segment references per cell before editing), paths were inexpensive during flight. Editing requires validation and index/upload work: the same curve network is sampled for validation and again for rendering. This remains a potential optimization, but this audit makes no path-rendering or path-quality changes. Small differences in path timings between runs are noise, not a claimed speedup.

Further checks should target large terrain extents with concentrated path networks, grass-area exclusion during edits, and long interactive editing sessions. The current 64 x 64 path grid can have many candidates in a cell on larger maps. Building preparation also still visits all pieces and samples terrain supports during camera movement; those are future cache opportunities requiring terrain-edit invalidation coverage.

## Validation and boundaries

- 10,000 randomized camera projections compare exactly with the original projector, including points behind the camera, at its position, large world coordinates and varied lenses.
- Building model/browser tests, path model/browser tests and building shadow tests cover placement, drag/drop, snapping, materials, collision, persistence, undo/redo, spline editing, openings, offscreen casters and terrain/shadow invalidation.
- The benchmark measures renderer and model-edit work, not SVG handle layout, pointer-event dispatch, autosave or the complete editor DOM. Compilation and initial shader warm-up are excluded.
- These fixtures isolate buildings and paths. They do not include the full forest, water, rain or physics frame loop, and they do not establish an end-to-end FPS guarantee for the island.
- Runs were serial on one machine. Timing outliers vary with browser scheduling and host load; a shorter maximum in one run does not prove every hitch is eliminated. The captured adapter metadata was empty, so the measurements are not attributed to a specific installed GPU.

## Reproduce

Start the local server on port 5197, then run serially:

```powershell
node scripts/profile-building-paths.mjs artifacts/building-path-performance-before.json --baseline
npm run profile:building-paths
npm run test:performance-parity
npm run test:camera-projector
```

`--baseline` serves the three changed JavaScript modules from commit `804d52b` through Playwright route overrides, without altering the checkout. Both runs use the current harness. This comparison is intended for this change; future shader or fixture changes need a new baseline.

Raw evidence: `artifacts/building-path-performance-before.json` and `artifacts/building-path-performance-after.json`.
