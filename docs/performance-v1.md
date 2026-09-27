# Leaf

A local experiment in seeded, GPU-resident leaf instances with shared approximate lighting. Geometry generation, wind displacement, visibility, branches and pixel shading are authored in `src/leaf.cu`, compiled by the CUDA WebShader system copied from `D:\cuda-webshader`.

## Run

```powershell
cd D:\Leaf
npm run build
npm start
```

Open http://127.0.0.1:5197 in a WebGPU-capable browser. Drag to orbit and scroll to zoom. No dependency installation is needed to build or serve. The validation script currently uses the existing Playwright installation at `D:\cuda-webshader\node_modules` and installed Microsoft Edge.

## How the experiment works

1. A tree seed creates 128 canopy cluster centres. Leaf `i` belongs to cluster `i % 128`; `i / 128` is its stable offset within that cluster.
2. A hash of the tree seed, cluster and offset produces position, normal, size and pigment. Increasing the instance count preserves the previously generated prefix. Two float4 buffers cache these records (32 bytes per instance). Capacity is 200,000 instances, or 6.4 MB, even at a lower selected count.
3. Orientation is quantized into azimuth and elevation bins. The pair `(cluster, orientation bin)` identifies a shared exposure. The default is 128 clusters × 32 orientations = 4,096 values.
4. The lighting kernel evaluates two-sided diffuse response and a heuristic directional canopy shelter factor at each cluster centre and bin representative normal. The cache refreshes when the light, seed or bin count changes. Light changes do not regenerate instances.
5. Every frame, a CUDA compute rasterizer projects each animated leaf as a small elliptical splat. Atomic minimum on a packed depth/instance key resolves occlusion deterministically. Branches use the same visibility buffer. Another CUDA pass looks up exposure and produces RGBA pixels; JavaScript copies the GPU buffer directly into the canvas texture. There is no per-frame CPU geometry upload or pixel readback.

JavaScript handles controls, kernel dispatch and display. There is no Three.js, WebGL renderer or handwritten WGSL. Generated artifacts are built from the `.cu` source.

## Comparison controls

- **Shared exposure:** the cached group exposure with individual seeded pigmentation.
- **Per-leaf reference:** evaluates the same analytic lighting model using the selected visible leaf's own position and normal. This evaluates per visible pixel, so it is a visual reference rather than an equivalent performance baseline.
- **Lighting group colours:** stable colours identify lighting group membership.
- **Exposure error × 5:** red highlights absolute exposure error, magnified five times, before pigment and display encoding.

The 24.4× figure is `100000 / 4096`, an operation-count reduction for a lighting refresh compared with evaluating all instances. It is **not** a demonstrated frame-rate improvement. Drawing still processes every active leaf. Instancing here means procedural instance records expanded by compute; this prototype does not issue hardware instanced triangle draws.

## Validation

Run `npm test` while the server is running. Results are written to `artifacts/validation.json`, and a browser screenshot to `artifacts/leaf-default.png`.

Validation covers pipeline startup, 100k and 200k leaves, all inspection modes, finite position data, stable geometry under light changes, a changed seed producing different geometry, and a repeated seed reproducing the original geometry. It also compares every leaf's shared GPU exposure against the analytic reference at seed 42, sun azimuth 305°, elevation 40°.

Recorded absolute exposure error (exposure scale 0–1):

| Shared values | Mean absolute error | RMS error | Maximum error |
|---:|---:|---:|---:|
| 1,024 | 0.0782 | 0.0993 | 0.4001 |
| 4,096 | 0.0509 | 0.0654 | 0.3118 |
| 16,384 | 0.0316 | 0.0393 | 0.1630 |

These are one tree/light configuration, not universal error bounds. The UI timing includes host submission and queue completion, excludes the animation-frame scheduling interval, and is not a GPU timestamp benchmark. Grouped/reference lighting performance has not been isolated.

## Performance investigation and fix

GPU timestamps on the local NVIDIA Blackwell adapter identified the branch rasterizer as the dominant cost. The original kernel assigned one thread to an entire branch. The trunk thread serially processed its overlapping circular stamps, while almost the whole GPU sat idle. The optimized kernel assigns a workgroup to each branch and distributes the same stamp sequence across 128 lanes. Integer atomic minimum makes stamp ordering irrelevant, preserving coverage and depth exactly.

Median GPU compute times at 1280×896, after five warmup iterations and across 25 measured iterations:

| Scenario | Original | Optimized | Compute speedup |
|---|---:|---:|---:|
| 100k leaves, default zoom | 30.221 ms | 0.364 ms | 82.9× |
| 200k leaves, default zoom | 30.290 ms | 0.429 ms | 70.6× |
| 100k leaves, maximum zoom | 230.513 ms | 2.138 ms | 107.8× |

At 100k/default zoom the original branch pass alone was 30.146 ms; it is now 0.290 ms. Leaf rasterization was already about 0.058 ms. These times cover clear, leaf raster, branch raster and resolve; they exclude canvas copy, browser presentation, CPU submission, and scheduling. Generation and lighting are measured separately and excluded from steady compute time. Each pass is timestamped separately in the profiling harness, unlike the single batched production frame. This is not a claim of 83× displayed FPS.

Exact SHA-256 pixel matches passed for all three profiling scenarios plus two additional seed/camera/wind configurations, one using error visualization. Functional smoke tests pass after the change. The original CUDA and artifacts remain in `artifacts/baseline` for reproducibility.

```powershell
node scripts/profile.mjs --baseline
node scripts/profile.mjs
node scripts/parity.mjs
npm test
```

Raw results: `artifacts/profile-before.json`, `artifacts/profile-after.json`, `artifacts/parity.json`. The largest remaining compute cost is overlapping trunk/branch stamps, particularly at maximum zoom; the lighting cache is not the current bottleneck.

## Current limits

- Cluster shelter and the ground contact shadow are heuristic. There are no leaf-to-leaf light rays or shadow maps.
- Leaves are opaque elliptical splats with centre depth, not textured triangle meshes; depth has 14 bits and the leaf identifier 18 bits. Camera projection is orthographic. No LOD or frustum hierarchy is implemented.
- Wind moves positions and rotates the projected splats. Lighting intentionally uses rest-pose normals and positions, so wind does not invalidate the light cache. Branch tips do not follow leaf wind.
- Finer angular bins reduce orientation error, but using the cluster centre leaves spatial lighting error. More groups will not remove that completely.
- The test exposes optional readback hooks for diagnostics; the ordinary rendering loop never calls them.

## Source provenance

`vendor/cuda-webshader` is the compiler/runtime source copied from `D:\cuda-webshader` at commit `9011955806cee30636ba24ae34b22d218e84196f`. The source checkout had an unrelated untracked `showcases/river-study/` directory, which was not copied. The upstream MIT license is preserved as `vendor/LICENSE.cuda-webshader`. The original checkout was not edited.
