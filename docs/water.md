# Water and shoreline materials

Open **Terrain**. Enable **Ocean to the horizon** and set sea level to flood low terrain. Ocean rendering extends beyond map edges; terrain outside the editable map is treated as a deep seabed. Shared wind, rain and animation controls also live in Terrain.

Drag **Water plane** or **Grass area** from the Scene asset library into the viewport. The actual rendered object follows the cursor before dropping; placement is saved only on drop. Select the placed polygon in the scene or hierarchy to show its inspector and corner handles. Terrain masks water wherever ground rises above its surface.

Use **W** for move, **E** for rotation around Y, and **R** for uniform scale. X/Z movement keeps ordinary objects and grass attached to terrain. Only water polygons have a vertical Y handle. These shortcuts leave RMB + WASD flight controls intact. Transforms support undo and redo.

Ocean/coastal water blends sand into shores and seabeds. Ponds and lakes use earthy, wet bank materials. Material transitions use actual ground height relative to the surface and distance from each rotated plane boundary. Water colour changes with depth, with limited transmission of the existing scene in shallows and a narrow foam band. No image textures are required.

## ClearWater adaptation

Only the dielectric Fresnel function and wind-driven normal/reflection approach from `D:/ClearWater/src/clearwater.cu` were adapted into `src/water.cu`. The original copyright notice is preserved in `vendor/LICENSE.ClearWater`. Leaf adds a small analytic wave-normal field, broad colour bands, restrained glints and shoreline foam before its existing painterly finish. No FFT simulation, caustics, ripple solver, glare/bloom pipeline, native application or ClearWater demo assets were imported.

This is a surface shader, not fluid simulation: water planes remain horizontal; waves affect normals and shading, not geometry. Reflections approximate the sky rather than tracing scene objects. Underwater camera rendering/refraction and flowing rivers are not implemented.

## Shared weather interface

`map.water.weather` contains windDirection (degrees), windSpeed (0-30 m/s), and rain (0-1). Every ocean and plane receives the same values in one water dispatch. These are manual preview controls and a data interface for the future weather system, not a complete weather simulation. Wind controls ripple normals and motion, while rain affects surface streaks and illumination. Water animates by default with 4 m/s wind at 45 degrees. Pausing preserves its current phase and avoids continuous full-scene rendering during editing.

Water data is optional in version-1 maps; old maps load with water disabled. New data participates in save/load, autosave, undo and redo. The renderer adds one full-screen water pass only when a surface is enabled, plus water proximity checks in the existing ground pass. Cost depends on the number of enabled planes; no work is added for disabled water apart from an empty ground loop.


## Polygon scene objects

Select an area in Scene, then use Draw grass or Draw water in its inspector, click 3 or more corners on the terrain, then Finish outline. Plans appear in the scene hierarchy and can be selected by clicking their filled area. Drag a corner handle to resize, click a plus handle on an edge to insert a corner, or drag the filled object to move the entire outline. Corners can also be edited or removed in the coordinate list. Concave outlines are supported; crossing edges and zero-area outlines are rejected. Escape cancels an unfinished outline. Existing rectangular water surfaces can be converted using Edit polygon outline, even if buried, or by clicking the visible surface.

Only water offers a Y offset (absolute metres from world zero). Water can sit below the ground; it becomes visible wherever terrain is below the water surface. Grass tile roots always follow terrain and have no editable vertical offset. Water polygons share the same weather and shoreline-material system as the ocean and rectangular surfaces.

Plans currently support grass and water fills. Grass tile spacing, scale and species are configurable; tile centres are clipped to the polygon, while individual blades may naturally extend across its edge. Deterministic tile transforms reuse the same species/seed geometry, rather than generating one unique mesh per tile. Each grass plan uses one picking ID for the filled scene object. There are at most 16 polygon plans with 32 corners each and 8,192 grass tiles total; dense bounding grids over 100,000 candidate cells are rejected before generation. The existing renderer's visible-object and geometry budgets still apply. Very large plans should use wider spacing.

Validation: test-plans.mjs checks concave filling, invalid edges, on-object edge insertion, vertex and body dragging, water-only height, buried surfaces, serialization and undo. test-water.mjs checks ocean, polygon editing, shared wind and animation. test-scene-tools.mjs checks move/rotate/scale handles, actual previews before placement, water-only Y handles and Terrain ocean controls. The forest water benchmark before polygon additions measured 9.17 ms dry versus 9.71 ms with ocean (10 versus 11 dispatches); these local warmed measurements are not a worst-case bound for 49 water surfaces.

Select a corner and use **Delete selected node** to remove it; deletion is disabled at three nodes. **Smooth curved edges** rounds the corners for both grass clipping and water rendering while retaining editable control nodes. Curves use up to 128 sampled boundary points. **Seeded random grass rotation** can be disabled for aligned tiles; the grass rotation seed produces repeatable rotation per tile without changing position or scale.
