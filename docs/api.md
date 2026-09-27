# Reusing the grass/leaves instance system

`src/foliage-system.js` exports a DOM-independent `FoliageSystem`. `src/leaf.cu` owns all procedural geometry, lighting, wind, visibility and shading. The JavaScript module owns buffers, cached bindings, validated configuration and queue dispatch. No Three.js or handwritten WGSL is used.

## Generated batches

```js
import {FoliageSystem} from './src/foliage-system.js';

const foliage = await FoliageSystem.create({
  width: 1280, height: 896, capacity: 200000
});
foliage.configure({preset: 'weeping-willow', count: 100000, seed: 42, bins: 8});
foliage.setLight({azimuth: 305, elevation: 40});

// Called from your frame loop. Returns a GPU resource, not CPU pixels.
const rgba = foliage.render({time: seconds, wind: 0.1, yaw: 0.3, tilt: 0.16});

// Switch the same buffers and lighting system to rooted grass.
foliage.configure({preset: 'grass', count: 100000, seed: 7});
foliage.render({time: seconds, wind: 0.2, tilt: 0.65, focus: 0.5});

// Only when no more rendering is needed:
await foliage.dispose();
```

The output is RGBA8 packed in `rgba.gpuBuffer`, with `width * 4` bytes per row. Copy it to your display texture, or call `foliage.present(context)` after configuring a WebGPU canvas with the same device, `rgba8unorm`, and COPY_DST | RENDER_ATTACHMENT usage. A minimal example with two independent batches sharing a device is in `reuse.html`.

`create` accepts an existing `runtime`; disposing that system releases its own buffers but does not dispose the borrowed runtime. Width must be a multiple of 64 for texture row alignment. Capacity is 1–200,000 instances. The packed visibility format reserves IDs from 250,000 for branches; simply raising capacity without changing this format is unsupported.

Each system currently renders one batch into its own output/depth buffers. Multiple systems can share one runtime/device and be displayed separately. Cross-batch depth compositing into a single world, LOD and terrain streaming are not implemented.

## Custom data / your own CUDA emitter

Three float4 records describe each instance (48 bytes):

| Buffer | Components |
|---|---|
| `pos` | world x, y, z; leaf half-length or grass height |
| `normal` | normal azimuth in [0, 6.283185); normal elevation in [-1.35, 1.35); pigment variation in [0,1]; integer cluster ID 0–127 |
| `shape` | world-space long-axis direction x, y, z; width ratio for leaves, world-space half-width for grass |
| `centers` | 128 float4 records: cluster x, y, z; reserved |

For grass, `pos.xyz` is the root. Position displacement is zero at the root and grows quadratically toward the tip. `shape.xyz` sets the lean; `pos.w` is blade height. Leaf directions should normally be unit length. Supported custom lengths are >0 and ≤2; widths are >0 and ≤1. Supply finite scene coordinates that fit the current depth range, approximately -16 to +18 along the camera depth axis. Large world coordinates need a camera-relative extension.

Upload external records once:

```js
foliage.setInstances({
  positions: new Float32Array([0, 3.6, 0, 0.15]),
  normals: new Float32Array([0, 0, 0.5, 0]),
  shapes: new Float32Array([1, 0, 0, 0.5]),
  centers: new Float32Array(128 * 4),
  kind: 'leaves' // or 'grass'
});
foliage.render({time: 0, wind: 0.1});
```

Custom leaves use the broadleaf material/mask. They do not automatically create a trunk. To generate records directly on the GPU, bind `foliage.buffers.pos`, `.normal`, `.shape`, and `.centers` as outputs of your own CUDA kernel, submit it on `foliage.runtime`, then call:

```js
foliage.useGpuInstances({count: instanceCount, kind: 'grass'});
```

This does not read back or validate GPU-written records. Your emitter must satisfy the record contract above. Calling it again marks shared lighting dirty after you update clusters. The same-queue submission order provides synchronization. To return to a supplied generator:

```js
foliage.useGenerated({preset: 'english-oak', seed: 42, count: 100000});
```

Changing preset/count/seed via `configure` also selects generated geometry; light and bin changes preserve custom records. A same-value `configure` does not reset a custom batch—use `useGenerated` for an explicit reset.

## Cache and lighting

Seed/count/preset changes regenerate records. Light direction and bin changes refresh only shared exposures. Camera, time, wind, inspection mode and autumn tint do not regenerate records. Bind groups are cached and uniforms updated per dispatch.

There are 128 clusters × `bins * bins / 2` exposure values. `bins` accepts 4, 8 or 16. Lights use two-sided diffuse response and heuristic shelter; grass uses a common shelter factor. Wind shading uses rest-pose normals and positions. There are no true inter-leaf shadows.

