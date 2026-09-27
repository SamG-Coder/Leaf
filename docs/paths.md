# Terrain-attached spline paths

Paths are scene objects made from connected quadratic curves, rather than filled polygons. Their surface is shaded directly on the terrain, including slopes and subsequent sculpting. There is no separate floating mesh or Y offset.

## Create and edit

1. In **Scene**, find **Spline path** in the library (or the **Paths** category). Drag it onto the ground, or select the card and click the terrain.
2. Select the path in the scene hierarchy or click its surface. **Frame path** / **F** brings it into view.
3. Drag a **round node** to move it along the terrain. Drag a **square handle** to bend that connection.
4. Select a round node, click **Extend / connect**, and click terrain to add connected nodes. Click another existing node to create a junction or close a loop. Click **Finish** to stop extending.
5. Select a square handle and use **Split selected connection** to insert a node without changing the curve.
6. Select a round node and use **Delete selected node** to remove it and its incident connections. Isolated nodes are removed too. At least one connection must remain; **Delete path** removes the whole object.
7. Drag the path surface to move the entire network. Adjust **Width**, **Soft edge**, **Texture seed**, name and visibility in the inspector.

Each connection has one bend handle. Split a connection when you need an S bend or more local shape control. Junctions join at shared nodes; adjoining curves do not automatically enforce tangent continuity. Material and width apply to the entire path object; use separate paths for different surfaces or widths.

## Surfaces

| Surface | Appearance |
| --- | --- |
| Sand | Warm sand with subtle ripples |
| Dirt | Brown earth with irregular pigment |
| Stone | Grey stone blocks |
| Pebbles | Rounded, varied stones |
| Gravel | Smaller, denser aggregate |
| Cobblestone | Compact offset paving |
| Brick | Red offset masonry |
| Flagstone | Broad warm paving |
| Slate | Cool dark paving |
| Limestone | Pale paving |
| Clay | Red earth with fine grain |
| Mud | Dark earth |
| Wood chips | Elongated brown fragments |
| Worn grass | Muted green trail |

These are seeded procedural materials in `src/paths.cu`, with distance-filtered detail. They use terrain lighting and the existing weather and anime passes. They are colour/material treatments, not displaced stone geometry.

Paths replace the ground appearance inside their footprint and hide overlapping grass placements, including grass produced by Grass areas. The saved grass remains intact and returns if a path is moved, hidden or deleted. Other plants, trees and rocks are preserved. Paths do not flatten or excavate the terrain; sculpt the ground separately and the surface will follow it.

## Persistence and limits

Map files, local autosave and undo/redo include path nodes, connections and material settings. Older maps without paths still load. Terrain-only files contain height data, not scene paths.

Up to 32 paths, 128 nodes and 192 connections per path are supported. Width is 0.25–64 metres, and edge softness is 0–4 metres. The shared render budget is 16,384 sampled segments and 262,144 spatial references. Dense overlapping networks can reach that budget before the per-object limits; rejected edits leave the last valid map intact. Very long, sharply curved connections are bounded to 128 samples; split them for finer control.

The host builds a cached 64 × 64 spatial index and uploads it when paths change. The terrain shader evaluates nearby segments instead of searching every path at every pixel. Materials require no downloaded texture assets and no additional render pass. Authoring dense overlapping networks or dragging through a large grass population still has a cost; these limits are not a guarantee of a particular frame rate.

## Validation

With the local server running:

```sh
npm run build
npm run test:paths
```

The tests cover curve hit testing, validation, legacy loading, history, real viewport editing, junction connections, all 14 GPU materials, terrain edits, autosave reload and reversible grass exclusion.
