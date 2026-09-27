# Modular building system

Open **Building** in the editor toolbar. The parts bar appears over the bottom of the viewport. Each piece is an independent scene object with its own material, dimensions, elevation and rotation.

## Build a raised platform or house

1. Drag **Platform** from the parts bar onto the terrain, or click the part then click the ground. A full rendered preview follows the cursor.
2. Set its **Y offset above ground**. The deck stays level while four pillars extend to the terrain under their corners. Choose **Solid foundation** for a continuous base, or **None / upper floor** for an unsupported deck.
3. Place another platform near one of the cyan snap points. Platforms snap edge-to-edge at a shared elevation and rotation. Switch **Snap pieces** off for free placement.
4. Choose **Wall**, **Half wall**, **Doorway** or **Window wall** and place it at an edge socket. Choose **Stairs** or **Ramp** for an approach. At placement, their rise adjusts between the ground at the foot and the snapped platform top, when that rise is within the supported range.
5. Add **Pitched roof** or **Flat roof** above the room. Platform roof sockets default to a 3 m room height. Wall sockets use the wall's actual height; use those for taller or shorter rooms. Pillars, railings and beams are also available.
6. Choose **Select / move**, then drag a piece to reposition it. **R** or **Rotate 90°** rotates the selected piece or placement preview. The inspector also accepts precise rotation, width, depth and height.
7. Assign each piece **Wood, Stone, Mud, Brick, Plaster, Slate or Thatch**. The textures are procedural and lit in CUDA, and pass through the existing anime and weather finish.
8. Use **Duplicate**, **Delete piece**, **Frame piece** or **F**. **Escape** cancels placement/selection. Undo/redo, local autosave and Save/Load map preserve buildings.

The bar contains 25 parts: Platform, Foundation, Wall, Half wall, Doorway, Window wall, Stairs, Ramp, Pitched roof, Flat roof, Pillar, Railing, Beam, Battlement, Gate arch, Buttress, Arrow slit, Gable wall, Round foundation, Round wall, Round doorway, Conical roof, Pyramidal roof, Hipped roof and Curved wall. Doors and windows are actual openings; there are no interactive door leaves or glass panes in this version.

## See and place larger structures

The parts bar includes silhouette icons and category filters. Use **Castle** for battlements, gate arches, buttresses and arrow-slit walls, **Round / curved** for circular foundations, hollow tower walls, round doorways and quarter-circle walls, or **Roofs** for pitched, flat, conical, pyramidal, hipped and gable pieces. New pieces have actual rendered previews plus a 3D outline, dimension/elevation label and orientation marker. Nearby snap sockets are cyan; the chosen socket gets a larger ring.

- Set width, depth, height, material and support style **before placing** a piece.
- Enable **Repeat placement** to keep the chosen dimensions and place successive pieces. Use **Select / move** or Escape to finish.
- Choose **Grid** for 0.25, 0.5, 1 or 2 metre positioning. Piece sockets take precedence over the grid.
- Choose **Fixed floor level** to place at an absolute world Y instead of raycasting to terrain. This makes upper floors and wall tops much easier to work on. Select a platform and click **Use selected floor level** to use its deck height; for other parts this uses their top. Socket snapping takes precedence over the fixed level. The Y-offset field still edits an existing piece relative to terrain.
- Use **Frame all** to frame visible building pieces, or **Frame piece** for the selection. Search the piece list by name to find parts inside a large structure.
- Battlements snap to wall tops. Gate arches and arrow slits preserve their openings in rendering, shadows and Play-mode collision. Gate arches use stepped stone courses. Gables and the new roofs use sloped surfaces; round parts use analytic curved surfaces. Curved wall is a quarter-circle section; its sockets join another quarter at the same height or stack it above. Occupied sockets are skipped. Round wall thickness is 20% of the radius. Equal width and depth gives a circle; unequal dimensions give an ellipse. Round foundations can use a solid terrain-reaching base or no support for an upper slab.

## Castle template

Open **New Project → Templates → Castle → Create Project**. The 256 m map contains a stone castle with four round towers, crenellated curtain walls, wall walks, courtyard stairs, a gate arch, conical front-tower roofs, open rear battlements, pyramidal gatehouse roofs, a keep with a hipped slate roof, tables/benches, a timber bridge, four water polygons forming a moat, spline roads, grass areas and surrounding trees.

Every building component is an ordinary editable piece. There are no baked castle meshes. The player starts on the approach road: walk over the bridge, through the main gate and into the keep. Compact courtyard switchbacks with turning landings reach the wall walks; tower stairs and landings reach the rooftop battlements. The fixed-step traversal test exercises these routes.

A standalone saved copy is provided as [castle-example.json](../artifacts/castle-example.json). Creating any new project replaces the active map; save a file first if you want to keep your current world.

## Terrain and snapping

A piece stores its world elevation. The Y offset field displays its elevation relative to the terrain at its centre. Sculpting changes that displayed offset and the length of platform supports, while keeping connected deck heights level. Platforms do not flatten or excavate terrain. Pillars sample the four corners, and solid foundations extend below the lowest sampled ground height.

Snapping aligns pieces at placement or movement; it does not create a parent/child constraint. Moving or resizing one piece does not automatically move its neighbours. Walls have independent materials and heights. Use Gable wall to fill pitched-roof ends; the system does not automatically generate a completed house.

## Play mode

Platforms and stair treads provide walkable surfaces. Stairs use 4-128 treads according to height, keeping each rise at 25 cm or less throughout the supported 32 m height range. The castle uses short flights with explicit turning and arrival landings. Walls, pillars, foundations and railings block movement; doorways and windows retain their openings. Roofs and ramps have sloped floor/ceiling tests. Collision uses the existing fixed-step character controller and spatial cells. This is static construction, without structural collapse, destruction or rigid-body simulation.

## Rendering and limits

`src/buildings.cu` renders analytic modular solids into the existing depth and picking buffers before water, weather and anime shading. Door/window apertures and support gaps are real geometry. The host uploads piece parameters and screen-tile candidate lists; the shader only tests candidates that may affect each tile. Building data and candidate lists are reused until the map, selection or camera changes. Support heights refresh when terrain is sculpted.

The limit is 2,048 stored pieces. Width is 0.2–32 m, depth 0.15–32 m and height 0.15–32 m. Piece elevations are -512–4096 m. Dense overlapping structures cost more than well-separated ones; these bounds do not guarantee a frame rate. Buildings cast and receive directional sun shadows. Platforms, pillars, stairs, walls and sloped roofs reuse their visible solid shapes, preserving doorway and window apertures. Casters outside the camera view are included. The structural shadow map is cached independently of animated vegetation; placement, terrain, sunlight and shadow-region changes invalidate it. Shadows share the Cast shadows and Shadow strength controls and soften in cloudy weather. Very small features can lose shadow detail at wide viewing distances.

A small mixed-material house/deck example is supplied in [building-example.json](../artifacts/building-example.json). Download it and use **Load map**. Save your current map before replacing it.

## Tests

With the local server running:

```sh
npm run build
npm run test:buildings
npm run test:castle
node scripts/test-castle-visuals.mjs
```

The model tests cover validation, rotated snapping, map round trips, undo, stair traversal, deck floors and wall/door collision. Browser tests exercise the real GPU renderer, drag/drop, snapping, per-piece materials and height, duplication/deletion, history and autosave reload.
