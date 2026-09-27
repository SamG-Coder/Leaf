# World editor

Open http://127.0.0.1:5197/editor.html. Use Example for the forest hills stress test, or drag assets from the searchable library onto the terrain. All 121 presets are available. The viewport is a freely navigable perspective scene.

## Camera controls

The primary navigation follows Unity Scene view conventions: https://docs.unity3d.com/Manual/SceneViewNavigation.html

| Input | Action |
| --- | --- |
| Hold right mouse + move mouse | Look around |
| Hold right mouse + W/A/S/D | Fly forward/left/back/right |
| Hold right mouse + Q/E | Move down/up |
| Shift while flying | Four times normal speed |
| Wheel while holding right mouse | Adjust flight speed |
| Middle mouse drag | Pan in the camera plane |
| Alt + left mouse drag | Orbit the current pivot |
| Alt + right mouse drag | Dolly |
| Mouse wheel | Dolly toward/away from pivot |
| F / Frame selected | Frame selected objects and set orbit pivot |
| Home / Fit map | Frame the whole map |
| Q or H / Pan tool | Left-drag navigation in Scene or Terrain |
| Space + left drag | Temporary pan |

Flight speed can also be set explicitly in metres per second in the inspector. Camera navigation does not paint terrain or modify placements. Camera, selection and undo history are session state; map files contain world data.

## Scene workspace

Drag a library card into the viewport, or choose Place and click the ground. Select visible geometry by clicking. Drag to move; Shift adds/removes selection. Radius select picks visible object anchors inside a world-space circle. Brush radius has both a slider and a precise numeric input.

New placements use per-asset scale defaults from src/asset-scale.js: larger trees and smaller flowers, ferns, moss and mushrooms. These are authoring defaults relative to generator units, not measured botanical dimensions. Saved object scales remain unchanged. The inspector edits X/Z, rotation, scale, seed and visibility. Multi-object position edits apply a common delta; other fields set a common value. Duplicate and Delete act on selection. Search the scene hierarchy by asset name or exact object ID; only the first 200 matches are listed to keep the panel responsive on large worlds. F frames the selection even when it is far from the camera. Snapping uses a 0.5 m grid.

V/W selects, B activates radius selection, P places, Delete removes, Escape clears selection. Ctrl/Cmd+Z undoes, Ctrl/Cmd+Shift+Z redoes, Ctrl/Cmd+S saves when viewport controls have focus.

## Separate Terrain workspace

Raise, Lower, Flatten and Smooth edit the ground. Radius, strength and flatten height control the brush. One stroke is one undo action. Object base height follows the terrain automatically after sculpting or movement. Objects remain upright and rigid: attachment currently changes height, not slope orientation or the geometry of broad foliage patches.

Choose dimensions in New Map before editing: maps can be 8 to 65,536 metres wide. The world inspector shows read-only dimensions; terrain imports must match the existing map size. Small maps use the original 65 by 65 base heightfield. Larger maps allocate sparse local terrain tiles only where sculpting occurs, with 2 m node spacing and 32 by 32 nodes per tile. Up to 4,096 edited tiles are supported. A world does not allocate a dense heightfield across its entire area. The base surface and tile offsets each support -256 to 2,048 m. Large maps retain their base heightfield for compatibility and broad terrain shape.

The maximum extent is about 65.5 km across; it is not a claim that the entire world can be densely sculpted at once. Ray-marched terrain uses bounded sampling, so very narrow distant features can lose detail. There are no terrain overhangs or underground volumes.

## Save and load

Save map downloads validated leaf-map version 1 JSON containing name, extent, sunlight, base terrain, sparse tiles and object records. Old version 1 maps without tiles remain readable. Invalid imports preserve the current map. New and successful Load are undoable. Undo history uses a roughly 64 MiB snapshot budget and at most 60 entries; a large edit may retain fewer steps.

Local autosave uses IndexedDB so large worlds do not depend on localStorage's small quota. The old localStorage autosave is used as a migration fallback. Portable JSON files remain the way to transfer maps between browsers or machines. File imports are limited to 200 MB; available browser storage and memory remain practical constraints.

