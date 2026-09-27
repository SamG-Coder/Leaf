# Leaf — procedural trees, leaves and grass

[Open the world editor](https://samg-coder.github.io/Leaf/editor.html) � [Rendering lab](https://samg-coder.github.io/Leaf/) � [Build and deployment](https://github.com/SamG-Coder/Leaf/actions)

Ten tree presets, ten bush presets, ten flower presets, ten fern presets, ten moss presets, ten vine/ivy presets, ten grass species presets, ten crop presets, ten mushroom colony presets, ten rock/crystal formations, ten ground-litter presets, ten deadwood/stump presets, and a reusable CUDA WebShader instance system for leaves and grass. Generation, wind, shared lighting, depth testing and pixel shading live in `src/leaf.cu`. JavaScript is host/API/UI glue.

## Map editor

Open `editor.html` for the Scene and Terrain workspaces: all 121 assets, drag/drop, radius selection, transforms, height brushes, automatic ground attachment, undo/redo, autosave and JSON map/terrain save-load. The editor now has a perspective camera with Unity-style right-mouse flight, Alt-orbit, pan and selection framing. Worlds support up to 65,536 m width and 100,000 stored placements, with sparse terrain and bounded visible rendering. Use **Example** to load the 1 km island: wooded uplands, sandy beaches, four curved grass areas with seeded rotations, a lagoon and a river with directional surface flow. See `docs/editor.md` for controls, limits and tests.

## Run

```powershell
cd D:\Leaf
npm run build
npm start
```

Open http://127.0.0.1:5197. The local server is port 5197. Select a tree or **Instanced grass** under **Species / emitter**. Drag to orbit; scroll to zoom. Autumn tint applies to deciduous presets. Light direction, orientation grouping and error views remain available.

- `deadwood.html`: ten logs, stumps, root and branch forms.
- `docs/deadwood.md`: geometry, materials and API integration.
- `litter.html`: ten ground-litter presets with fixed seeded scatter.
- `docs/litter.md`: shapes, sample semantics and reuse.
- `rocks.html`: ten rock and crystal formations.
- `docs/rocks.md`: geological references, generation details and reuse.
- `mushrooms.html`: ten mushroom colonies, including wood-supported shelves and a fairy ring.
- `docs/mushrooms.md`: species references, rendering details and reuse.
- `crops.html`: ten crops in planted rows.
- `docs/crops.md`: crop keys, sources, sample semantics and integration.
- `grasses.html`: ten rooted turf and ornamental grass presets.
- `docs/grasses.md`: grass keys, growth forms and rendering details.
- `vines.html`: ten vines and ivies with connected stems, petioles and species-specific foliage.
- `docs/vines.md`: vine keys, sources, path structure and integration.
- `moss.html`: ten magnified moss patches with cushion, turf and branching forms.
- `docs/moss.md`: moss keys, source links and sample-count semantics.
- `ferns.html`: ten fern forms with curved fronds and attached pinnae/pinnules.
- `docs/ferns.md`: fern source links, generation details and integration.
- `flowers.html`: ten flower beds, each using 16 plants with seeded petal and leaf surface instances.
- `docs/flowers.md`: flower forms, source links, count semantics and integration.
- `bushes.html`: ten bush previews, including selected flowering forms.
- `docs/bushes.md`: bush keys, source links, material conventions and integration.
- `gallery.html`: ten tree previews with research links; click a tree to open its interactive preset.
- `reuse.html`: 100k maple leaves and 100k grass blades rendered by independent batches sharing one GPU runtime.
- `docs/species.md`: botanical sources, what each preset implements, and approximation boundaries.
- `docs/api.md`: reusable API, GPU record layout and custom CPU/GPU emitter integration.

## Included trees

English oak, red maple, silver birch, weeping willow, Norway spruce, stone pine, Lombardy poplar, Italian cypress, blue gum and Canary Island date palm. Species differ in canopy distribution, trunk/branch form, leaf/needle/leaflet shape and material. Lombardy poplar and Italian cypress represent narrow cultivated forms. These are research-informed stylizations, not botanical reconstructions. Palm foliage instances are leaflets, and cypress instances represent small foliage sprays.

## Instance architecture

`FoliageSystem` in `src/foliage-system.js` creates a reusable GPU batch. It supports built-in generators, one-time external record uploads through `setInstances`, and direct output from another CUDA emitter through `useGpuInstances`.

Every instance has three float4 records: position/size, normal/pigment/cluster ID, and shape direction/width. At 200k capacity these occupy 9.6 MB; the 128 cluster records, exposure cache and frame/depth buffers are additional. IDs and storage stay stable when light or camera changes. Increasing generated count preserves existing records. Geometry is regenerated only when the seed, count or preset changes.

Lighting shares exposure across a spatial cluster and quantized normal direction. The default 128 × 32 groups produces 4,096 exposures. Changing the light refreshes that cache. Grass uses the same cache and depth/resolve path, but emits rooted curved blades instead of leaf masks. Wind displacement grows toward blade tips and stays zero at the roots.

The renderer uses compute instances expanded into screen pixels, not hardware triangle-instance draws. Each batch has its own image and depth buffer. Cross-batch world compositing, terrain streaming, LOD, true leaf shadows and physically measured species proportions are outside this implementation.

## Validation and performance

With the server running:

```powershell
npm test
npm run profile
node scripts/test-reuse.mjs
node scripts/test-flowers.mjs
node scripts/test-ferns.mjs
node scripts/test-moss.mjs
node scripts/test-vines.mjs
node scripts/test-grasses.mjs
node scripts/test-crops.mjs
node scripts/test-mushrooms.mjs
node scripts/test-rocks.mjs
node scripts/test-litter.mjs
node scripts/test-deadwood.mjs
```

The scripts use the existing Playwright installation at `D:\cuda-webshader\node_modules` and installed Microsoft Edge. Building/serving the demo itself requires no dependency installation.

`npm test` checks all 121 presets, finite geometry, visible wind response, deterministic seeds, unchanged geometry under light changes, stable count prefixes, 200k grass/palm capacity, invalid API inputs, custom instance records, switching back to generated geometry, and the browser UI. It also renders the species previews and comparison sheet. `test-reuse` exercises two systems on a shared device.

GPU timestamps at 1280×896, 100k instances, default scale, 25 samples after 5 warmups on the local NVIDIA Blackwell adapter:

| Preset | Median GPU compute |
|---|---:|
| English oak | 0.168 ms |
| Red maple | 0.203 ms |
| Silver birch | 0.097 ms |
| Weeping willow | 0.263 ms |
| Norway spruce | 0.160 ms |
| Stone pine | 0.204 ms |
| Lombardy poplar | 0.172 ms |
| Italian cypress | 0.120 ms |
| Blue gum | 0.274 ms |
| Canary Island date palm | 2.000 ms |
| Grass | 0.124 ms |

200k grass measured 0.224 ms; 200k palm 3.388 ms. The widest palm leaflets at maximum zoom measured 10.153 ms for 100k. Those leaflets cover far more pixels than small tree leaves. These are compute-only measurements with cached geometry/light, not browser FPS; they exclude canvas copy, presentation and host overhead. See `artifacts/profile-foliage.json` and `artifacts/foliage-validation.json` for raw results. The UI shows submission plus GPU completion time, a different metric.

The earlier branch parallelization is retained. Its original before/after measurements and pixel-parity records are historical, before species geometry changed; see `docs/performance-v1.md`, `artifacts/profile-before.json`, `artifacts/profile-after.json`, and `artifacts/baseline`. They are not evidence of pixel parity between the original generic tree and these species.

## Source provenance

`vendor/cuda-webshader` is the compiler/runtime copied from `D:\cuda-webshader` at commit `9011955806cee30636ba24ae34b22d218e84196f`. The upstream MIT license is in `vendor/LICENSE.cuda-webshader`. The original checkout was not modified. Generated JSON contains compiler-produced WGSL; author shader changes in `.cu` and run the build.

## Branch structure and bark update

Oak, maple, birch, stone pine and blue gum now use a tapered curved trunk, eight main limbs, and twigs attached along those limbs. The canopy instance positions are preserved. A CUDA `wood` kernel caches segment endpoints/radii when geometry changes (512 segment slots, 16 KiB across two buffers).

All species share a rounded tapered-segment rasterizer with surface depth, approximate surface normals, directional diffuse lighting and ambient fill. Bark uses deterministic world-space procedural patterns: irregular grain, pine plate-like cracks, birch dashes and pale blue-gum patches. It no longer depends on screen-pixel hashes. This remains an approximate compute surface renderer, without branch shadow maps or true cylinder intersections.

`node scripts/test-branches.mjs` verifies that sun changes affect wood colour but not segment geometry/depth, and returning from a camera orbit reproduces the rendered pixels. Results are in `artifacts/branch-validation.json`; bare-branch inspection images are `artifacts/branches-0.png`, `branches-1.png`, `branches-2.png`, `branches-5.png`, and `branches-8.png`. The gallery has been regenerated.

## Bush collection

Boxwood, English lavender, rosemary, bigleaf hydrangea, Catawba rhododendron, Southern Indian azalea, border forsythia, creeping juniper, Japanese holly and Japanese barberry are IDs 11–20. They use low multi-stem wood, the existing lit bark, distinct foliage distributions, and flower instances where applicable. Select them from Species / emitter or open `bushes.html`. See `docs/bushes.md` for interpretation and sources. `artifacts/foliage-validation.json` includes per-preset GPU timings at 768×768 and 100,000 instances; those timings are not browser FPS.


## Public deployment and development

Requires Node.js 24 or newer. Run `npm ci`, `npm run build`, then `npm start`; open http://127.0.0.1:5197/editor.html. Browser GPU tests use Playwright and Microsoft Edge (`msedge`); install Edge before running them. Rendering requires WebGPU support and HTTPS or localhost. GPU test results in artifacts are local measurements, not CI hardware guarantees.

`npm run check` verifies JavaScript syntax; `npm run test:model` checks the map model; `npm run build:pages` compiles every CUDA entry point and stages the complete static site in `dist/`. Pushes to main run those checks in GitHub Actions and deploy GitHub Pages. Pull requests run the build without deploying. CI does not run the local GPU benchmarks.

The CUDA WebShader compiler/runtime is vendored with its license in `vendor/LICENSE.cuda-webshader`. Rendering kernels are authored in `.cu`; JavaScript handles UI, input, data and GPU dispatch. Performance work is ongoing: isolated local benchmark improvements do not establish that all rapid-travel hitches have been eliminated.


## Water

The editor's Scene library includes draggable Water plane and Grass area polygon objects with live placement previews, corner editing and W/E/R transform handles. Only water supports vertical movement. Horizon ocean and shared water-weather controls live under Terrain. Water-aware ground shading adds sandy coasts, wet earthy banks and seabeds. A lightweight ClearWater-derived CUDA surface shader shares wind/rain inputs across all water and uses the existing anime finish. See [water controls, design and limitations](docs/water.md). Run `node scripts/test-water.mjs` with the local server running to validate editing and compatibility.

The Terrain panel includes an optional day/night clock and manual or time-driven weather, with animated clouds, rain, water impact rings, and terrain wetness. See [weather controls and limits](docs/weather.md).
