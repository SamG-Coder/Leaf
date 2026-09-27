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

The bar contains 13 parts: Platform, Foundation, Wall, Half wall, Doorway, Window wall, Stairs, Ramp, Pitched roof, Flat roof, Pillar, Railing and Beam. Doors and windows are actual openings; there are no interactive door leaves or glass panes in this version.

## Terrain and snapping

A piece stores its world elevation. The Y offset field displays its elevation relative to the terrain at its centre. Sculpting changes that displayed offset and the length of platform supports, while keeping connected deck heights level. Platforms do not flatten or excavate terrain. Pillars sample the four corners, and solid foundations extend below the lowest sampled ground height.

Snapping aligns pieces at placement or movement; it does not create a parent/child constraint. Moving or resizing one piece does not automatically move its neighbours. Walls have independent materials and heights. Roof ends are open unless filled with appropriate structural pieces; the system does not automatically generate a completed house.

## Play mode

Platforms and stair treads provide walkable surfaces. Walls, pillars, foundations and railings block movement; doorways and windows retain their openings. Roofs and ramps have sloped floor/ceiling tests. Collision uses the existing fixed-step character controller and spatial cells. This is static construction, without structural collapse, destruction or rigid-body simulation.

## Rendering and limits

`src/buildings.cu` renders analytic modular solids into the existing depth and picking buffers before water, weather and anime shading. Door/window apertures and support gaps are real geometry. The host uploads piece parameters and screen-tile candidate lists; the shader only tests candidates that may affect each tile. Building data and candidate lists are reused until the map, selection or camera changes. Support heights refresh when terrain is sculpted.

The limit is 2,048 stored pieces. Width is 0.2–32 m, depth 0.15–32 m and height 0.15–32 m. Piece elevations are -512–4096 m. Dense overlapping structures cost more than well-separated ones; these bounds do not guarantee a frame rate. Buildings cast and receive directional sun shadows. Platforms, pillars, stairs, walls and sloped roofs reuse their visible solid shapes, preserving doorway and window apertures. Casters outside the camera view are included. The structural shadow map is cached independently of animated vegetation; placement, terrain, sunlight and shadow-region changes invalidate it. Shadows share the Cast shadows and Shadow strength controls and soften in cloudy weather. Very small features can lose shadow detail at wide viewing distances.

A small mixed-material house/deck example is supplied in [building-example.json](../artifacts/building-example.json). Download it and use **Load map**. Save your current map before replacing it.

## Tests

With the local server running:

```sh
npm run build
npm run test:buildings
```

The model tests cover validation, rotated snapping, map round trips, undo, stair traversal, deck floors and wall/door collision. Browser tests exercise the real GPU renderer, drag/drop, snapping, per-piece materials and height, duplication/deletion, history and autosave reload.