Terrain mode has separate Save terrain / Load terrain controls. These contain extent, base heights and sparse tiles. Existing objects stay in place and sample the imported ground. Terrain imports with different dimensions are rejected; they cannot resize an existing map.

## Rendering and current limits

The editor caches CUDA-generated 3D sample geometry, not camera-facing asset images. src/scene.cu renders perspective terrain and transformed asset samples into shared depth and picking buffers. src/leaf.cu supplies procedural geometry and material helpers. JavaScript handles UI, input, brush data, history, validation, file I/O and dispatch. No Three.js renderer is involved.

The map supports 100,000 stored placements. A working view renders up to 4,096 nearest eligible placements with up to 128 distinct preset/seed geometry variants. Frustum and subpixel screen-size culling and an adaptive two-million-sample foliage budget bound rendering work; branch and grass samples are additional. Distant or over-budget objects are omitted rather than all 100,000 being drawn simultaneously. The status bar reports the actual rendered count. Scale is 0.1 to 3.

Sun direction and elevation preview continuously on slider input. Releasing a slider commits one undo step and autosave, without cloning the scene on every preview. Position, rotation, scale, sunlight, camera and terrain changes reuse geometry. New preset/seed combinations populate the least-recently-used GPU cache. Close assets use a separate eight-variant cache with up to 200,000 samples per variant, while distant assets retain the 20,000-sample cache. Sample counts respond to projected size; branches switch from 32 to 128 longitudinal rings with 16 samples around each ring. Geometry cache storage is about 200 MiB, with terrain and output buffers additional. Rendering is demand-driven, including continuous updates during active flight. This is a sampled procedural renderer; close views can reveal finite sample density. Wind animation, inter-object shadows, runtime/mesh export and collision are not implemented.

## Validation

With the server running:

```
npm run build
node scripts/test-map-model.mjs
node scripts/test-editor.mjs
node scripts/test-editor-lod.mjs
node scripts/test-editor-settings.mjs
node scripts/test-editor-camera.mjs
node scripts/test-editor-capacity.mjs
```

The interaction suite covers drag/drop, GPU picking and dragging, transforms, duplication, radius selection, terrain attachment, geometry reuse, undo/redo, map and terrain round trips, invalid imports and autosave. Camera checks cover right-mouse look and flight, vertical flight, speed adjustment, orbit pivot, dolly, middle pan in Terrain, selection framing and preservation of scene data.

The capacity suite constructs 100,000 placements on a 65,536 m world, sculpts terrain at X 24,000 / Z -20,000, frames the distant object, checks bounded visibility, round-trips data and restores it from IndexedDB after reload. Timings in the reports are coarse end-to-end updates on the test machine, not guaranteed frame rates or GPU benchmarks.

Reports: artifacts/editor-validation.json, artifacts/editor-camera-validation.json and artifacts/editor-capacity.json. Screenshots: artifacts/editor-scene.png, artifacts/editor-terrain.png, artifacts/editor-orbit.png and artifacts/editor-large-world.png. Example map: artifacts/forest-hills.leaf.json. The deterministic 512 m forest contains 7,923 placements, including 2,010 trees, rolling hills up to about 58 m, a winding open corridor and a clearing. Its initial view disables the grid and sets flight speed to 25 m/s. The view can retain thousands of distant objects with lower sample counts instead of selecting a sparse subset of the forest.

## Forest rendering performance

The renderer submits a shared object table and flattened work list to two CUDA scene passes, plus terrain, rather than issuing two dispatches per placement. Geometry and object/work buffers are reused. Assets without procedural wood skip branch work. The foliage budget and visible object selection are unchanged by batching.

On the local headless Edge test, ten warmed forest updates changed from a median 64.1 ms to 20.8 ms (3,074 placements and 1,998,067 foliage samples in both runs). Runtime dispatches dropped from 6,149 to 3, and runtime batch submissions from 98 to 2. Display-copy queue submission is additional. These are CPU-to-GPU-completion update timings, not guaranteed interactive FPS; camera movement and first-time generation can differ. Run `node scripts/bench-editor.mjs after` to repeat. Reports are `artifacts/forest-benchmark-before.json` and `artifacts/forest-benchmark-after.json`.