For inspection, render `mode` 0 = shared exposure, 1 = per-visible-leaf reference, 2 = group colours, 3 = exposure error ×5. `autumn` ranges 0–1 and applies only to deciduous presets. `read(name)` is an optional diagnostic readback, never required by the normal render loop.

## Flower presets

Built-in flower IDs 21–30 use the same buffers and cache. Select a key such as `sunflower`, `tulip` or `bearded-iris` with `configure`. See [flower reference](flowers.md). Each bed has 16 plants; count controls the number of small surface samples across petals and leaves, not the number of plants. Stem segments use the existing branch buffers.

Generated flower `normal.z` uses the integer part for material (0 leaf, 1 petal, 2 centre/corona/beard) and the fractional part for pigment. This is an internal built-in convention; the custom leaf/grass upload API retains its documented [0,1] pigment contract. Flower stems and surfaces use the same root-anchored CUDA wind deformation. Normals remain in the rest pose.

## Fern presets

IDs 31–40 use keys such as `boston-fern`, `autumn-fern` and `birds-nest-fern`. Each generator produces a crown of 16 curved fronds. Count controls foliage surface sampling density, not the frond count. Bipinnate presets include secondary pinna stems. The default fern camera tilt is 0.4 radians. Shared root-anchored wind moves stems and foliage; lighting retains rest-pose normals. See [fern reference](ferns.md).

## Moss presets

IDs 41–50 use keys such as `pincushion-moss`, `tree-moss` and `silvery-thread-moss`. Each generator renders a magnified patch of shoots and leaf surfaces using the existing instance buffers. Count controls surface sampling density, not the patch size. Moss emits no tree/fern branch segments; shoot axes are sampled in the instance stream. Default camera tilt is 0.65 radians with focus height 0.3. These presets currently generate their own patches; arbitrary mesh-surface attachment is not implemented. See [moss reference](moss.md).

## Vines and ivy

IDs 51–60 use keys such as english-ivy, virginia-creeper and chinese-wisteria. The generator selects trunk-following, stem-twining or trellis-spreading paths by species. Each preset has eight leaders and eight connected lateral shoots, with varied attachment nodes and 128 leaf groups. Count controls leaf surface samples. Trunk scenes use 505 active stem/support segments; trellis scenes use 512. Default camera tilt is 0.16 radians and focus height 1.5.

Support and attached stems stay fixed while leaf surfaces flutter slightly outward. This is a static generator using built-in supports, not an arbitrary-mesh climbing or collision solver. See [vine reference](vines.md).

## Grass species

IDs 61–70 add ten species-inspired blade generators while preserving the original grass preset (ID 10). Use keys such as blue-fescue, bermudagrass or fountain-grass. Each instance is a complete rooted blade or seed-bearing stalk, using the existing six-segment blade rasterizer. Root y is zero; wind displacement increases toward the tip. Count is the blade/stalk count, not surface samples. New defaults: camera tilt -0.5 radians, focus 0.65 and scale 150. See [grass reference](grasses.md).

## Crop presets

IDs 71–80 (wheat, barley, oats, rice, maize, grain-sorghum, pearl-millet, sugarcane, soybean, cotton) use the existing configure/render/present API. Count specifies surface samples over 32 plants in four rows, with 256 connected stem segments. Default crop camera tilt is -0.35 and focus height is 1.15. Seed changes plant variation; count changes sampling detail, not plant count. See [crops.md](./crops.md) for sources and approximation limits.

## Mushroom colonies

Presets 81–90 use the same configure/render/present methods. Count controls surface detail for 16 fruiting bodies; the seed controls variation. Mushroom geometry is rigid under wind. Caps, stems and undersides share grouped lighting; wood-supported species include a shaded log. See [mushrooms.md](./mushrooms.md) for preset keys, sources and limitations.

## Rock and crystal formations

Presets 91–100 use configure/render/present with 16 seeded pieces per formation. Count controls surface samples. Geometry remains rigid under wind; light changes preserve sample buffers. Crystal shading adds a view-dependent highlight to opaque facets. See [rocks.md](./rocks.md) for keys, sources and rendering limits.

## Ground litter

Presets 101–110 use the existing API with 128 seeded debris objects. Count controls surface detail, not object count; geometry stays rigid under wind. Default tilt is -0.85, focus height 0.1. See [litter.md](./litter.md) for keys and limitations.

## Deadwood and stumps

Presets 111–120 use the same API. Count specifies surface samples over fixed trunk/root/branch structures. Geometry is rigid under wind. Bark, exposed ends and hollow interiors have separate material ranges. See [deadwood.md](./deadwood.md) for preset keys and limitations.
