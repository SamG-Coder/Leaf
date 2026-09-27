# Cast shadows

The editor enables **Cast shadows** by default, below Anime shading. **Shadow strength** controls their contrast; switching shadows off skips the shadow work. These are viewport settings, like the anime style, and are not saved in map JSON.

Trees, bushes and rock/crystal formations cast directional shadows onto terrain, water and other visible objects. The light follows the manual sun controls or the environment clock. Cloud cover reduces shadow contrast; shadows fade near the horizon and turn off below it. Moon shadows are not implemented.

## Rendering and performance

`src/shadows.cu` builds a 1024 by 1024 directional height map using the same species and 32-bit seeds as the vegetation. Trees and bushes use 128 canopy ellipsoids, trees add 16 approximate trunk segments, and mineral formations use their 16 seeded bodies. The caster list includes off-screen objects. No leaf geometry is regenerated for shadows.

The map uses 4 MiB of GPU storage. A separate reusable caster buffer reserves 4.8 MB for the maximum 100,000 placements. The receiver pass reconstructs world positions from scene depth and uses four filtered shadow comparisons per visible pixel. It preserves picking and depth, runs after water and before weather/anime finishing, and leaves the sky unchanged.

Stationary scenes reuse the shadow map. Object and terrain changes, sun changes and moving outside the snapped shadow region invalidate it. Wind deformation is sampled at 8 Hz; sun changes update immediately. Caster data is reused between wind updates. The shadow region follows the camera pivot and expands with viewing distance, from 128 to 4,096 metres, fading at its boundaries.

## Current limits

These are efficient shape approximations, not exact leaf/branch triangle shadows. Small branches, grass, flowers, ferns, vines, moss, crops, mushrooms, litter and deadwood are not shadow casters. Terrain receives object shadows but does not yet cast shadows from hills. Shadow texels become coarser in wide views. Wind shadows update less often than visible foliage. Filtered edges soften aliasing but do not simulate area-light penumbrae. Existing broad ground-cover shading remains an additional artistic term.

## Validation

Run `npm run build`, then with the local server running on port 5197 run `node scripts/test-shadows.mjs`.

The GPU test checks cast shadows on ground, an off-screen tree casting while no scene objects are rendered, reversed sun direction, hidden-caster removal, terrain-edit invalidation, cache reuse, unchanged depth/picking/sky and all three anime finishes on the island. Screenshots and measured timings are written under `artifacts/shadows-*`.

A local headless Edge run at 1024 by 768 with 1,405 island casters measured approximately 2.2 to 3.3 ms for the shadow section in its final 12-frame sample. These are synchronized wall-clock measurements including submission and CPU work, not isolated GPU timestamps or a guarantee for other hardware, 1080p, or worst-case maps. An earlier sample had a 12 ms outlier; broader flight/storm performance still needs monitoring.