## Screen-space detail budget

Asset projected radius now controls sampling density as well as the high-detail cache. Small distant assets can use 16 samples rather than the previous 512-sample floor. Category-specific footprint estimates prevent a mushroom patch receiving a tree-sized budget. Density increases continuously with projected size. Small splats cover a limited pixel neighbourhood to preserve coverage; this is representative geometry sampling, not an exact average of every original leaf colour. It changes distant fine detail. Branch cross-sections use 4, 8 or 16 surface samples according to screen size. The viewport stays at full output resolution.

The example retained all 3,074 eligible placements while reducing foliage work from 1,998,067 to 733,412 samples. Ten warmed local updates measured a median 12.9 ms; see artifacts/forest-benchmark-screen-detail.json. Hardware, camera position, first-generation cost and scene content affect timings.

## Anime finish

Enabled by default. The inspector has Anime finish, Painterly softness and Ink outline strength controls. Foliage lighting combines the whole crown's outward direction with local normals around the seeded foliage cluster centres. Lit faces use warm greens; shaded faces use cooler teal greens. This retains volume before filtering.

The screen-space filter uses object bounds to size its neighbourhood, and object IDs, depth and original luminance to guide a bilateral blur. It softens detail within similarly lit surfaces while reducing mixing across depth and light/shadow boundaries. Whole-object average-colour mixing has been removed because it flattened canopy form. Broad tone shaping and silhouette outlines follow the blur. This is a painterly approximation, not a reproduction of a supplied illustration's geometry or hand-painted detail.

The original picking/depth buffers and geometry are preserved. Style controls are viewport settings and are not exported in map data. Run `node scripts/test-editor-anime.mjs` to test controls and preservation of map/geometry. The latest benchmark is artifacts/forest-benchmark-painterly-volume.json; it retains 3,074 visible placements and 733,412 foliage samples in the example.

### Paint texture

The Paint texture slider controls overlapping irregular brush dabs, pigment variation and subtle grain in the existing CUDA finish pass. Dab size follows each object's visible screen bounds. Samples stay within the object mask and reject large depth/light changes, preserving the volume lighting beneath the paint. Set the slider to zero to remove this layer while retaining painterly softness. The effect is deterministic for a stationary view; it is a screen-space treatment, so brush placement can change as the camera or visible bounds change. It does not add geometric leaves or reproduce a hand-painted reference exactly. Validation: scripts/test-editor-anime.mjs. Timing report: artifacts/forest-benchmark-paint-texture.json.

## Placement-based ground materials

Enabled by default through World settings. This changes only the terrain material, not manually placed grass or other objects. CUDA paints soft influence masks for canopy shade, litter, exposed soil, moss and stone. Trees/bushes contribute litter and root soil, conifers denser litter, moss patches moss, rocks stone, deadwood moss/soil and ground-litter assets litter. Ground slope adds exposed stone. World-space noise creates mottled painted transitions; the existing anime/painterly finish is applied afterward.

Shade is an artistic canopy-footprint projection using sun direction/elevation and estimated plant height. It updates while the sun control is dragged. It is not mesh-traced shadowing, terrain-aware occlusion, seasonal growth or a botanical simulation. Litter/root effects remain under the placement while shade moves with the sun.

A cached 512 by 512 GPU influence field covers a view-centred world region with adaptive spacing. It refreshes when placements/visibility, sunlight or the region changes, and does not regenerate foliage geometry. Beyond that local field the terrain uses its procedural grass/slope base; large-world regional refinement is bounded rather than allocating a dense world-sized texture. Validation: scripts/test-editor-ground.mjs; report artifacts/editor-ground-validation.json.

## Seed-derived triangle LOD

Distant trees and bushes switch to filled triangle proxies using their existing seeded foliage-cluster centres and branch endpoints. Canopies use eight triangular faces per cluster, while branch segments use four-sided tubes. Geometry is rasterized in CUDA into the shared depth and picking buffers, then receives the same screen-space painted finish. Near views keep detailed samples. Triangle coverage fades from full at a 16-pixel estimated radius to zero at 36 pixels, using a smoothstep curve. Complementary stable screen-pixel masks blend triangles and samples in the same depth/picking passes. This is a dithered coverage fade, not transparent alpha blending. Other asset categories retain screen-budgeted samples. Proxies approximate canopy shape and material; they are not exact leaf silhouettes. The current cache still generates the normal asset records when first encountering a variant, so this reduces distant rendering work rather than eliminating generation/storage.

Validation: scripts/test-editor-lod.mjs verifies near samples, far triangles and return to near detail. The forest's starting view selected 729 triangle proxies while retaining all 3,074 eligible placements.

Triangle LOD lighting now calls the same foliage material and canopy/cluster lighting helper as detailed samples. It interpolates vertex colours perspective-correctly over each face, retaining warm highlights and cool shadows. Branch normals face outward and use directional rather than absolute-dot lighting. The LOD test checks brightness variation and a colour response to changing sunlight on the far object's own pixels, without regenerating geometry.

### Close-up streaming and transitions

High-detail variants are requested at a 72-pixel projected radius, before the old 120-pixel switch. Only one uncached high-detail variant is generated per frame; base detail remains available for the rest, and the editor schedules refinement frames until the queue is complete. Sample allowance and branch ring counts increase gradually with screen size. Splat loops are clipped to the viewport and the depth-only pass skips foliage/bark colour evaluation.

`node scripts/bench-approach.mjs after` exercises a cold-cache approach and retreat, asserts transitional coverage and a maximum of one high-detail promotion per frame, and records timings in artifacts/approach-after.json. These changes bound promotion bursts; they do not guarantee spike-free rendering for every camera, device or scene.


### Persistent canopy surfaces
Trees and bushes retain a closed triangle surface per seed cluster at all viewing distances. Each octahedron face is split into four triangles (4,096 canopy triangles per object); shared edge midpoints round continuously toward an ellipsoid as the close leaf representation fades in. The close surface contracts to 88% of the proxy radius, letting the existing detailed leaves define the outer silhouette. It writes normal depth and object IDs and uses the shared foliage lighting; only branch proxies retain complementary LOD dithering. This fills sampling holes inside clusters while retaining real gaps between separate clusters. It is a hybrid surface/detail renderer, not a complete replacement of leaf samples. Near-plane crossing and species silhouette fidelity remain limitations of the proxy representation.

Validated with the close/far lighting regression and a warmed forest benchmark; the latter measured approximately 13–16 ms per render on the test machine, not a universal frame-rate guarantee.


### Close-canopy raster performance
The triangle rasterizer distributes screen rows across 16 or 64 lanes for large projected objects (above 128 or 256 pixels radius). Smaller objects use one lane. This changes work scheduling only: triangle topology, leaf budget, resolution, shading and pixel coverage remain unchanged. Separate splat and triangle work lists avoid launching each kernel over the other renderer's jobs; the depth-only triangle pass skips colour shading.

The cold-cache approach replay in `artifacts/approach-perf-before.json` and `artifacts/approach-perf-after.json` measured the closest position at 165.8 ms versus 8.9 ms with 200,000 leaf samples. These are individual machine-local measurements, not a guaranteed frame rate. The wider forest still showed occasional longer frames. `scripts/test-editor-raster-parity.mjs` compares serial and parallel rasterization on the same close oak: depth and IDs matched exactly; one output pixel differed by one 8-bit colour level in the recorded run. The serial override is a test-only view flag.


### Continuous tree wood
Tree and bush trunks/branches now use capped eight-sided triangle tubes at every distance. Their point-ring branch path is disabled, and wood coverage is not dithered during leaf LOD transitions. Bark is evaluated at the perspective-correct interpolated surface position in the colour pass, retaining texture across large faces. The triangle row-parallel raster path remains active. Build, close/far lighting tests and the oak preview passed; the warmed 3,074-object forest run measured 10.0–12.3 ms per render on the test machine. This supersedes the earlier branch-proxy dithering description.


### Under-canopy performance investigation
A repeatable 24-position path beneath a tree in the forest example is available through `scripts/bench-under-canopy.mjs NAME forest` (synchronized stage profiling) or `scripts/bench-under-canopy.mjs NAME forest normal` (normal submission path). Profile times include queue-completion waits and are not raw GPU timestamps.

Long, narrow projected branch triangles wasted work scanning their entire bounding boxes. Triangle rasterization now conservatively bounds each scanline to its edge intersections; original barycentric coverage and depth still determine which pixels are written. A test-only referenceRaster scalar retains the original full-box path for comparison. Depth and picking matched exactly on the close oak; one final colour pixel differed by one level. Resident high-detail cache capacity is now 16 variants while the active high-detail selection remains eight, reducing regeneration without changing the detail budget. This uses roughly 77 MB more geometry buffer storage.

Recorded synchronized forest path: median geometry 14.13 to 6.34 ms; maximum total 31.87 to 21.82 ms. Final normal submission path: median 9.07 ms, maximum 15.63 ms in this local run. These are test-route measurements, not a guarantee for every scene or camera position. See artifacts/under-canopy-forest-before.json, under-canopy-forest-after.json and under-canopy-forest-normal-final.json.


### Flyover diagnostics and redundant work
`scripts/bench-flyover.mjs NAME` replays 120 camera positions around the example forest; append `profile` for synchronized stage timing. `scripts/bench-live-flight.mjs` exercises real RMB and keyboard flight. `mapDiagnostics.timings` retains the latest 300 interactive renders, recording render duration, CPU preparation, position and render-start interval. Start intervals include idle/input delays and must not be interpreted as GPU frame times.

Triangle work lists now stop at each tree/bush generator's actual branch limit (288, 257 or 129), omitting only always-empty slots. Painterly bounds use boundary pixels for exact min/max reductions and no longer calculate unused RGB sums/counts. CPU-versus-GPU bounds verification is exposed through editorTest.boundsParity.

Recorded 120-position flyover: median 16.42 to 14.25 ms; p95 27.82 to 24.80 ms; max 40.41 to 31.70 ms. Interactive test max 11.80 ms. The user's reported 60 ms spikes were not reproduced in these runs; do not claim these fixes conclusively explain or eliminate them. Source artifacts: flyover-before.json, flyover-after.json, flyover-stages.json and live-flight.json. No sample, geometry or resolution budget was reduced.


### Flying directly through leaves
`scripts/bench-through-leaves.mjs NAME` runs 200 positions at canopy height in both view directions through a forest tree. The leaf splat rasterizer now bounds each circular sample row conservatively, retaining the original circle test and coverage. The test-only referenceRaster path retains the old square loop. No leaf counts or radii are reduced. Combined reference-versus-optimized parity passed (exact depth and IDs, one colour pixel differing by one level).

Recorded normal-path median/p95/max: 11.16/20.44/22.42 ms before, 10.12/15.78/18.00 ms after. The reported 60 ms hitch remains unreproduced on this route. Artifacts: through-leaves-both-before.json and through-leaves-both-after.json. Optional profile argument inserts synchronization waits and should not be compared directly with normal-path timing.


### Rapid map crossings
`scripts/bench-fast-crossing.mjs NAME` alternates between opposite sides of the example map for 80 frames; add `profile` for synchronized stages. Static placement heights and ground influence descriptions are now cached until object or terrain references change. Camera motion no longer recalculates terrain attachment for every placement or recreates each influence descriptor. Culling also avoids temporary per-object vector arrays. Ground region rasterization still updates when entering another region.

Recorded before/after medians: CPU prepare 3.34/2.11 ms, total 16.37/14.98 ms; p95 22.31/19.64 ms. Maximum was 28.93/30.62 ms: this optimization did not establish an improvement to the worst spike. The user's 60 ms event remains unreproduced. Interactive timing records now include camera travel distance, geometry generations, ground-region rebuilds and visible object count, to correlate future spikes with rapid movement. Ground edit/removal/light tests validate cache invalidation.
